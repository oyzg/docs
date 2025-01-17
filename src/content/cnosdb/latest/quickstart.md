# 快速开始

## 下载

- ### Ubuntu & Debian

   > MD5: 3aa8049d784487f6aeeab21a4e8f7c1c
   
   ```shell
   wget https://github.com/cnosdb/cnosdb/releases/download/v1.0.1/cnosdb_1.0.1_amd64.deb
   sudo dpkg -i cnosdb_1.0.1_amd64.deb
   ```

- ### Docker Image

   ```shell
   docker pull cnosdb:1.0.1
   ```

- ### RedHat & CentOS

   > MD5: 0d3c00abdb34764dcbd79eee33ea1c0f
   
   ```shell
   wget https://github.com/cnosdb/cnosdb/releases/download/v1.0.1/cnosdb-1.0.1.x86_64.rpm
   sudo yum localinstall cnosdb-1.0.1.x86_64.rpm
   ```

- ### macOS

   > MD5: 7711a3167255ee015f1f62f53d0e38cd
   
   ```shell
   wget https://github.com/cnosdb/cnosdb/releases/download/v1.0.1/cnosdb-1.0.1_darwin_amd64.tar.gz
   tar zxvf cnosdb-1.0.1_darwin_amd64.tar.gz
   ```

- ### Windows Binaries(64-bit) - using PowerShell

   > MD5: 62ea309b3edd8fe9c4b98d10f9bc7dcf
   
   ```shell
   wget https://github.com/cnosdb/cnosdb/releases/download/v1.0.1/cnosdb-1.0.1_windows_amd64.zip -UseBasicParsing -OutFile cnosdb-1.0.1_windows_amd64.zip
   Expand-Archive .\cnosdb-1.0.1_windows_amd64.zip -DestinationPath 'C:\Program Files\CnosDB\cnosdb\'
   ```

- ### Linux Binaries(64-bit)

   > MD5: 64c763c917030134971d21e54c21a59d
   
   ```shell
   wget https://github.com/cnosdb/cnosdb/releases/download/v1.0.1/cnosdb-1.0.1_linux_amd64.tar.gz
   tar xvfz cnosdb-1.0.1_linux_amd64.tar.gz
   ```

- ### Linux Binaries(64-bit, static)

   > MD5: eebb5665fcc4f540de488567caec187d
   
   ```shell
   wget https://github.com/cnosdb/cnosdb/releases/download/v1.0.1/cnosdb-1.0.1-static_linux_amd64.tar.gz
   tar xvfz cnosdb-1.0.1-static_linux_amd64.tar.gz
   ```

- ### Linux Binaries(32-bit)

   MD5: 3ed72382eb79d664baeac3b71d744b4b
   
   ```shell
   wget https://github.com/cnosdb/cnosdb/releases/download/v1.0.1/cnosdb-1.0.1_linux_i386.tar.gz
   tar xvfz cnosdb-1.0.1_linux_i386.tar.gz
   ```

- ### Linux Binaries(ARMv7)

   MD5: 90b2b8c72404e1835988325b3ea05f3d
   
   ```shell
   wget https://github.com/cnosdb/cnosdb/releases/download/v1.0.1/cnosdb-1.0.1_linux_armhf.tar.gz
   tar xvfz cnosdb-1.0.1_linux_armhf.tar.gz
   ```

- ### Linux Binaries(ARMv8)
   
   MD5: 631ef2e05b2d0f5a310422d1871bb003
   
   ```shell
   wget https://github.com/cnosdb/cnosdb/releases/download/v1.0.1/cnosdb-1.0.1_linux_arm64.tar.gz
   tar xvfz cnosdb-1.0.1_linux_arm64.tar.gz
   ```

- ### 验证下载二进制文件的真实性（可选）

  为了验证安全性，请按照以下步骤验证您下载的CnosDB的`gpg`签名（大多数系统默认包含`gpg`命令，如果`gpg`不可用，请参阅[Gun主页](https://gnupg.org/download)获取安装说明。

  1. 下载并导入CnosDB公钥

   ```
   curl -s https://www.cnosdb.com/cnosdb.key | gpg --import
   ```

   2. 通过在URL上添加`.asc`来下载指定版本的签名文件

   ```shell
    wget https://github.com/cnosdb/cnosdb/releases/download/v1.0.1/cnosdb-1.0.1_linux_amd64.tar.gz
   ```

   3. 验证签名 `gpg --verify`

   ```shell
    gpg --verify cnosdb-1.0.1_linux_amd64.tar.gz.asc cnosdb-1.0.1_linux_amd64.tar.gz
   ```

   此命令应该输出：

   ```shell
   gpg: Good signature from "CnosDB <contact@cnosdb.com>" [unknown]
   ```



## 安装

- ### Docker

  拉取镜像

  ```shell
  docker pull cnosdb/cnosdb:latest
  ```

  启动容器

   ```shell
   docker run -itd -p 8086:8086 cnosdb/cnosdb:latest
   ```

- ### Ubuntu & Debian

  下载

   ```shell
   wget https://github.com/cnosdb/cnosdb/releases/download/v1.0.1/cnosdb_1.0.1_amd64.deb
   sudo dpkg -i cnosdb_1.0.1_amd64.deb
   ```

  启动

   ```shell
   sudo systemctl start cnosdb
   ```

- ### Red Hat & CentOS

  下载

   ```shell
   wget https://github.com/cnosdb/cnosdb/releases/download/v1.0.1/cnosdb-1.0.1.x86_64.rpm
   sudo yum localinstall cnosdb-1.0.1.x86_64.rpm
   ```

  启动

   ```shell
   sudo systemctl start cnosdb
   <<<<<<< Updated upstream
   ```
   =======
   ```

## 源码使用介绍

- ### 构建

  克隆项目

   ```
   git clone https://github.com/cnosdb/cnosdb.git
   ```

  编译

   ```
   go install ./...
   ```

- ### 运行

  启动服务端

   ```bash
   $GOPATH/bin/cnosdb
   ```

  使用客户端

   ```bash
   $GOPATH/bin/cnosdb-cli
   ```

## 入门指南

   **[入门指南](./guide.md)**
