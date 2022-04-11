# 集群版简介

## 介绍

CnosDB由两组软件组成，`data`节点和`meta`节点，集群内的通讯如下所示：

`meta`节点使用`tcp`和`raft`协议进行通信，`meta`节点之间使用默认端口`8091`通信，多个`meta`节点需要互相能够访问，用来维持`meta`集群的一致性。同时`8091`端口也用来和外界通信，比如`cnosd-ctl`或`data`节点等。

`data`节点通过`tcp`的8088端口互相通信，并且通过`8091`访问`meta`节点的API，使状态保持同步。

`meta`节点数量必须为大于等于3的奇数，这样可以保证集群能够保持选举稳定。

## 安装

> 配置文件的`hostname`需要其他的`meta node`和`data node`节点都能够访问\
> 配置文件可以通过`cnosdb-meta config > config_path`获得

### 启动`meta`节点

```
./cnosdb-meta --config [cnosdb_meta_config_path]
```

### 将`meta`加入到集群

> 添加完后会提示：Added meta node x at cnosdb-meta-0x:8091

```
cnosdb-ctl --bind cnosdb-meta-01:8091 add-meta cnosdb-meta-01:8091
cnosdb-ctl --bind cnosdb-meta-01:8091 add-meta cnosdb-meta-02:8091
cnosdb-ctl --bind cnosdb-meta-01:8091 add-meta cnosdb-meta-03:8091
```

3个节点都添加完输入`cnosdb-ctl show`查看集群状态

```
Data Nodes:
==========


Meta Nodes:
==========

1      cnosdb-meta-01:8091
2      cnosdb-meta-02:8091
3      cnosdb-meta-03:8091
```

请注意，一但没有出现3个节点，不要进行下一步。

### 启动`data`节点

> 启动前将配置文件中的`cluster`改为`true`

```
 cnosdb --config [cnosdb_config_path]
```

### 将`data`节点加入到集群

> 添加完后会提示：Added data node x at cnosdb-data-0x:8088

```
cnosdb-ctl --bind cnosdb-data-01:8091 add-data cnosdb-data-01:8088
cnosdb-ctl --bind cnosdb-data-01:8091 add-data cnosdb-data-02:8088
```

2个节点都添加完输入`cnosdb-ctl show`查看集群状态

```
Data Nodes:
==========

4      cnosdb-data-01:8088
5      cnosdb-data-02:8088
Meta Nodes:
==========

1      cnosdb-meta-01:8091
2      cnosdb-meta-02:8091
3      cnosdb-meta-03:8091
```
## Distributed-sandbox

可以使用`Distributed-sandbox`工具快速生产分布式集群

## 要求

本地上要有`Docker`

## 快速开始

### 克隆项目

```
git clone https://github.com/IvanGao01/distributed-sandbox.git
```
### 运行

```
docker-compose up -d
chmod 777 cluster.sh
./cluster.sh
```

运行成功后可看到如下结果

```
Joining meta nodes to cluster...
Added meta node 1 at cnosdb-meta-01:8091
Added meta node 2 at cnosdb-meta-02:8091
Added meta node 3 at cnosdb-meta-03:8091
Data Nodes:
==========
4      cnosdb-data-01:8088
5      cnosdb-data-02:8088

Meta Nodes:
==========
1      cnosdb-meta-01:8091
2      cnosdb-meta-02:8091
3      cnosdb-meta-03:8091

Joining data nodes to cluster...
EOF
EOF
Cluster successfully created
Data Nodes:
==========
4      cnosdb-data-01:8088
5      cnosdb-data-02:8088

Meta Nodes:
==========
1      cnosdb-meta-01:8091
2      cnosdb-meta-02:8091
3      cnosdb-meta-03:8091
```
