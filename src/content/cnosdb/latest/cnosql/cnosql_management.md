

# CnosQL for Database Management





## SHOW

### SHOW DATABASES Statement

显示数据库的名称

#### Syntax

```sql
SHOW DATABASES
```

#### Examples

```sql
> SHOW DATABASES

name: databases
name
----
oceanic_station
```





### SHOW RETENTION POLICIES Statement

显示retention policies

| 元素          | 说明                 |
| ------------- | -------------------- |
| name          | 名称                 |
| duration      | 持续时间             |
| groupDuration | 组持续时间           |
| replicaN      | 冗余数（默认是1）    |
| default       | 是否是默认的保留策略 |

#### Syntax

```sql
SHOW RETENTION POLICIES
[ON <database_name>]
```

#### Examples

```sql
> SHOW RETENTION POLICIES ON oceanic_station
name    duration groupDuration replicaN default
----    -------- ------------- -------- -------
autogen 0s       168h0m0s      1        true
```

OR

```sql
> use oceanic_station
Using database oceanic_station
Using rp autogen
> SHOW RETENTION POLICIES
name    duration groupDuration replicaN default
----    -------- ------------- -------- -------
autogen 0s       168h0m0s      1        true
```





### SHOW SHARDS Statement

显示shard相关信息，包括id，所属数据库，retention policy以及所在的shard（相对应的开始时间，结束时间和过期时间）

#### Syntax

```sql
SHOW SHARDS
```

#### 例1：显示SHARDS

```sql
> SHOW SHARDS

name: oceanic_station
id database        rp      shard_group start_time           end_time             expiry_time          owners
-- --------        --      ----------- ----------           --------             -----------          ------
4  oceanic_station autogen 2           2021-08-30T00:00:00Z 2021-09-06T00:00:00Z 2021-09-06T00:00:00Z 0
6  oceanic_station autogen 3           2021-09-06T00:00:00Z 2021-09-13T00:00:00Z 2021-09-13T00:00:00Z 0
8  oceanic_station autogen 4           2021-09-13T00:00:00Z 2021-09-20T00:00:00Z 2021-09-20T00:00:00Z 0
10 oceanic_station autogen 5           2021-09-20T00:00:00Z 2021-09-27T00:00:00Z 2021-09-27T00:00:00Z 0
12 oceanic_station autogen 6           2021-09-27T00:00:00Z 2021-10-04T00:00:00Z 2021-10-04T00:00:00Z 0
```





### SHOW SERIES Statement

显示series

#### Syntax

```sql
SHOW SERIES
[ON <database_name>] 
[FROM_clause] 
[WHERE <tag_key> <operator> [ '<tag_value>' | <regular_expression>]]
[LIMIT_clause] 
[OFFSET_clause]
```

#### 例1：显示数据库的索引

```sql
> SHOW SERIES ON oceanic_station
key
---
air,station=LianYunGang
air,station=XiaoMaiDao
sea,station=LianYunGang
sea,station=XiaoMaiDao
wind,station=LianYunGang
wind,station=XiaoMaiDao
```

#### 例2：附加WHERE条件，对返回结果过滤，并限制输出条目数量

```sql
> SHOW SERIES ON oceanic_station FROM "air" WHERE "station" = 'LianYunGang' LIMIT 1
key
---
air,station=LianYunGang
```

#### 例3：通过time对返回结果过滤

```sql
> SHOW SERIES ON oceanic_station WHERE time < now() - 1m
key
---
air,station=LianYunGang
air,station=XiaoMaiDao
sea,station=LianYunGang
sea,station=XiaoMaiDao
wind,station=LianYunGang
wind,station=XiaoMaiDao
```





### SHOW MEASUREMENTS Statement

显示数据库对应的measurements

#### Syntax

```sql
SHOW MEASUREMENTS 
[ON <database_name>]
[WITH MEASUREMENT <operator> ['<measurement_name>' | <regular_expression>]]
[WHERE <tag_key> <operator> ['<tag_value>' | <regular_expression>]] 
[LIMIT_clause]
[OFFSET_clause]
```

用法及注意事项：

