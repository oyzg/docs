# 连续查询



> 注意：以下将连续查询（Continuous Queries）简称为CQ




- [基本语法示例](#基本语法示例)

- [高级语法示例](#高级语法示例)

- [管理CQ](#管理cq)



 ### 语法

  #### 基本语法

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

  #### 基本语法示例

  以下示例使用数据库`transportation`中的示例数据，`bus_data`中存储的数据是公交车乘客数量和投诉数量的15分钟数：


```sql
name: air
time                 pressure station     temperature visibility
----                 -------- -------     ----------- ----------
2021-08-31T16:00:00Z 78       LianYunGang 63          71
2021-08-31T16:00:00Z 75       XiaoMaiDao  79          68
2021-08-31T16:03:00Z 50       LianYunGang 52          53
2021-08-31T16:03:00Z 73       XiaoMaiDao  70          55
2021-08-31T16:06:00Z 60       LianYunGang 52          75
2021-08-31T16:06:00Z 58       XiaoMaiDao  77          79
2021-08-31T16:09:00Z 58       LianYunGang 73          65
2021-08-31T16:09:00Z 63       XiaoMaiDao  54          70
2021-08-31T16:12:00Z 50       LianYunGang 73          69
2021-08-31T16:12:00Z 73       XiaoMaiDao  77          63
...
```
  **自动采样数据**

  使用CQ自动从单个字段下采样数据，并将结果写入到同一个数据库的另一个`measurement`中：


  ```sql
  CREATE CONTINUOUS QUERY "cq_basic" ON "oceanic_station"
  BEGIN
    SELECT mean("temperature") INTO "average_air_temperatures" FROM "air" GROUP BY time(1h)
  END
  ```

  最终结果如下：

```sql
  > SELECT * FROM "average_air_temperatures"
name: average_air_temperatures
time                 mean
----                 ----
2021-08-31T16:00:00Z 63.65
2021-08-31T17:00:00Z 63.3
2021-08-31T18:00:00Z 65.65
2021-08-31T19:00:00Z 61.425
2021-08-31T20:00:00Z 65.775
2021-08-31T21:00:00Z 64.45
2021-08-31T22:00:00Z 65.1
2021-08-31T23:00:00Z 64.95
2021-09-01T00:00:00Z 63.525
2021-09-01T01:00:00Z 66.125
...
```

  **自动采样数据并将结果保存到另一个保留策略中**

  ```sql
  CREATE CONTINUOUS QUERY "cq_basic_rp" ON "oceanic_station"
  BEGIN
    SELECT mean("temperature") INTO "oceanic_station"."one_year"."average_air_temperatures_1year" FROM "air" GROUP BY time(1h)
  END
  ```

  最终结果如下：

  ```sql
  > SELECT * FROM "oceanic_station"."one_year"."average_air_temperatures_1year"
name: average_air_temperatures_1year
time                 mean
----                 ----
2021-08-31T16:00:00Z 63.65
2021-08-31T17:00:00Z 63.3
2021-08-31T18:00:00Z 65.65
2021-08-31T19:00:00Z 61.425
2021-08-31T20:00:00Z 65.775
...
  ```

  **使用通配符自动下采样数据**

  ```sql
  CREATE CONTINUOUS QUERY "cq_basic_br" ON "oceanic_station"
  BEGIN
    SELECT mean(*) INTO "downsampled_oceanic"."autogen".:MEASUREMENT FROM /.*/ GROUP BY time(168h),*
  END
  ```

  最终结果如下：

  ```sql
> SELECT * FROM "downsampled_oceanic"."autogen"."air"
name: air
time                 mean_pressure     mean_temperature  mean_visibility   station
----                 -------------     ----------------  ---------------   -------
2021-08-26T00:00:00Z 64.5890625        64.4625           64.575            LianYunGang
2021-08-26T00:00:00Z 65.2546875        64.4765625        64.7109375        XiaoMaiDao
2021-09-02T00:00:00Z 65.06517857142858 64.80208333333333 65.0014880952381  LianYunGang
2021-09-02T00:00:00Z 64.86964285714286 64.93988095238095 64.93690476190476 XiaoMaiDao
2021-09-09T00:00:00Z 65.02410714285715 65.13988095238095 65.05684523809524 LianYunGang
2021-09-09T00:00:00Z 65.06607142857143 64.99732142857142 64.91964285714286 XiaoMaiDao
2021-09-16T00:00:00Z 65.13690476190476 64.99464285714286 65.08660714285715 LianYunGang
2021-09-16T00:00:00Z 65.13660714285714 65.09285714285714 64.95446428571428 XiaoMaiDao
2021-09-23T00:00:00Z 64.76636904761905 65.04642857142858 65.01726190476191 LianYunGang
2021-09-23T00:00:00Z 65.03333333333333 64.77708333333334 64.8202380952381  XiaoMaiDao
2021-09-30T00:00:00Z 64.1358024691358  65.01234567901234 64.20987654320987 LianYunGang
2021-09-30T00:00:00Z 64.54320987654322 64.35802469135803 65.06172839506173 XiaoMaiDao
  ```

  **自动采样数据并配置CQ的时间边界**

  ```sql
  CREATE CONTINUOUS QUERY "cq_basic_offset" ON "oceanic_station"
  BEGIN
    SELECT mean("temperature") INTO "average_air_temperatures_offset" FROM "air" GROUP BY time(1h,15m)
  END
  ```

  最终结果如下：

```sql
name: average_air_temperatures_offset
time                 mean
----                 ----
2021-08-26T00:03:00Z 64.47581903276131
2021-09-02T00:03:00Z 64.87008928571429
2021-09-09T00:03:00Z 65.06755952380952
2021-09-16T00:03:00Z 65.04315476190476
2021-09-23T00:03:00Z 64.9110119047619
2021-09-30T00:03:00Z 64.775
```


  #### 高级语法

  ```sql
  CREATE CONTINUOUS QUERY <cq_name> ON <database_name>
  RESAMPLE EVERY <interval> FOR <interval>
  BEGIN
    <cq_query>
  END
  ```

  #### 高级语法示例

  示例数据如下：

```sql
name: sea
time                 station     temperature
----                 -------     -----------
2021-08-31T16:00:00Z LianYunGang 55
2021-08-31T16:00:00Z XiaoMaiDao  50
2021-08-31T16:03:00Z LianYunGang 59
2021-08-31T16:03:00Z XiaoMaiDao  64
2021-08-31T16:06:00Z LianYunGang 71
2021-08-31T16:06:00Z XiaoMaiDao  60
2021-08-31T16:09:00Z LianYunGang 60
2021-08-31T16:09:00Z XiaoMaiDao  62
2021-08-31T16:12:00Z LianYunGang 62
2021-08-31T16:12:00Z XiaoMaiDao  65
...
```

  **配置时间间隔**

  在`RESAMPLE`中使用`EVERY`来指明CQ的执行间隔

  ```sql
  CREATE CONTINUOUS QUERY "cq_advanced_every" ON "oceanic_station"
  RESAMPLE EVERY 30m
  BEGIN
    SELECT mean("temperature") INTO "average_sea_temperatures" FROM "sea" GROUP BY time(1h)
  END
  ```

  最终结果如下：

```sql
name: average_sea_temperatures
time                 mean
----                 ----
2021-08-31T16:00:00Z 63.025
2021-08-31T17:00:00Z 63.975
2021-08-31T18:00:00Z 64.45
2021-08-31T19:00:00Z 64.025
2021-08-31T20:00:00Z 64.55
2021-08-31T21:00:00Z 63.075
2021-08-31T22:00:00Z 66.15
2021-08-31T23:00:00Z 64.625
2021-09-01T00:00:00Z 63.025
2021-09-01T01:00:00Z 67.75
...
```

  **配置CQ的重采样时间范围**

  在`RESAMPLE`中使用`FOR`来指明CQ的时间间隔的长度

  ```sql
  CREATE CONTINUOUS QUERY "cq_advanced_for" ON "oceanic_station"
  RESAMPLE FOR 1h
  BEGIN
    SELECT mean("temperature") INTO "average_sea_temperatures" FROM "sea" GROUP BY time(30m)
  END
  ```

  最终结果如下：

```sql
name: average_sea_temperatures
time                 mean
----                 ----
2021-08-31T16:00:00Z 62.6
2021-08-31T16:30:00Z 63.45
2021-08-31T17:00:00Z 65.85
2021-08-31T17:30:00Z 62.1
2021-08-31T18:00:00Z 64.45
2021-08-31T18:30:00Z 64.45
2021-08-31T19:00:00Z 64.45
2021-08-31T19:30:00Z 63.6
2021-08-31T20:00:00Z 65.8
2021-08-31T20:30:00Z 63.3
...
```

  **配置执行间隔和CQ时间范围**

  在`RESAMPLE`子句中使用`EVERY`和`FOR`来指定CQ的执行间隔和CQ的时间范围长度。

  ```sql
  CREATE CONTINUOUS QUERY "cq_advanced_every_for" ON "oceanic_station"
  RESAMPLE EVERY 1h FOR 90m
  BEGIN
    SELECT mean("temperature") INTO "average_sea_temperatures" FROM "sea" GROUP BY time(90m)
  END
  ```

  最终结果如下：

```sql
name: average_sea_temperatures
time                 mean
----                 ----
2021-08-31T15:00:00Z 62.6
2021-08-31T16:00:00Z 62.6
2021-08-31T16:30:00Z 63.8
2021-08-31T17:00:00Z 65.85
2021-08-31T17:30:00Z 62.1
2021-08-31T18:00:00Z 64.45
2021-08-31T18:30:00Z 64.45
2021-08-31T19:00:00Z 64.45
2021-08-31T19:30:00Z 64.23333333333333
2021-08-31T20:00:00Z 65.8
...
```

  **配置CQ的时间范围并填充空值**

  使用`FOR`间隔和`fill()`来更改不含数据的时间间隔值。请注意，至少有一个数据点必须在`fill()`运行的`FOR`间隔内。 如果没有数据落在`FOR`间隔内，则CQ不会将任何数据写入目标`measurement`。

  ```sql
  CREATE CONTINUOUS QUERY "cq_advanced_for_fill" ON "oceanic_station"
  RESAMPLE FOR 2h
  BEGIN
    SELECT mean("temperature") INTO "average_sea_temperatures" FROM "sea" GROUP BY time(1h) fill(1000)
  END
  ```

  最终结果如下：

```sql
...
2021-09-30T01:30:00Z 64.35
2021-09-30T02:00:00Z 63.8
2021-09-30T02:30:00Z 64.95
2021-09-30T03:00:00Z 67.225
2021-09-30T03:30:00Z 66.75
2021-09-30T04:00:00Z 54
2021-09-30T05:00:00Z 1000
2021-09-30T06:00:00Z 1000
2021-09-30T07:00:00Z 1000
2021-09-30T08:00:00Z 1000
2021-09-30T09:00:00Z 1000
...
```

 ### 管理CQ

  > CQ不能`update`，只能`drop`和`create`

  **列出所有CQ**

  ```sql
  SHOW CONTINUOUS QUERIES
  ```

  **删除CQ**

  ```sql
  DROP CONTINUOUS QUERY <cq_name> ON <database_name>
  ```