# 安装

摘要：本指南介绍如何安装CnosDB

> 历史版本和其他操作系统软件安装包，请访问[GitHub Releases](https://github.com/cnosdb/cnosdb/releases)


## Ubuntu & Debian

1. 使用`wget`命令从官网下载获得deb安装包`cnosdb_1.0.1_amd64.deb`
   ```shell
   wget https://github.com/cnosdb/cnosdb/releases/download/v1.0.1/cnosdb_1.0.1_amd64.deb
   ```
   
2. 进入`cnosdb_1.0.1_amd64.deb`所在目录，使用`dpkg`命令进行安装
   ```shell
   sudo dpkg -i cnosdb_1.0.1_amd64.deb
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


## Red Hat & CentOS

1. 使用`wget`命令从官网下载获得rpm安装包`cnosdb-1.0.1.x86_64.rpm`
   ```shell
   wget https://github.com/cnosdb/cnosdb/releases/download/v1.0.1/cnosdb-1.0.1.x86_64.rpm
   ```

2. 进入`cnosdb-1.0.1.x86_64.rpm`所在目录，使用`yum`命令进行安装
   ```shell
   sudo yum localinstall cnosdb-1.0.1.x86_64.rpm
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

## 在Windows安装
> 以下命令请使用Windows PowerShell执行
1. 下载安装包
   ```shell
   wget https://github.com/cnosdb/cnosdb/releases/download/v1.0.1/cnosdb-1.0.1_windows_amd64.zip -UseBasicParsing -OutFile cnosdb-1.0.1_windows_amd64.zip
   ```
2. 解压并安装
   ```shell
   Expand-Archive .\cnosdb-1.0.1_windows_amd64.zip -DestinationPath 'C:\Program Files\cnosdb\'
   ```

3. 将配置到环境变量
   先查看目录上一步的解压目录
   ```shell
   PS C:\Users\Administrator> ls  'C:\Program Files\cnosdb\'


    目录: C:\Program Files\cnosdb


   Mode                 LastWriteTime         Length Name
   ----                 -------------         ------ ----
   d-----         2022/5/19     15:58                cnosdb-1.0.1-1
   ```
4. 将安装目录配置到环境变量
   
   ```shell
   setx PATH "%PATH%;C:\Program Files\cnosdb\cnosdb-1.0.1-1\"
   ```

5. 打开Windows中的命令提示符程序，执行以下命令(这里不再PowerShell中执行)
   ```shell
   cnosdb
   ```
   将返回以下内容：
   ```shell
   C:\Users\Administrator>cnosdb
   [2022-05-19T16:11:00.252173+08:00] [INFO] [run.go:81] ["No configuration provided, using default settings"] [log_id=0aYqlV70000]
   [2022-05-19T16:11:00.262211+08:00] [INFO] [store.go:214] ["Using data dir"] [log_id=0aYqlV7l000] [service=store] [path="C:\Users\Administrator\.cnosdb\data"]
   [2022-05-19T16:11:00.262211+08:00] [INFO] [store.go:287] ["Compaction settings"] [log_id=0aYqlV7l000] [service=store] [max_concurrent_compactions=3] [throughput_bytes_per_second=50331648] [throughput_bytes_per_second_burst=50331648]
   [2022-05-19T16:11:00.262211+08:00] [INFO] [fields.go:108] ["Open store (start)"] [log_id=0aYqlV7l000] [service=store] [trace_id=0aYqlV9W000] [op_name=tsdb_open] [op_event=start]
   [2022-05-19T16:11:00.262211+08:00] [INFO] [fields.go:110] ["Open store (end)"] [log_id=0aYqlV7l000] [service=store] [trace_id=0aYqlV9W000] [op_name=tsdb_open] [op_event=end] [op_elapsed=0.000ms]
   [2022-05-19T16:11:00.263212+08:00] [INFO] [http_handler.go:241] ["opened HTTP access log"] [log_id=0aYqlV7l000] [path=stderr]
   [2022-05-19T16:11:00.263850+08:00] [INFO] [service.go:76] ["Starting cluster service"] [log_id=0aYqlV7l000] [service=coordinator]
   [2022-05-19T16:11:00.263850+08:00] [INFO] [service.go:68] ["Starting snapshot service"] [log_id=0aYqlV7l000] [service=snapshot]
   [2022-05-19T16:11:00.263850+08:00] [INFO] [service.go:121] ["Starting continuous query service"] [log_id=0aYqlV7l000] [service=continuous_querier]
   ```

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


## 验证下载二进制文件的真实性（可选）

  为了验证安全性，请按照以下步骤验证您下载的CnosDB的`gpg`签名（大多数系统默认包含`gpg`命令，如果`gpg`不可用，请参阅[Gun主页](https://gnupg.org/download) 获取安装说明。)

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

如果您已成功完成本指南，则您已安装 CnosDB 并准备好连接到您的CnosDB实例并开始插入数据。