- 可用WITH语句附加正则表达式
- 可用WHERE语句对tag_key操作
- 可用LIMIT和OFFSET控制输出

#### 例1：显示measurements

```sql
> SHOW MEASUREMENTS ON oceanic_station
name: measurements
name
----
air
sea
wind
```

OR

```sql
> USE oceanic_station
Using database oceanic_station
Using rp autogen
> SHOW MEASUREMENTS
name: measurements
name
----
air
sea
wind
```

#### 例2：附加正则表达式

```sql
> SHOW MEASUREMENTS ON "oceanic_station" WITH MEASUREMENT =~ /air*/
name: measurements
name
----
air
```



### SHOW TAG KEYS Statement

显示Tag Keys，Tag Keys类似于MySQL中带索引的字段

#### Syntax

```sql
SHOW TAG KEYS
[ON <database_name>] 
[FROM_clause] 
[WHERE <tag_key> <operator> ['<tag_value>' | <regular_expression>]] 
[LIMIT_clause]
[OFFSET_clause]
```

#### 例1：显示Tag Keys

```sql
> SHOW TAG KEYS ON "oceanic_station"
name: air
tagKey
------
station

name: sea
tagKey
------
station

name: wind
tagKey
------
station
```

OR

```sql
> USE oceanic_station
Using database oceanic_station
Using rp autogen
> SHOW TAG KEYS
name: air
tagKey
------
station

name: sea
tagKey
------
station

name: wind
tagKey
------
station
```

#### 例2：显示指定数据库及measurement上的Tag Keys

```sql
> SHOW TAG KEYS ON "oceanic_station" FROM "air" LIMIT 1
name: air
tagKey
------
station
```



### SHOW TAG VALUES Statement

显示Tag Values

#### Syntax

```sql
SHOW TAG VALUES
[ON <database_name>]
[FROM_clause] 
WITH KEY [[<operator> "<tag_key>" | <regular_expression>] | [IN ("<tag_key1>","<tag_key2")]] 
[WHERE <tag_key> <operator> ['<tag_value>' | <regular_expression>]]
[LIMIT_clause]
[OFFSET_clause]
```

#### 例1：指定数据库及Tag Key，显示对应的Tag Values

```sql
>  SHOW TAG VALUES ON "oceanic_station" WITH KEY = "station"
name: air
key     value
---     -----
station LianYunGang
station XiaoMaiDao

name: sea
key     value
---     -----
station LianYunGang
station XiaoMaiDao

name: wind
key     value
---     -----
station LianYunGang
station XiaoMaiDao
```

#### 例2：附加正则表达式

```sql
> SHOW TAG VALUES ON "oceanic_station" WITH KEY IN ("station") WHERE "station" =~ /./ LIMIT 3
name: air
key     value
---     -----
station LianYunGang
station XiaoMaiDao

name: sea
key     value
---     -----
station LianYunGang
station XiaoMaiDao

name: wind
key     value
---     -----
station LianYunGang
station XiaoMaiDao
```



### SHOW FIELD KEYS Statement

显示Field Keys，类似于MySQL中不带索引的字段

#### Syntax

```sql
SHOW FIELD KEYS
[ON <database_name>]
[FROM <measurement_name>]
```

#### 例1：指定数据库，显示Field Keys

```sql
> SHOW FIELD KEYS ON "oceanic_station"
name: air
fieldKey    fieldType
--------    ---------
pressure    float
temperature float
visibility  float

name: sea
fieldKey    fieldType
--------    ---------
temperature float

name: wind
fieldKey  fieldType
--------  ---------
direction float
speed     float
```

OR

```sql
> USE oceanic_station
Using database oceanic_station
Using rp autogen
> SHOW FIELD KEYS
name: air
fieldKey    fieldType
--------    ---------
pressure    float
temperature float
visibility  float

name: sea
fieldKey    fieldType
--------    ---------
temperature float

name: wind
fieldKey  fieldType
--------  ---------
direction float
speed     float
```

#### 例2：指定measurement

```sql
> SHOW FIELD KEYS ON "oceanic_station" FROM "sea"
name: sea
fieldKey    fieldType
--------    ---------
temperature float
```



