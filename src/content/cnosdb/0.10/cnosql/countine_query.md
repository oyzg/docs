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
