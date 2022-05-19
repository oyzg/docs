# 安装

摘要：本指南介绍如何安装CnosDB

> 历史版本和其他操作系统软件安装包，请访问[Github Releases](https://github.com/cnosdb/cnosdb/releases)

##在Linux安装

### Ubuntu & Debian

1. 使用`wget`命令从官网下载获得deb安装包`cnosdb_0.10.3_amd64.deb`
   ```shell
   wget https://github.com/cnosdb/cnosdb/releases/download/v0.10.3/cnosdb_0.10.3_amd64.deb
   ```
   
2. 进入`cnosdb_0.10.3_amd64.deb`所在目录，使用`dpkg`命令进行安装
   ```shell
   sudo dpkg -i cnosdb_0.10.3_amd64.deb
   ```

3. 安装成功后即可启动，执行以下命令进行启动
   ```shell
   sudo systemctl start cnosdb
   ```
   
    启动后可使用以下命令验证是否启动成功：
    ```
    # sudo systemctl status cnosdb
    ● cnosdb.service - CnosDB is an open-source, disributed, time series database
       Loaded: loaded (/usr/lib/systemd/system/cnosdb.service; enabled; vendor preset: disabled)
       Active: active (running) since Thu 2022-05-19 11:16:59 CST; 1s ago
         Docs: https://www.cnosdb.com
     Main PID: 16942 (cnosdb)
       CGroup: /system.slice/cnosdb.service
               └─16942 /usr/bin/cnosdb --config /etc/cnosdb/cnosdb.conf
    
    May 19 11:16:59 iZ2ze48dce3wds62w0b6vrZ systemd[1]: Started CnosDB is an open-source, disributed, time series database.
    May 19 11:16:59 iZ2ze48dce3wds62w0b6vrZ cnosdb[16942]: [2022/05/19 11:16:59.255 +08:00] [INFO] [run.go:94] ["Loading configuration file"] [path=/etc/cnosdb/cnosdb.conf]
    May 19 11:16:59 iZ2ze48dce3wds62w0b6vrZ cnosdb[16942]: open server: listen: listen tcp 127.0.0.1:8086: bind: address already in use  
    ```    


### Red Hat & CentOS

1. 使用`wget`命令从官网下载获得rpm安装包`cnosdb-0.10.3.x86_64.rpm`
   ```shell
   wget https://github.com/cnosdb/cnosdb/releases/download/v0.10.3/cnosdb-0.10.3.x86_64.rpm
   ```

2. 进入`cnosdb-0.10.3.x86_64.rpm`所在目录，使用`yum`命令进行安装
   ```shell
   sudo yum localinstall cnosdb-0.10.3.x86_64.rpm
   ```


3. 安装成功后即可启动，执行以下命令进行启动
   ```shell
   sudo systemctl start cnosdb
   ```
   启动后可使用以下命令验证是否启动成功：
    ```
    # sudo systemctl status cnosdb
    ● cnosdb.service - CnosDB is an open-source, disributed, time series database
       Loaded: loaded (/usr/lib/systemd/system/cnosdb.service; enabled; vendor preset: disabled)
       Active: active (running) since Thu 2022-05-19 11:16:59 CST; 1s ago
         Docs: https://www.cnosdb.com
     Main PID: 16942 (cnosdb)
       CGroup: /system.slice/cnosdb.service
               └─16942 /usr/bin/cnosdb --config /etc/cnosdb/cnosdb.conf
    
    May 19 11:16:59 iZ2ze48dce3wds62w0b6vrZ systemd[1]: Started CnosDB is an open-source, disributed, time series database.
    May 19 11:16:59 iZ2ze48dce3wds62w0b6vrZ cnosdb[16942]: [2022/05/19 11:16:59.255 +08:00] [INFO] [run.go:94] ["Loading configuration file"] [path=/etc/cnosdb/cnosdb.conf]
    May 19 11:16:59 iZ2ze48dce3wds62w0b6vrZ cnosdb[16942]: open server: listen: listen tcp 127.0.0.1:8086: bind: address already in use  
    ```  

##在Windows安装


1. 从[Github](https://github.com/cnosdb/cnosdb/releases) 下载获得安装包`cnosdb-0.10.3_windows_amd64.zip`
    
2. 进入`cnosdb-0.10.3_windows_amd64.zip`所在目录，并解压

3. 配置环境变量：将解压路径加入到`Path`中

4. 在命令行输入`cnosdb`命令即可运行

## Docker

1. 拉取镜像

    ```shell
    docker pull cnosdb/cnosdb:latest
    ```
    如需其他版本，可在[Docker Hub](https://hub.docker.com/r/cnosdb/cnosdb/tags) 查找指定版本
2. 启动容器

    ```shell
    docker run -itd -p 8086:8086 cnosdb/cnosdb:latest
    ```
   使用以下命令确定该容器已经启动并且在正常运行
    ```shell
    docker ps
    ```
   使用以下命令可进入该容器并执行 bash
   ```shell
   docker exec -it <container name> bash
    ```


## 源码安装
由于CnosDB 1.x 使用Golang进行编写，所以使用源码安装需要配置Go环境，在配置好Go环境后，即可进行安装。
- ### 构建

1. 从[Github](https://github.com/cnosdb/cnosdb/) 克隆项目

   ```
   git clone https://github.com/cnosdb/cnosdb.git
   ```

2. 进入到项目目录下，执行以下命令进行编译

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

## 验证下载二进制文件的真实性（可选）

  为了验证安全性，请按照以下步骤验证您下载的CnosDB的`gpg`签名（大多数系统默认包含`gpg`命令，如果`gpg`不可用，请参阅[Gun主页](https://gnupg.org/download) 获取安装说明。)

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

如果您已成功完成本指南，则您已安装 CnosDB 并准备好连接到您的CnosDB实例并开始插入数据。


