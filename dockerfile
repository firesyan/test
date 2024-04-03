# 使用更具体的Debian镜像标签
FROM debian:buster-slim

# 添加32位架构支持
RUN dpkg --add-architecture i386

# 更新包列表
RUN apt update 

# 安装必要的工具和应用
RUN DEBIAN_FRONTEND=noninteractive apt install -y \
    wine \
    qemu-kvm \
    fonts-wqy-zenhei \
    xz-utils \
    dbus-x11 \
    curl \
    firefox-esr \
    gnome-system-monitor \
    mate-system-monitor  \
    git \
    xfce4 \
    xfce4-terminal \
    tightvncserver \
    wget

# 清理不必要的文件
RUN apt clean && rm -rf /var/lib/apt/lists/*

# 下载和解压noVNC
WORKDIR /root
RUN wget https://github.com/novnc/noVNC/archive/refs/tags/v1.2.0.tar.gz && \
    tar -xvf v1.2.0.tar.gz && \
    rm v1.2.0.tar.gz

# 配置VNC服务器
RUN mkdir $HOME/.vnc && \
    echo 'bothy' | vncpasswd -f > $HOME/.vnc/passwd && \
    echo '/bin/env  MOZ_FAKE_NO_SANDBOX=1  dbus-launch xfce4-session'  > $HOME/.vnc/xstartup && \
    chmod 600 $HOME/.vnc/passwd && \
    chmod 755 $HOME/.vnc/xstartup

# 配置启动脚本
RUN printf "%s\n" \
    "whoami" \
    "cd" \
    "su -l -c 'vncserver :2000 -geometry 1360x768'" \
    "cd /root/noVNC-1.2.0" \
    "./utils/launch.sh  --vnc localhost:7900 --listen 8900" \
    > /bothy.sh && \
    chmod 755 /bothy.sh

# 暴露VNC端口
EXPOSE 8900

# 容器启动命令
CMD ["/bothy.sh"]
