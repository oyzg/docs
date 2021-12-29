# DDL

CnosQL提供了一整套DDL（数据定义语言）

|                                          |        [数据库管理](#数据库管理)         |                                         |
| :--------------------------------------: | :--------------------------------------: | :-------------------------------------: |
|      [CRAETE DATABASE](#创建数据库)      |      [SHOW DATABASES](#显示数据库)       |      [DROP DATABASE](#删除数据库)       |
|        [SHOW SERIES](#显示series)        |    [DROP SERIES](#使用drop删除series)    |     [DELETE](#使用delete删除series)     |
|  [SHOW MEASUREMENTS](#显示measurement)   |   [DROP MEASUREMENT](#删除measurement)   |      [SHOW TAG KEYS](#显示tag-key)      |
|    [SHOW TAG VALUES](#显示tag-value)     |    [SHOW FIELD KEYS](#显示field-key)     |        [按时间过滤](#按时间过滤)        |
|         [DROP SHARD](#删除分片)          |                                          |                                         |
|                                          |    [**保留策略管理**](#保留策略管理)     |                                         |
| [CRAETE RETENTION POLICY](#创建保留策略) | [SHOW RETENTION POLICIES](#显示保留策略) | [ALTER RETENTION POLICY](#修改保留策略) |
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
