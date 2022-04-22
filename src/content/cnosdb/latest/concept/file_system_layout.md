# 文件系统布局

## CnosDB 文件结构

### Data 目录

  CnosDB存储时间序列数据(TSM文件)的目录路径。要定制此路径，请使用`[data].dir`配置选项。

### WAL 目录

  CnosDB存放WAL(Write Ahead Log 预写日志)文件的目录路径。要定制此路径，请使用`[data].wal-dir`配置选项。

### Meta 目录

  CnosDB存放meta文件的目录路径，存储有关用户、数据库、保留策略、分片和连续查询的信息。要定制此路径，请使用`[meta].dir`配置选项。

## 文件布局
  - [macOS](####macOS)
  - [Linux](####Linux)
  - [Windows](####Windows)
  - [Docker](####Docker)
  - [Kubernetes](####Kubernetes)

### macOS

macOs默认目录

|          路径           |       默认路径        |
|:---------------------:|:-----------------:|
|    Data directory     | 	~/.cnosdb/data/  |
|    Meta directory     | 	~/.cnosdb/mata/  |
|     WAL directory     | 	~/.cnosdb/wal/   |

macOS 文件系统概述

              ~/.cnosdb/
                ├──data
                │  └──TSM目录和文件
                ├──wal
                │  └──WAL目录和文件
                └──meta
                   └──meta.db

### Linux
在Linux上安装CnosDB时，您可以下载并安装cnosdb二进制文件，也可以以包的形式安装。使用的安装方法决定了文件系统的布局。

Linux 默认目录 (以独立的二进制文件形式安装)

|          路径           |       默认路径        |
|:---------------------:|:-----------------:|
|    Data directory     | 	~/.cnosdb/data/  |
|    Meta directory     | 	~/.cnosdb/mata/  |
|     WAL directory     | 	~/.cnosdb/wal/   |

Linux 文件系统概述 (以独立的二进制文件形式安装)

              ~/.cnosdb/
                ├──data
                │  └──TSM目录和文件
                ├──wal
                │  └──WAL目录和文件
                └──meta
                   └──meta.db

Linux 默认目录 (以包的形式安装)

|       路径       |          默认路径           |
|:--------------:|:-----------------------:|
| Data directory | 	 /var/lib/cnosdb/data/ |
| Meta directory |  /var/lib/cnosdb/meta/  |
| WAL directory  |  /var/lib/cnosdb/wal/   |
|    默认配置文件路径    | /etc/cnosdb/cnosdb.conf |

Linux 文件系统概述 (以包的形式安装)

              /var/lib/cnosdb/
                ├──data
                │  └──TSM目录和文件
                ├──wal
                │  └──WAL目录和文件
                └──meta
                   └──meta.db
    
              /etc/cnosdb/
                └──cnosdb.conf

### Windows

Windows 默认目录

|          路径           |                    默认路径                    |
|:---------------------:|:------------------------------------------:|
|    Data directory     |       %USERPROFILE% \ .cnosdb\data\        |
|    Meta directory     |       %USERPROFILE% \ .cnosdb\meta\        |
|     WAL directory     |       %USERPROFILE% \ .cnosdb\meta\        |

Windows 文件系统概述

              %USERPROFILE% \ .cnosdb\
                ├──data
                │  └──TSM目录和文件
                ├──wal
                │  └──WAL目录和文件
                └──meta
                   └──meta.db

### Docker

Docker 默认目录

|       路径       |         默认路径          |
|:--------------:|:---------------------:|
| Data directory | /var/lib/cnosdb/data/ |
| Meta directory | /var/lib/cnosdb/meta/ |
| WAL directory  | /var/lib/cnosdb/wal/  |

Docker 文件系统概述

              /var/lib/cnosdb/
                ├──data
                │  └──TSM目录和文件
                ├──wal
                │  └──WAL目录和文件
                └──meta
                   └──meta.db

### kubernetes

Kubernetes 默认目录

|       路径       |         默认路径          |
|:--------------:|:---------------------:|
| Data directory | /var/lib/cnosdb/data/ |
| Meta directory | /var/lib/cnosdb/meta/ |
| WAL directory  | /var/lib/cnosdb/wal/  |

Kubernetes 文件系统概述

              /var/lib/cnosdb/
                ├──data
                │  └──TSM目录和文件
                ├──wal
                │  └──WAL目录和文件
                └──meta
                   └──meta.db
