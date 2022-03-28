# 安装

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
   wget https://github.com/cnosdb/cnosdb/releases/download/v0.10.2/cnosdb_0.10.2_amd64.deb
   sudo dpkg -i cnosdb_0.10.2_amd64.deb
   ```

2. 启动
   ```shell
   sudo systemctl start cnosdb
   ```

## Red Hat & CentOS

1. 下载
   ```shell
   wget https://github.com/cnosdb/cnosdb/releases/download/v0.10.2/cnosdb-0.10.2.x86_64.rpm
   sudo yum localinstall cnosdb-0.10.2.x86_64.rpm
   ```
2. 启动
   ```shell
   sudo systemctl start cnosdb
   ```