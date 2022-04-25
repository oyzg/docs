# 安装

> 历史版本和其他操作系统软件安装包，请访问[Github Releases](https://github.com/cnosdb/cnosdb/releases)

## Docker

1. 拉取镜像

    ```shell
    docker pull cnosdb/cnosdb:latest
    ```

2. 启动容器

    ```shell
    docker run -itd -p 8086:8086 cnosdb/cnosdb:latest
    ```

## Ubuntu & Debian

1. 下载
   ```shell
   wget https://github.com/cnosdb/cnosdb/releases/download/v0.10.3/cnosdb_0.10.3_amd64.deb
   sudo dpkg -i cnosdb_0.10.3_amd64.deb
   ```

2. 启动
   ```shell
   sudo systemctl start cnosdb
   ```

## Red Hat & CentOS

1. 下载
   ```shell
   wget https://github.com/cnosdb/cnosdb/releases/download/v0.10.3/cnosdb-0.10.3.x86_64.rpm
   sudo yum localinstall cnosdb-0.10.3.x86_64.rpm
   ```
2. 启动
   ```shell
   sudo systemctl start cnosdb
   ```

## 验证下载二进制文件的真实性（可选）

  为了验证安全性，请按照以下步骤验证您下载的CnosDB的`gpg`签名（大多数系统默认包含`gpg`命令，如果`gpg`不可用，请参阅[Gun主页](https://gnupg.org/download)获取安装说明。

   1. 下载并导入CnosDB公钥

   ```
   curl -s https://www.cnosdb.com/cnosdb.key | gpg --import
   ```

   2. 通过在URL上添加`.asc`来下载指定版本的签名文件

   ```shell
    wget https://github.com/cnosdb/cnosdb/releases/download/v0.10.3/cnosdb-0.10.3_linux_amd64.tar.gz
   ```

   3. 验证签名 `gpg --verify`

   ```shell
    gpg --verify cnosdb-0.10.3_linux_amd64.tar.gz.asc cnosdb-0.10.3_linux_amd64.tar.gz
   ```

  此命令应该输出：

   ```shell
   gpg: Good signature from "CnosDB <contact@cnosdb.com>" [unknown]
   ```


