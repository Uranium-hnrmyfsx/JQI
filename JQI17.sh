#!/bin/bash
#2025.3.8 
#Uranium_hnrmyfsx
#ver2.0

# 定义Java版本和安装目录
JAVA_VERSION="17.0.14_7"
INSTALL_DIR="/usr/lib/jvm"
DOWNLOAD_URL="https://mirrors.tuna.tsinghua.edu.cn/Adoptium/17/jdk/x64/linux/OpenJDK17U-jdk_x64_linux_hotspot_${JAVA_VERSION}.tar.gz"


# 安装依赖项
sudo apt-get update
sudo apt-get install -y wget tar

# 清理旧安装
sudo rm -rf /tmp/jdk.tar.gz "$INSTALL_DIR"/jdk-*

# 下载JDK
echo "正在下载JDK..."
if ! wget -O /tmp/jdk.tar.gz "$DOWNLOAD_URL"; then
    echo "下载失败"
    exit 1
fi

# 验证下载文件
if [ ! -f "/tmp/jdk.tar.gz" ]; then
    echo "错误：文件未正确下载"
    exit 1
fi

# 解压安装
echo "正在安装到 $INSTALL_DIR..."
sudo mkdir -p "$INSTALL_DIR"
if ! sudo tar -xzf /tmp/jdk.tar.gz -C "$INSTALL_DIR"; then
    echo "解压失败，请检查："
    echo "1. 磁盘空间 (df -h)"
    echo "2. 文件完整性 (sha256sum /tmp/jdk.tar.gz)"
    exit 1
fi



# 立即生效环境变量
source /etc/profile.d/java17.sh

# 验证安装
if ! command -v java &> /dev/null; then
    echo "安装失败，请检查："
    echo "1. 符号链接：ls -l $INSTALL_DIR"
    echo "2. 环境变量：echo \$PATH"
    exit 1
fi

echo "安装成功！请重新登录。Java版本："
java -version
