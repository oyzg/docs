# CnosQL





# CnosDB入门

> 摘要

- [什么是时序数据？](#什么是时序数据)
- [CnosDB简介](#cnosdb简介)
- [快速开始](#快速开始)
- [CnosQL VS SQL](#cnosql-vs-sql)
- [查询入门](#查询入门)

## 什么是时序数据？

时序数据是指时间序列数据。是按**时间顺序**记录的数据列，在同一数据列中的各个数据必须是同口径的，要求具有可比性。

[场景](https://www.cnosdb.com)

[天气](https://weathernew.pae.baidu.com/weathernew/pc?query=%E5%8C%97%E4%BA%AC%E5%A4%A9%E6%B0%94&srcid=4982)

## CnosDB简介

**时序数据库** - 用于处理带时间标签（按照时间的顺序变化，即时间序列化）的数据

**时序数据管理系统** - 主要通过对时序数据的采集、处理和分析帮助企业实时监控企业的生产与经营过程。

- 数据是时序的，一定带有时间戳
- 数据极少有更新操作
- 数据的写入多，读取少
- 用户关注的是一段时间的趋势
- 数据是有保留期限的
- 除了存储查询外，还需要实时的计算操作
- 数据量巨大，每天很容易就会过百亿

## 快速开始

### 使用Docker启动

```bash
docker pull cnosdb/cnosdb:latest
docker run -itd -p 8086:8086 cnosdb/cnosdb:latest
```

### 导入示例数据

> 如何提示`bash: wget: command not found`
>
> 请下载`wget`工具: `apt-get update && apt-get install wget`

```bash
docker ps # 查看运行中的容器

docker exec -it container_id bash # 进入容器

wget https://gist.githubusercontent.com/cnos-db/9839ac8e78e45b0ee50d2803de4acfd8/raw/818b19d0dd3c80befe636b60ee569451ac2ca4b1/oceanic_station

cnosdb-cli import --path oceanic_station # 导入数据到cnosdb

cnosdb-cli

SHOW DATABASES

USE oceanic_station

```

## CnosQL vs SQL

- 时间序列数据在聚合场景中最有用

- CnosDB 中的`measurement`类似于一个 SQL 中的`table`

- CnosDB 中的`tag`就像 SQL 中的一个带索引的列

- CnosDB 中的`field`就像 SQL 中的没有索引的列

- CnosDB`points`类似于 SQL 中的行

- CnosDB 中不需要预定义`schema`

## 查询入门

### 查看所有 `measurements`

    show measurements

### 计算`air`中`temperature`的数量

    SELECT COUNT("temperature") FROM air


### 查看`air`中的前五个值

    SELECT * FROM air LIMIT 5

### 指定字段的标识符号

    SELECT "temperature"::field,"station"::tag,"visibility"::field FROM "air" limit 10

### 查看`measurement`的tag key

    SHOW TAG KEYS FROM air

### 查看tag value

    SHOW TAG VALUES FROM air WITH KEY = "station"

### 查看field key

    SHOW FIELD KEYS FROM air

### 查看series

    SHOW SERIES

### 函数使用

> [更多](https://www.cnosdb.com/content/cnosdb/0.10/cnosql/function.html)

    SELECT MEAN("temperature") FROM "air"


## 课堂问题

1. 时序数据和时序数据库的关系是什么？
2. 写出一条符合CnosDB格式的数据
3. 查询出2022-01-14T00:00:00Z到2022-02-15T00:00:00Z期间在XiaoMaiDao水位最高的一条数据
4. 查询出2022-01-14T00:00:00Z到2022-02-15T00:00:00Z期间LianYunGang每天的平均水温是多少



















# CnosQL语法

# DDL

CnosQL提供了一整套DDL（数据定义语言）

|                                          |        [数据库管理](#数据库管理)         |                                         |
| :--------------------------------------: | :--------------------------------------: | :-------------------------------------: |
|      [CREATE DATABASE](#创建数据库)      |      [SHOW DATABASES](#显示数据库)       |      [DROP DATABASE](#删除数据库)       |
|        [SHOW SERIES](#显示series)        |    [DROP SERIES](#使用drop删除series)    |     [DELETE](#使用delete删除series)     |
|  [SHOW MEASUREMENTS](#显示measurement)   |   [DROP MEASUREMENT](#删除measurement)   |      [SHOW TAG KEYS](#显示tag-key)      |
|    [SHOW TAG VALUES](#显示tag-value)     |    [SHOW FIELD KEYS](#显示field-key)     |        [按时间过滤](#按时间过滤)        |
|         [DROP SHARD](#删除分片)          |                                          |                                         |
|                                          |    [**保留策略管理**](#保留策略管理)     |                                         |
| [CREATE RETENTION POLICY](#创建保留策略) | [SHOW RETENTION POLICIES](#显示保留策略) | [ALTER RETENTION POLICY](#修改保留策略) |
|  [DROP RETENTION POLICY](#删除保留策略)  |                                          |                                         |



## 数据库管理

### 创建数据库

**语法**

```sql
CREATE DATABASE <database_name> [WITH [DURATION <duration>] [REPLICATION <n>] [SHARD DURATION <duration>] [NAME <rp-name>]]
```

**语法描述**

`CREATE DATABASE`需要一个数据库名称，其他都为可选项。如果未在`WITH`后面指定保留策略，则会创建一个默认的保留策略，名称为`autogen。`

`DURATION`保留策略的总窗口时长。

`REPLICATION`副本数量，默认为`1`并且只能为`1`。

`SHARD DURATION`分片的窗口时长。

`NAME`指定保留策略名称。

`CREATE DATABASE`成功执行后不会返回任何结果。

**示例**

创建数据库

> 创建一个名为`cnos`的数据库，CnosDB还会在其下创建一个名为`autogen`的保留策略。

```sql
> CREATE DATABASE "cnos"
>
```

创建数据库并指定保留策略

> 创建一个名为`cnos`的数据库，并指定保留策略为`1d_events`，它的生命周期为总保留时长为一天，副本数为1，每个分片的的窗口长度为一小时。

```sql
> CREATE DATABASE "cnos" WITH DURATION 1d REPLICATION 1 SHARD DURATION 1h NAME "1d_events"
```

### 显示数据库

**语法**

```sql
SHOW DATABASES
```

### 删除数据库

**语法**

```sql
DROP DATABASE <database_name>
```

**语法描述**

`DROP DATABASE`会删除数据库下所有数据。

**示例**

```sql
DROP DATABASE "cnos"
```

## 保留策略管理

### 创建保留策略

**语法**

```sql
CREATE RETENTION POLICY <rp_name> ON <database_name> DURATION <duration> REPLICATION <n> [SHARD DURATION <duration>] [DEFAULT]
```

**描述**

`DURATION`保留策略的总窗口时长。

`REPLICATION`副本数量，默认为`1`并且只能为`1`。

`SHARD DURATION`分片的窗口时长。

`DEFAULT`可选项，指定其是否为默认保留策略

**示例**

创建保留策略

> 该语句创建了一个名为`1d_events`的保留策略，并且副本数为1

```sql
> CREATE RETENTION POLICY "1d_events" ON "cnos" DURATION 1d REPLICATION 1
>
```

创建默认保留策略

```sql
> CREATE RETENTION POLICY "1d_events" ON "cnos" DURATION 23h60m REPLICATION 1 DEFAULT
>
```

### 显示保留策略

**语法**

```sql
SHOW RETENTION POLICIES [ON <database_name>]
```

**示例**

```sql
> SHOW RETENTION POLICIES ON "cnos"

name      duration   shardGroupDuration   replicaN   default
----      --------   ------------------   --------   -------
autogen   0s         168h0m0s             1          true
```

### 修改保留策略

**语法**

```sql
ALTER RETENTION POLICY <rp_name> ON <database_name> DURATION <duration> REPLICATION <n> SHARD DURATION <duration> DEFAULT
```

**示例**

```sql
ALTER RETENTION POLICY "1d_events" ON "cnos" DURATION 7 SHARD DURATION 1d DEFAULT
```

### 删除保留策略

**语法**

```sql
DROP RETENTION POLICY <rp_name> ON <database_name>
```

**示例**

```sql
> DROP RETENTION POLICY "1d_events" ON "cnos"
>
```











# schema查询

### 显示`SERIES`

**语法**

```sql
SHOW SERIES [ON <database_name>] [FROM_clause] [WHERE <tag_key> <operator> [ '<tag_value>' | <regular_expression>]] [LIMIT_clause] [OFFSET_clause]
```

**语法描述**

`SHOW SERIES`后面都是可选项

`[ON <database_name>]`指定数据库名称

`FROM`子句指定`measurement`

`WHERE`子句支持比较`tag`，`field`比较是无效的

**示例**

```sql
SHOW SERIES ON "cnos" WHERE time > now() - 1m LIMIT 10
```



### 使用`DROP`删除`series`

**语法**

```sql
DROP SERIES FROM <measurement_name[,measurement_name]> WHERE <tag_key>='<tag_value>'
```

**语法描述**

`DROP SERIES`会删除数据库中符合条件的所有数据以及数据所对应的索引

**示例**

从一个`measurement`中删除所有`series`

```sql
> DROP SERIES FROM "cpu"
```

从一个`measurement`中删除具有特定条件的`series`

```sql
DROP SERIES FROM "cpu" WHERE "region" = 'Shanghai'
```

### 使用`DELETE`删除`series`

**语法**

```sql
DELETE FROM <measurement_name> WHERE [<tag_key>='<tag_value>'] | [<time interval>]
```

**语法描述**

`DROP SERIES`会删除数据库中符合条件的所有数据，但是不会删除索引，并且支持时间过滤

**示例**

> 删除2020-01-01之前产生的的所有数据

```sql
> DELETE WHERE time < '2021-01-01'
```

### 显示`measurement`

**语法**

```sql
SHOW MEASUREMENTS [ON <database_name>] [WITH MEASUREMENT <operator> ['<measurement_name>' | <regular_expression>]] [WHERE <tag_key> <operator> ['<tag_value>' | <regular_expression>]] [LIMIT_clause] [OFFSET_clause]
```

`SHOW MEASUREMENTS`后面都是可选项

`[ON <database_name>]`指定数据库名称

`FROM`子句指定`measurement`

`WHERE`子句支持比较`tag`，`field`比较是无效的

**示例**

> 该查询返回数据库`cnos`下`tag key`host下的`tag value`的值中包含一个整数

```sql
SHOW MEASUREMENTS ON "cnos" WITH MEASUREMENT =~ /h2o.*/ WHERE "host"  =~ /\d/
```

### 删除`measurement`

**语法**

```sql
DROP MEASUREMENT <measurement_name>
```

**语法描述**

`DROP MEASUREMENT`会删除指定`measurement`下所有的数据

**示例**

```sql
DROP MEASUREMENT "cpu"
```

### 显示`tag key`

**语法**

```sql
SHOW TAG KEYS [ON <database_name>] [FROM_clause] [WHERE <tag_key> <operator> ['<tag_value>' | <regular_expression>]] [LIMIT_clause] [OFFSET_clause]
```

**语法描述**

`SHOW tag keys`后面都是可选项

`[ON <database_name>]`指定数据库名称

`FROM`子句指定`measurement`

`WHERE`子句支持比较`tag`，`field`比较是无效的

**示例**

```sql
SHOW TAG KEYS ON "cnos" FROM "cpu" LIMIT 1 OFFSET 1
```

### 显示`tag value`

**语法**

```sql
SHOW TAG VALUES [ON <database_name>][FROM_clause] WITH KEY [ [<operator> "<tag_key>" | <regular_expression>] | [IN ("<tag_key1>","<tag_key2")]] [WHERE <tag_key> <operator> ['<tag_value>' | <regular_expression>]] [LIMIT_clause] [OFFSET_clause]
```

**语法描述**

`[ON <database_name>]`指定数据库名称

`FROM`子句指定`measurement`

`WHERE`子句支持比较`tag`，`field`比较是无效的

**示例**

```sql
SHOW TAG VALUES ON "cnos" WITH KEY IN ("region","host") WHERE "host" =~ /./ LIMIT 3
```

### 显示`field key`

**语法**

```sql
SHOW FIELD KEYS [ON <database_name>] [FROM <measurement_name>]
```

**语法描述**

`FROM`子句为可选项

**示例**

```sql
SHOW FIELD KEYS ON "cnos" FROM "cpu"
```

### 按时间过滤

> 可以在`SHOW TAG KEYS`、`SHOW TAG VALUES` `SHOW SERIES` `SHOW MEASUREMENTS` `SHOW FIELD KEYS`上使用

**示例**

```sql
SHOW TAG KEYS ON cnos where time > now() -1h and time < now()
```



### 删除分片

**语法**

```sql
DROP SHARD <shard_id_number>
```

**语法描述**

`DROP SHARD`会在磁盘上删除有关分片的所有数据以及元数据

```sql
> DROP SHARD 1
>
```

## 









# 连续查询

| [基本语法](#基本语法)         | [高级语法](#高级语法)         | [管理CQ](#管理CQ) |
| ----------------------------- | ----------------------------- | ----------------- |
| [基本语法示例](#基本语法示例) | [高级语法示例](#高级语法示例) |                   |

## 语法

### 基本语法

```sql
CREATE CONTINUOUS QUERY <cq_name> ON <database_name>
BEGIN
  <cq_query>
END
```

**语法描述**

CQ查询必须包含一个函数，一个`INTO`子句和一个`GROUP BY time()`子句：

```sql
SELECT <function[s]> INTO <destination_measurement> FROM <measurement> [WHERE <stuff>] GROUP BY time(<interval>)[,<tag_key[s]>]
```

> 在`WHERE`子句中，不需要指定时间范围，CQ查询会为语句自动匹配时间范围

### 基本语法示例

以下示例使用数据库`transportation`中的示例数据，`bus_data`中存储的数据是公交车乘客数量和投诉数量的15分钟数：

```sql
name: bus_data
--------------
time                   passengers   complaints
2020-08-28T07:00:00Z   5            9
2020-08-28T07:15:00Z   8            9
2020-08-28T07:30:00Z   8            9
2020-08-28T07:45:00Z   7            9
2020-08-28T08:00:00Z   8            9
2020-08-28T08:15:00Z   15           7
2020-08-28T08:30:00Z   15           7
2020-08-28T08:45:00Z   17           7
2020-08-28T09:00:00Z   20           7
```

**自动采样数据**

使用CQ自动从单个字段下采样数据，并将结果写入到同一个数据库的另一个`measurement`中：

```sql
CREATE CONTINUOUS QUERY "cq_basic" ON "transportation"
BEGIN
  SELECT mean("passengers") INTO "average_passengers" FROM "bus_data" GROUP BY time(1h)
END
```

最终结果如下：

```sql
> SELECT * FROM "average_passengers"
name: average_passengers
------------------------
time                   mean
2020-08-28T07:00:00Z   7
2020-08-28T08:00:00Z   13.75
```

**自动采样数据并将结果保存到另一个保留策略中**

```sql
CREATE CONTINUOUS QUERY "cq_basic_rp" ON "transportation"
BEGIN
  SELECT mean("passengers") INTO "transportation"."three_weeks"."average_passengers" FROM "bus_data" GROUP BY time(1h)
END
```

最终结果如下：

```sql
> SELECT * FROM "transportation"."three_weeks"."average_passengers"
name: average_passengers
------------------------
time                   mean
2020-08-28T07:00:00Z   7
2020-08-28T08:00:00Z   13.75
```

**使用通配符自动下采样数据**

```sql
CREATE CONTINUOUS QUERY "cq_basic_br" ON "transportation"
BEGIN
  SELECT mean(*) INTO "downsampled_transportation"."autogen".:MEASUREMENT FROM /.*/ GROUP BY time(30m),*
END
```

最终结果如下：

```sql
> SELECT * FROM "downsampled_transportation."autogen"."bus_data"
name: bus_data
--------------
time                   mean_complaints   mean_passengers
2020-08-28T07:00:00Z   9                 6.5
2020-08-28T07:30:00Z   9                 7.5
2020-08-28T08:00:00Z   8                 11.5
2020-08-28T08:30:00Z   7                 16
```

**自动采样数据并配置CQ的时间边界**

```sql
CREATE CONTINUOUS QUERY "cq_basic_offset" ON "transportation"
BEGIN
  SELECT mean("passengers") INTO "average_passengers" FROM "bus_data" GROUP BY time(1h,15m)
END
```

最终结果如下：

```sql
> SELECT * FROM "average_passengers"
name: average_passengers
------------------------
time                   mean
2020-08-28T07:15:00Z   7.75
2020-08-28T08:15:00Z   16.75
```

### 高级语法

```sql
CREATE CONTINUOUS QUERY <cq_name> ON <database_name>
RESAMPLE EVERY <interval> FOR <interval>
BEGIN
  <cq_query>
END
```

##### 高级语法示例

示例数据如下：

```sql
name: bus_data
--------------
time                   passengers
2020-08-28T06:30:00Z   2
2020-08-28T06:45:00Z   4
2020-08-28T07:00:00Z   5
2020-08-28T07:15:00Z   8
2020-08-28T07:30:00Z   8
2020-08-28T07:45:00Z   7
2020-08-28T08:00:00Z   8
2020-08-28T08:15:00Z   15
2020-08-28T08:30:00Z   15
2020-08-28T08:45:00Z   17
2020-08-28T09:00:00Z   20
```

**配置时间间隔**

在`RESAMPLE`中使用`EVERY`来指明CQ的执行间隔

```sql
CREATE CONTINUOUS QUERY "cq_advanced_every" ON "transportation"
RESAMPLE EVERY 30m
BEGIN
  SELECT mean("passengers") INTO "average_passengers" FROM "bus_data" GROUP BY time(1h)
END
```

最终结果如下：

```sql
> SELECT * FROM "average_passengers"
name: average_passengers
------------------------
time                   mean
2020-08-28T07:00:00Z   7
2020-08-28T08:00:00Z   13.75
```

**配置CQ的重采样时间范围**

在`RESAMPLE`中使用`FOR`来指明CQ的时间间隔的长度

```sql
CREATE CONTINUOUS QUERY "cq_advanced_for" ON "transportation"
RESAMPLE FOR 1h
BEGIN
  SELECT mean("passengers") INTO "average_passengers" FROM "bus_data" GROUP BY time(30m)
END
```

最终结果如下：

```sql
> SELECT * FROM "average_passengers"
name: average_passengers
------------------------
time                   mean
2020-08-28T07:00:00Z   6.5
2020-08-28T07:30:00Z   7.5
2020-08-28T08:00:00Z   11.5
2020-08-28T08:30:00Z   16
```

**配置执行间隔和CQ时间范围**

在`RESAMPLE`子句中使用`EVERY`和`FOR`来指定CQ的执行间隔和CQ的时间范围长度。

```sql
CREATE CONTINUOUS QUERY "cq_advanced_every_for" ON "transportation"
RESAMPLE EVERY 1h FOR 90m
BEGIN
  SELECT mean("passengers") INTO "average_passengers" FROM "bus_data" GROUP BY time(30m)
END
```

最终结果如下：

```sql
> SELECT * FROM "average_passengers"
name: average_passengers
------------------------
time                   mean
2020-08-28T06:30:00Z   3
2020-08-28T07:00:00Z   6.5
2020-08-28T07:30:00Z   7.5
2020-08-28T08:00:00Z   11.5
2020-08-28T08:30:00Z   16
```

**配置CQ的时间范围并填充空值**

使用`FOR`间隔和`fill()`来更改不含数据的时间间隔值。请注意，至少有一个数据点必须在`fill()`运行的`FOR`间隔内。 如果没有数据落在`FOR`间隔内，则CQ不会将任何数据写入目标`measurement`。

```sql
CREATE CONTINUOUS QUERY "cq_advanced_for_fill" ON "transportation"
RESAMPLE FOR 2h
BEGIN
  SELECT mean("passengers") INTO "average_passengers" FROM "bus_data" GROUP BY time(1h) fill(1000)
END
```

最终结果如下：

```sql
> SELECT * FROM "average_passengers"
name: average_passengers
------------------------
time                   mean
2020-08-28T05:00:00Z   1000
2020-08-28T06:00:00Z   3
2020-08-28T07:00:00Z   7
2020-08-28T08:00:00Z   13.75
2020-08-28T09:00:00Z   20
2020-08-28T10:00:00Z   1000
```

## 管理CQ

> CQ不能`update`，只能`dorp`和`create`

**列出所有CQ**

```sql
SHOW CONTINUOUS QUERIES
```

**删除CQ**

```sql
DROP CONTINUOUS QUERY <cq_name> ON <database_name>
```



