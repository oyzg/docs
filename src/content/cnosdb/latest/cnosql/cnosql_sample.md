## 示例数据

为了进一步学习CnosQL，本节将提供示例数据供您下载，并教您如何将数据导入数据库。后面章节中引用的数据源都来自此示例数据。

### 下载数据

执行以下命令将在本地生成一个名称为`oceanic_station`的[Line Protocol](../protocol/line_protocol.md)格式的数据文件
```shell
wget https://gist.githubusercontent.com/cnos-db/9839ac8e78e45b0ee50d2803de4acfd8/raw/818b19d0dd3c80befe636b60ee569451ac2ca4b1/oceanic_station
```

### 导入数据

通过命令行将数据导入CnosDB
```shell
cnosdb-cli import --path oceanic_station
```
会在CnosDB中生成一个名称为`oceanic_station`的数据库

```shell
> SHOW DATABASES
name: databases
name
----
oceanic_station
```

### 数据来源说明

示例数据（oceanic_station）是[中国海洋观测站](http://mds.nmdis.org.cn/pages/dataViewDetail.html?dataSetId=4-1)的公开数据，数据包括在2022年1月14日到4月15日期间，在两个站点XiaoMaiDao和LianYunGang上收集到的海洋观测值，这些数据每3分钟收集一次，总共87360条观测值。 请注意，air、sea、wind中包含虚拟数据，这些数据用于阐述CnosDB中的查询功能。
