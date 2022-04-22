## schema查询

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
  SHOW SERIES ON "oceanic_station" WHERE time > now() - 1m LIMIT 10
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
  > DROP SERIES FROM "oceanic_station"
  ```

从一个`measurement`中删除具有特定条件的`series`

  ```sql
  DROP SERIES FROM "oceanic_station" WHERE "station" = 'XiaoMaiDao'
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

> 该查询返回数据库`oceanic_station`下`tag key`   oceanic_station下满足正则表达式air*的一个measurement

  ```sql
  SHOW MEASUREMENTS ON "oceanic_station" WITH MEASUREMENT =~ /air*/
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
  DROP MEASUREMENT "air"
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
  SHOW TAG KEYS ON "oceanic_station" FROM "air" LIMIT 1 OFFSET 1
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
  SHOW TAG VALUES ON "oceanic_station" WITH KEY IN ("station")
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
  SHOW FIELD KEYS ON "oceanic_station" FROM "air"
  ```

### 按时间过滤

可以在`SHOW TAG KEYS`、`SHOW TAG VALUES` `SHOW SERIES` `SHOW MEASUREMENTS` `SHOW FIELD KEYS`上使用

**示例**

  ```sql
  SHOW TAG KEYS ON "oceanic_station" where time > now() -1h and time < now()
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
