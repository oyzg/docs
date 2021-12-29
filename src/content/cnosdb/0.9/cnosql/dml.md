# DML

| 基础                        | 查询结果限制                              |
| --------------------------- | ----------------------------------------- |
| [INSERT](#insert)           | [ORDER BY time DESC](#order-by-time-desc) |
| [INSERT INTO](#insert-into) | [LIMIT 和 SLIMIT](#limit-和-slimit)       |
| [SELECT](#select)           | [OFFSET 和 SOFFSET](#offset-和-soffset)   |
| [WHERE](#where)             | [时区](#时区)                             |
| [GROUP BY](#group-by)       |                                           |
| [INTO](#into)               |                                           |

## INSERT

**语法**

> 需要在`cnos`中`USE <database>`后执行`INSERT`

```sql
INSERT <measurement_name> <"tag_key1=tag_value1","tag_key2=tag_value2"> <"field_key1=field_value1","field_key2=field_value2"> [timestamp]
```

**示例**

> 以下语句将数据写入到默认保留策略中

```sql
INSERT cpu,host=cnosdb-data-01 usage_idle=87
```

## INSERT INTO

**语法**

> 需要在`cnos`中`USE <database>`后执行`INSERT`

```sql
INSERT INTO <rp> <measurement_name> <"tag_key1=tag_value1","tag_key2=tag_value2"> <"field_key1=field_value1","field_key2=field_value2"> [timestamp]
```

**示例**

> 以下语句将数据写入到保留策略`1d_events`中

```
INSERT INTO 1d_events cpu,host=cnosdb-data-01 usage_idle=87
```

## SELECT

> `SELECT`从一个或多个`measurement`中查询数据

**语法**

```sql
SELECT <field_key>[,<field_key>,<tag_key>] FROM <measurement_name>[,<measurement_name>]
```

**语法描述**

`SELECT`语句需要和`FROM`语句配合使用

`SELECT *`返回所有`tag`和`field`

`SELECT "<field_key>"`返回一个特定的`field`

`SELECT "<field_key>","<field_key>"`返回多个`field`

`SELECT "<field_key>","<tag_key>"`返回特定的`tag`和`field`，当包含标签时，至少指定一个`field`

`SELECT "<field_key>"::field,"<tag_key>"::tag`返回特定的`tag`和`field`，`::[field | tag]`用来区分相同名称的`tag`和`field`

## FROM

> `FROM`支持指定`measurement`的格式

**语法**

```sql
FROM [<database_name>.<rp_name>. | <database_name>..]<measurement_name>,<measurement_name>
```

**语法描述**

`FROM <measurement_name>`返回一个`measurement`中的数据

`FROM <measurement_name>,<measurement_name>`返回多个`measurement`中的数据

`FROM <database_name>.<rp_name>.<measurement_name>`指定数据库、保留策略中返回具体`measurement`中的数据

`FROM <database_name>..<measurement_name>`从指定的数据库的`measurement`中返回数据

**示例**

```sql
SELECT * FROM "cnos"
SELECT "host","region","usage_idle" FROM "cpu"
SELECT "usage_idle"::field,"region"::tag,"usage_idle"::field FROM "cpu"
SELECT *::field FROM "cpu"
SELECT ("usage_idle" * 2) + 4 FROM "cpu"
SELECT * FROM "cpu","disk"
SELECT * FROM "cnos"."autogen"."cpu"
SELECT * FROM "cnos".."cpu"
```

## WHERE

**语法**

```sql
SELECT_clause FROM_clause WHERE <conditional_expression> [(AND|OR) <conditional_expression> [...]]
```

> CnosDB不支持在`WHERE`子句中使用`OR`来指定多个时间范围

**示例**

```sql
SELECT * FROM "cpu" WHERE "usage_idle" > 8
SELECT * FROM "cpu" WHERE "usage_idle" + 2 > 11.9
SELECT "region" FROM "cpu" WHERE "region" = 'Shanghai'
SELECT "location" FROM "cpu" WHERE "region" <> 'Shanghai' AND (usage_idle < -0.59 OR water_level > 9.95)
SELECT * FROM "cpu" WHERE time > now() - 7d
```

## GROUP BY

**语法**

```sql
SELECT_clause FROM_clause [WHERE_clause] GROUP BY [* | <tag_key>[,<tag_key]]
```

**语法描述**

`GROUP BY *`按所有`tag`分组

`GROUP BY <tag_key>`按指定`tag`分组

`GROUP BY <tag_key>,<tag_key>`按多个`tag`分组

**示例**

```sql
SELECT MEAN("usage_idle") FROM "cpu" GROUP BY "host"
SELECT MEAN("usage_idle") FROM "cpu" GROUP BY "host","region"
SELECT MEAN("usage_idle") FROM "cpu" GROUP BY *
```

## 按时间间隔分组

**语法**

```sql
SELECT <function>(<field_key>) FROM_clause WHERE <time_range> GROUP BY time(<time_interval>),[tag_key] [fill(<fill_option>)]
```

**语法描述**

`GROUP BY <time(time_interval)>`按时间分组，支持的单位为：`u`,`ns`,`ms`,`s`,`m`,`h`,`d`

`fill(<fill_option>)`是可选项，可以对缺失值进行填充

**示例**

```sql
SELECT "host","usage_idle" FROM "cpu" WHERE time >= '2020-08-18T00:00:00Z' AND time <= '2020-08-18T00:30:00Z'
SELECT COUNT("usage_idle") FROM "cpu" WHERE "region"='Shanghai' AND time >= '2020-08-18T00:00:00Z' AND time <= '2020-08-18T00:30:00Z' GROUP BY time(12m)
SELECT COUNT("usage_idle") FROM "cpu" WHERE time >= '2020-08-18T00:00:00Z' AND time <= '2020-08-18T00:30:00Z' GROUP BY time(12m),"host"
```

## INTO

**语法**

```sql
SELECT_clause INTO <measurement_name> FROM_clause [WHERE_clause] [GROUP_BY_clause]
```

**示例**

```sql
# 重命名数据库
SELECT * INTO "copy_cnos"."autogen".:MEASUREMENT FROM "cnos"."autogen"./.*/ GROUP BY *
# 将查询结果写入指定measurement
> SELECT "usage_idle" INTO "cnos_copy" FROM "cpu" WHERE "region" = 'Shanghai'
# 下采样数据
SELECT MEAN("usage_idle") INTO "usage_idle_30d" FROM "cpu" WHERE "region" = 'Shanghai' AND time >= '2020-08-18T00:00:00Z' AND time <= '2020-08-18T00:30:00Z' GROUP BY time(12m)
```

## ORDER BY time DESC

**语法**

```sql
SELECT_clause [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] ORDER BY time DESC
```

**语法描述**

如果查询语句中包含`GROUP BY`，那么`ORDER BY time DESC`必须放在`GROUP BY`后面。如果查询语句中包含`WHERE`并且没有`GROUP BY`，那么`ORDER BY time DESC`必须放在`WHERE`后面。

**示例**

```sql
SELECT "usage_idle" FROM "cpu" WHERE "region" = 'Shanghai' ORDER BY time DESC
SELECT MEAN("usage") FROM "cpu" WHERE time >= '2020-08-18T00:00:00Z' AND time <= '2020-08-18T00:42:00Z' GROUP BY time(12m) ORDER BY time DESC
```

## LIMIT 和 SLIMIT

> `LIMIT`和`SLIMIT`分别限制每个查询返回的数据条数和`series`个数。

### LIMIT

**语法**

```sql
SELECT_clause [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] LIMIT <N>
```

**示例**

```sql
SELECT "usage_idle","region" FROM "cpu" LIMIT 3
SELECT MEAN("usage_idle") FROM "cpu" WHERE time >= '2020-08-18T00:00:00Z' AND time <= '2020-08-18T00:42:00Z' GROUP BY *,time(12m) LIMIT 2
```

### SLIMIT

**语法**

```sql
SELECT_clause [INTO_clause] FROM_clause [WHERE_clause] GROUP BY *[,time(<time_interval>)] [ORDER_BY_clause] SLIMIT <N>
```

**示例**

```sql
SELECT "usage_idle" FROM "cpu" GROUP BY * SLIMIT 1
SELECT MEAN("usage_idle") FROM "cpu" WHERE time >= '2020-08-18T00:00:00Z' AND time <= '2020-08-18T00:42:00Z' GROUP BY *,time(12m) SLIMIT 1
```

## OFFSET 和 SOFFSET

> `OFFSET`和`SOFFSET`分别标记数据和`series`返回的位置。

### OFFSET

> `OFFSET <N>`表示从查询结果中的第`N`条数据开始返回。

**语法**

```sql
SELECT_clause [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] LIMIT_clause OFFSET <N> [SLIMIT_clause]
```

**示例**

```sql
SELECT "host","region" FROM "cpu" LIMIT 3 OFFSET 3
SELECT MEAN("usage_idle") FROM "cpu" WHERE time >= '2020-08-18T00:00:00Z' AND time <= '2020-08-18T00:42:00Z' GROUP BY *,time(12m) ORDER BY time DESC LIMIT 2 OFFSET 2 SLIMIT 1
```

### SOFFSET

> `SOFFSET <N>`表示从查询结果中的第`N`个`series`开始返回。

**语法**

```sql
SELECT_clause [INTO_clause] FROM_clause [WHERE_clause] GROUP BY *[,time(time_interval)] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] SLIMIT_clause SOFFSET <N>
```

**示例**

```sql
SELECT "usage_idle" FROM "cpu" GROUP BY * SLIMIT 1 SOFFSET 1
SELECT MEAN("usage_idle") FROM "cpu" WHERE time >= '2020-08-18T00:00:00Z' AND time <= '2020-08-18T00:42:00Z' GROUP BY *,time(12m) ORDER BY time DESC LIMIT 2 OFFSET 2 SLIMIT 1 SOFFSET 1
```

## 时区

> `tz()`子句返回指定时区的UTC偏移量。

**语法**

```sql
SELECT_clause [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause] tz('<time_zone>')
```

**示例**

```
SELECT "usage_idle" FROM "cpu" WHERE "region" = 'Shanghai' AND time >= '2020-08-18T00:00:00Z' AND time <= '2020-08-18T00:18:00Z' tz('Asia/Shanghai')
```