## DELETE





### DELETE SERIES Statement

从指定的measurement中删除series，可使用Where Clause附加条件

#### Syntax

```sql
DELETE FROM <measurement_name> 
WHERE [<tag_key>='<tag_value>'] | [<time interval>]
```

#### 例1：删除measurement下所有series

```sql
DELETE FROM "air"
```

#### 例2：附加WHERE，对Tag Keys筛选

```sql
DELETE FROM "air" WHERE "station" = 'XiaoMaiDao'
```

#### 例3：附加WHERE，对时间筛选

```sql
DELETE WHERE time < '2021-09-01'
```



## CREATE



### CREATE DATABASE Statement

创建数据库，可附带创建retention policy，如果不指定retention policy，则默认使用"autogen"作为retention policy

#### Syntax

```sql
CREATE DATABASE <database_name>
[WITH
[DURATION <duration>] 
[REPLICATION <n>] 
[SHARD DURATION <duration>] 
[NAME <retention-policy-name>]]
```

#### 例1：创建数据库

```sql
> CREATE DATABASE "cnos"
```

#### 例2：附加自定义的retention policy

```sql
> CREATE DATABASE "cnos" WITH DURATION 1d REPLICATION 1 SHARD DURATION 1h NAME "1d_events"
```



### CREATE RETENTION POLICY Statement

创建retention policy，需指定retention policy的名称，duration，replication以及shard duration，最后可指定当前创建的retention policy是否是该数据库默认的retention policy

#### Syntax

```sql
CREATE RETENTION POLICY <retention_policy_name> 
ON <database_name>
DURATION <duration> 
REPLICATION <n> 
[SHARD DURATION <duration>]
[DEFAULT]
```

#### 例1：创建retention policy

```sql
> CREATE RETENTION POLICY "1d_events" ON "cnos" DURATION 1d REPLICATION 1
```

#### 例2：添加DEFAULT，作为数据库默认retention policy

```sql
> CREATE RETENTION POLICY "1d_events" ON "cnos" DURATION 23h60m REPLICATION 1 DEFAULT
```



## DROP

### DROP DATABASE Statement

删除数据库

#### Syntax

```sql
DROP DATABASE <database_name>
```

#### 例1：删除数据库

```sql
> DROP DATABASE "oceanic_station"
```



### DROP SERIES Statement

删除指定表的索引，可使用Where Clause附加条件

#### Syntax

```sql
DROP SERIES
FROM <measurement_name[,measurement_name]>
WHERE <tag_key>='<tag_value>'
```

#### 例1：指定measurement，删除series

```sql
> DROP SERIES FROM "air"
```



### DROP MEASUREMENT Statement

删除measurement，可使用Where Clause附加条件

#### Syntax

```sql
DROP MEASUREMENT <measurement_name>
```

#### 例1：删除measurement

```sql
> DROP MEASUREMENT "air"
```

#### 例2：附加WHERE Clause，通过Tag Keys筛选需删除的数据

```sql
> DROP SERIES FROM "air" WHERE "station" = 'XiaoMaiDao'
```



### DROP SHARD Statement

根据shard_id删除特定的shard

#### Syntax

```sql
DROP SHARD <shard_id_number>
```

#### 例1：删除SHARD

```sql
> DROP SHARD 1
```



### DROP RETENTION POLICY Statement

删除retention policy

#### Syntax

```sql
DROP RETENTION POLICY <retention_policy_name>
ON <database_name>
```

#### 例1：指定数据库，删除retention policy

```sql
> DROP RETENTION POLICY "1d_events" ON "cnos"
```



## ALTER



### ALTER RETENTION POLICY Statement

修改retention policy，与创建时的语法类似，不再赘述

#### Syntax

```sql
ALTER RETENTION POLICY <retention_policy_name>
ON <database_name> 
DURATION <duration> 
REPLICATION <n> 
SHARD DURATION <duration>
DEFAULT
```

#### 例1：修改retention policy

```sql
> ALTER RETENTION POLICY "1d_events" ON "cnos" DURATION 7 SHARD DURATION 1d DEFAULT
```

