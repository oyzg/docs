## CnosQL函数

- ### 目录

  * [聚合函数](#聚合函数)
    * [COUNT()](#count)
    * [DISTINCT()](#distinct)
    * [INTEGRAL()](#integral)
    * [MEAN()](#mean)
    * [MEDIAN()](#median)
    * [MODE()](#mode)
    * [SPREAD()](#spread)
    * [STDDEV()](#stddev)
    * [SUM()](#sum)
    * [选择函数](#选择函数)
      * [BOTTOM()](#bottom)
      * [FIRST()](#first)
      * [LAST()](#last)
      * [MAX()](#max)
      * [MIN()](#min)
      * [PERCENTILE()](#percentile)
      * [SAMPLE()](#sample)
      * [TOP()](#top)
    * [转换函数](#转换函数)
      * [ABS()](#abs)
      * [ACOS()](#acos)
      * [ASIN()](#asin)
      * [ATAN()](#atan)
      * [ATAN2()](#atan2)
      * [CEIL()](#ceil)
      * [COS()](#cos)
      * [CUMULATIVE_SUM()](#cumulative-sum)
      * [DERIVATIVE()](#derivative)
      * [DIFFERENCE()](#difference)
      * [ELAPSED()](#elapsed)
      * [EXP()](#exp)
      * [FLOOR()](#floor)
      * [HISTOGRAM()](#histogram)
      * [LN()](#ln)
      * [LOG()](#log)
      * [LOG2()](#log2)
      * [LOG10()](#log10)
      * [MOVING_AVERAGE()](#moving-average)
      * [NON_NEGATIVE_DERIVATIVE()](#non-negative-derivative)
      * [NON_NEGATIVE_DIFFERENCE()](#non-negative-difference)
      * [POW()](#pow)
      * [ROUND()](#round)
      * [SIN()](#sin)
      * [SQRT()](#sqrt)
      * [TAN()](#tan)
    * [预测函数](#预测函数)
      * [HOLT_WINTERS()](#holt_winters)
    * [分析函数](#分析函数)
      * [CHANDE_MOMENTUM_OSCILLATOR()](#chande_momentum_oscillator)
      * [EXPONENTIAL_MOVING_AVERAGE()](#exponential_moving_average)
      * [DOUBLE_EXPONENTIAL_MOVING_AVERAGE()](#double_exponential_moving_average)
      * [KAUFMANS_EFFICIENCY_RATIO()](#kaufmans_efficiency_ratio)
      * [KAUFMANS_ADAPTIVE_MOVING_AVERAGE()](#kaufmans_adaptive_moving_average)
      * [TRIPLE_EXPONENTIAL_MOVING_AVERAGE()](#triple_exponential_moving_average)
      * [TRIPLE_EXPONENTIAL_DERIVATIVE()](#triple_exponential_derivative)
      * [RELATIVE_STRENGTH_INDEX()](#relative_strength_index)
    * [其他](#other)
      * [示例数据](#示例数据)
      * [函数的通用语法](#函数的通用语法)
        * [在`SELECT`中指定多个函数](#在SELECT中指定多个函数)
        * [重命名查询结果字段](#重命名查询结果字段)
        * [改变不含数据的时间间隔的返回值](#改变不含数据的时间间隔的返回值)
      * [函数常见问题](#函数的常见问题)

### 聚合函数

- ### COUNT()

  返回非空值 field values数量

  #### 语法

  ```sql
  SELECT COUNT( [ * | <field_key> | /<regular_expression>/ ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  #### 嵌套语法

  ```sql
  SELECT COUNT(DISTINCT( [ * | <field_key> | /<regular_expression>/ ] )) [...]
  ```

  `COUNT(field_key)`返回`field key`对应的`field value`的个数。

  `COUNT(/regular_expression/)`返回与正则表达式匹配的每个`field key`对应的`field value`的个数。

  `COUNT(*)`返回在`measurement`中每个`field key`对应的`field value`的个数。

  `COUNT()`支持所有数据类型的`field value`。cnosQL支持将[`DISTINCT()`](#distinct)函数嵌套在`COUNT()`函数里。

  #### 示例

  - #### 计算指定field key的field value的数目

  ```sql
  > SELECT COUNT("temperature") FROM "air"
  name: air
  time                 count
  ----                 -----
  1970-01-01T00:00:00Z 3334
  ```

  该查询返回`measurement``air`中的`temperature`的非空field value的数量。

  - #### 计数measurement中每个field key关联的field value的数量

  ```sql
  > SELECT COUNT(*) FROM "air"
  name: air
  time                 count_pressure count_temperature count_visibility
  ----                 -------------- ----------------- ----------------
  1970-01-01T00:00:00Z 3334           3334              3334
  ```

  该查询返回与measurement`air`相关联的每个field key的非空field value的数量。`air`有3个field keys：`count_pressure` `count_temperature` `count_visibility`

  - #### 计算匹配一个正则表达式的每个field key关联的field value的数目

  ```sql
  > SELECT COUNT(/.*pre.*/) FROM "air"
  name: air
  time                 count_pressure
  ----                 --------------
  1970-01-01T00:00:00Z 3334
  ```

  该查询返回measurement`air`中包含`pre`的每个field key的非空字段值的数量。

  - #### 计数包括多个子句的field key的field value的数目

  ```sql
  >  SELECT COUNT("pressure") FROM "air" WHERE time < now()  GROUP BY time(1ms),* fill(-1) LIMIT 7 SLIMIT 1
  name: air
  tags: station=LianYunGang
  time                     count
  ----                     -----
  2022-04-11T08:03:37.071Z 108
  2022-04-11T08:03:37.072Z 193
  2022-04-11T08:03:37.073Z 207
  2022-04-11T08:03:37.074Z 209
  2022-04-11T08:03:37.075Z 209
  2022-04-11T08:03:37.076Z 218
  2022-04-11T08:03:37.077Z 216
  ```

  该查询返回`pressure`field key中的非空field value的数量。它涵盖`now()`之间的`时间段`，并将结果分组为1ms的时间间隔和每个tag(表示为以上代码中的`*`)。并用`-1`填充空的时间间隔，并返回7个`point`，表格返回1。

- #### 计算一个field key的distinct的field value的数量

  ```sql
  > SELECT COUNT(DISTINCT("pressure")) FROM "air"
  name: air
  time                 count
  ----                 -----
  1970-01-01T00:00:00Z 7
  ```

查询返回measurement为`air`field`为`pressure 的唯一field value的数量。

#### `COUNT()`的常见问题

- #### `COUNT()`和`fill()`

大多数cnosQL函数对于没有数据的时间间隔返回`null`值，`fill(<fill_option>)`将该`null`值替换为`fill_option`。 `COUNT()`针对没有数据的时间间隔返回`0`，`fill(<fill_option>)`用`fill_option`替换0值。

*示例*

下面的代码块中的第一个查询不包括`fill()`。最后一个时间间隔没有数据，因此该时间间隔的值返回为零。第二个查询包括`fill(-1)`; 它将最后一个间隔中的零替换为`-1`。

  ```sql
  > SELECT COUNT("pressure") FROM "air" WHERE time < now()  GROUP BY time(1s),*  LIMIT 7 SLIMIT 1
  name: air
  tags: station=LianYunGang
  time                 count
  ----                 -----
  2022-04-11T08:03:37Z 1617
  2022-04-11T08:03:38Z 0
  2022-04-11T08:03:39Z 0
  2022-04-11T08:03:40Z 0
  2022-04-11T08:03:41Z 0
  2022-04-11T08:03:42Z 0
  2022-04-11T08:03:43Z 0
  
  > SELECT COUNT("pressure") FROM "air" WHERE time < now()  GROUP BY time(1s),* fill(-1) LIMIT 7 SLIMIT 1
  name: air
  tags: station=LianYunGang
  time                 count
  ----                 -----
  2022-04-11T08:03:37Z 1617
  2022-04-11T08:03:38Z -1
  2022-04-11T08:03:39Z -1
  2022-04-11T08:03:40Z -1
  2022-04-11T08:03:41Z -1
  2022-04-11T08:03:42Z -1
  2022-04-11T08:03:43Z -1
  ```

- ### `DISTINCT()`

  返回`field value`的不重复值列表。

  #### 语法

  ```sql
  SELECT DISTINCT( [ <field_key> | /<regular_expression>/ ] ) FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  #### 嵌套语法

  ```sql
  SELECT COUNT(DISTINCT( [ <field_key> | /<regular_expression>/ ] )) [...]
  ```

  #### 语法描述

  `DISTINCT(field_key)` 返回`field key`对应的不同`field values`。

  `DISTINCT()` 支持所有数据类型的`field value`，cnosQL支持[`COUNT()`](#count)嵌套`DISTINCT()`。

  #### 示例

  - #### 列出一个`field key`的不同的`field value`

  ```sql
  > SELECT DISTINCT("temperature") FROM "air"
  name: air
  time                 distinct
  ----                 --------
  1970-01-01T00:00:00Z 58
  1970-01-01T00:00:00Z 62
  1970-01-01T00:00:00Z 56
  1970-01-01T00:00:00Z 59
  1970-01-01T00:00:00Z 57
  1970-01-01T00:00:00Z 61
  1970-01-01T00:00:00Z 60
  ```

  该查询返回`air` measurement中`temperature`field 关键字中唯一`field values`的列表

[//]: # (  - #### 列出一个measurement中每个field key的不同的值)

[//]: # ()
[//]: # (  ```sql)

[//]: # (  > SELECT DISTINCT&#40;"temperature"&#41; FROM "air")

[//]: # (  name: air)

[//]: # (  time                 distinct)

[//]: # (  ----                 --------)

[//]: # (  1970-01-01T00:00:00Z 63)

[//]: # (  1970-01-01T00:00:00Z 79)

[//]: # (  1970-01-01T00:00:00Z 52)

[//]: # (  1970-01-01T00:00:00Z 70)

[//]: # (  1970-01-01T00:00:00Z 77)

[//]: # (  1970-01-01T00:00:00Z 54)

[//]: # (  1970-01-01T00:00:00Z 73)

[//]: # (  1970-01-01T00:00:00Z 55)

[//]: # (  1970-01-01T00:00:00Z 71)

[//]: # (  1970-01-01T00:00:00Z 50)

[//]: # (  1970-01-01T00:00:00Z 58)

[//]: # (  1970-01-01T00:00:00Z 59)

[//]: # (  1970-01-01T00:00:00Z 76)

[//]: # (  1970-01-01T00:00:00Z 57)

[//]: # (  1970-01-01T00:00:00Z 68)

[//]: # (  1970-01-01T00:00:00Z 67)

[//]: # (  1970-01-01T00:00:00Z 62)

[//]: # (  1970-01-01T00:00:00Z 74)

[//]: # (  1970-01-01T00:00:00Z 64)

[//]: # (  1970-01-01T00:00:00Z 53)

[//]: # (  1970-01-01T00:00:00Z 60)

[//]: # (  1970-01-01T00:00:00Z 56)

[//]: # (  1970-01-01T00:00:00Z 61)

[//]: # (  1970-01-01T00:00:00Z 69)

[//]: # (  1970-01-01T00:00:00Z 65)

[//]: # (  1970-01-01T00:00:00Z 66)

[//]: # (  1970-01-01T00:00:00Z 78)

[//]: # (  1970-01-01T00:00:00Z 51)

[//]: # (  1970-01-01T00:00:00Z 80)

[//]: # (  1970-01-01T00:00:00Z 72)

[//]: # (  1970-01-01T00:00:00Z 75)

[//]: # (  ```)

[//]: # ()
[//]: # (  查询返回`air`中字段的唯一字段值的列表。)

- #### 列出包含多个子句的field key关联的不同值的列表

  ```sql
  >SELECT DISTINCT("pressure") FROM "air" WHERE  time <now() GROUP BY time(12m),* SLIMIT 1
  name: air
  tags: station=LianYunGang
  time                 distinct
  ----                 --------
  2022-04-11T08:00:00Z 58
  2022-04-11T08:00:00Z 56
  2022-04-11T08:00:00Z 59
  2022-04-11T08:00:00Z 57
  2022-04-11T08:00:00Z 62
  2022-04-11T08:00:00Z 60
  2022-04-11T08:00:00Z 61
  ```

该查询返回`pressure`field key中不同field value的列表。它涵盖now()之前的时间段，并将结果按12分钟的时间间隔和每个tag分组。查询限制（SLIMIT）返回一个series。

- #### 对一个字段的不同值进行计算

  ```sql
  > SELECT COUNT(DISTINCT("pressure")) FROM "air"
  name: air
  time                 count
  ----                 -----
  1970-01-01T00:00:00Z 7
  ```

查询返回`air`这个measurement中字段`pressure`的不同值的数目。

#### `DISTINCT()`的常见问题

- #### `DISTINCT()` 和 `INTO` 子句

在`INTO`子句中使用`DISTINCT()`可能会导致CnosDB覆盖目标measurement中的`points`。`DISTINCT()`通常返回多个具有相同时间戳的结果；CnosDB假设在相同series中并具有相同时间戳的`point`是重复`point`，并简单地用目标measurement中最新的`point`覆盖重复`point`。

####示例

下面代码块中的第一个查询使用了`DISTINCT()`，并返回7个结果。请注意，每个结果都有相同的时间戳。第二个查询将`INTO`子句添加到查询中，并将查询结果写入measurement `distincts`。最后一个查询选择measurement `distincts`中所有数据。
因为原来的四个结果是重复的(它们在相同的series，有相同的时间戳)，所以最后一个查询只返回一个`point`。当系统遇到重复数据`point`，它会用最近的`point`覆盖之前的`point`。

  ```sql
  > SELECT DISTINCT("pressure") FROM "air"
  name: air
  time                 distinct
  ----                 --------
  1970-01-01T00:00:00Z 56
  1970-01-01T00:00:00Z 59
  1970-01-01T00:00:00Z 62
  1970-01-01T00:00:00Z 58
  1970-01-01T00:00:00Z 60
  1970-01-01T00:00:00Z 61
  1970-01-01T00:00:00Z 57
  
  > SELECT DISTINCT("pressure") INTO "distincts" FROM "air"
  name: result
  time                 written
  ----                 -------
  1970-01-01T00:00:00Z 7 
  
  > SELECT * FROM "distincts"
  name: distincts
  time                 distinct
  ----                 --------
  1970-01-01T00:00:00Z 57
  ```

- ### `INTEGRAL()`

  返回`field value`曲线下的面积，即关于`field value`的积分。

  #### 语法

  ```
  SELECT INTEGRAL( [ * | <field_key> | /<regular_expression>/ ] [ , <unit> ]  ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  #### 语法描述

  CnosDB计算field value曲线下的面积，并将这些结果转换为每个`unit`的总面积。参数`unit`的值是一个整数，后跟一个时间单位。这个参数是可选的，不是必须要有的。如果查询没有指定`unit`的值，那么`unit`默认为一秒(`1s`)。

  `INTEGRAL(field_key)`返回field key关联的值之下的面积。

  `INTEGRAL(/regular_expression/)`返回满足正则表达式的每个field key关联的值之下的面积。

  `INTEGRAL(*)`返回`measurement`中每个`field key`关联的值之下的面积。

  `INTEGRAL()`不支持`fill()`，`INTEGRAL()`支持int64和float64两个数据类型。

  #### 示例

  下面的五个例子，使用数据库[`oceanic_station`中的数据](oceanic_station.txt)：

  ```sql
  >  SELECT  temperature  FROM "air" WHERE "station" = 'XiaoMaiDao' limit 10
  name: air
  time                        temperature
  ----                        -----------
  2022-04-11T08:03:37.07132Z  58
  2022-04-11T08:03:37.071378Z 62
  2022-04-11T08:03:37.071385Z 58
  2022-04-11T08:03:37.071391Z 56
  2022-04-11T08:03:37.071394Z 56
  2022-04-11T08:03:37.071401Z 59
  2022-04-11T08:03:37.071403Z 57
  2022-04-11T08:03:37.071406Z 62
  2022-04-11T08:03:37.071409Z 59
  2022-04-11T08:03:37.071411Z 62
  ```

  - #### 计算指定的field key的值得积分

  ```sql
  >SELECT  INTEGRAL(temperature)  FROM "air" WHERE "station" = 'XiaoMaiDao' limit 10 
  name: air
  time                 integral
  ----                 --------
  1970-01-01T00:00:00Z 0.4677579999999999
  ```

  该查询返回`air`中的字段`temperature`的曲线下的面积（以秒为单位）。

  - #### 计算指定的field key和时间单位的值的积分

  ```sql
  > SELECT  INTEGRAL(temperature,1ms)  FROM "air" WHERE "station" = 'XiaoMaiDao' limit 10
  name: air
  time                 integral
  ----                 --------
  1970-01-01T00:00:00Z 467.7580000000045
  ```

  该查询返回`air`中的字段`temperature`的曲线下的面积（以1ms为单位）。

  - #### 计算measurement中每个field key在指定时间单位的值得积分

  ```sql
  > SELECT  INTEGRAL(*,1ms)  FROM "air" WHERE "station" = 'XiaoMaiDao' and time<now()
  name: air
  time                 integral_pressure  integral_temperature integral_visibility
  ----                 -----------------  -------------------- -------------------
  1970-01-01T00:00:00Z 467.22900000000413 467.7580000000045    491.2000000000007
  ```

  查询返回measurement`air`中存储的每个数值字段相关的字段值的曲线下面积（以1ms为单位）

  - #### 计算measurement中匹配正则表达式的field key在指定时间单位的值得积分

  ```sql
  > SELECT  INTEGRAL(/temp/,1ms)  FROM "air" WHERE "station" = 'XiaoMaiDao' and time<now()
  name: air
  time                 integral_temperature
  ----                 --------------------
  1970-01-01T00:00:00Z 467.7580000000045
  
  ```

  查询返回field key包括单词`water`的每个数值类型的字段相关联的字段值的曲线下的区域（以分钟为单位）。

  - #### 在含有多个子句中计算指定字段的积分

  ```sql
  > SELECT  INTEGRAL(temperature,1ms)  FROM "air" WHERE "station" = 'XiaoMaiDao' and time<now() GROUP BY time(12m) LIMIT 1
  name: air
  time                 integral_temperature
  ----                 --------------------
  2022-04-11T08:00:00Z 467.7580000000045
  ```

  该查询返回`measurement` `air`中`field key` `temperature`对应的field value曲线下的面积(以分钟为单位)，它涵盖的时间范围在now()之前，并将查询结果按12分钟的时间间隔进行分组，同时，该查询将返回的`point`个数限制为1。

- ### `MEAN()`

  返回field value的平均值。

  #### 语法

  ```
  SELECT MEAN( [ * | <field_key> | /<regular_expression>/ ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `MEAN(field_key)`返回`field key`对应的`field value`的平均值。

  `MEAN(/regular_expression/)`返回与正则表达式匹配的每个`field key`对应的field value的平均值。

  `MEAN(*)`返回在`measurement`中每个`field key`对应的`field value`的平均值。

  `MEAN()`支持数据类型为int64和float64的field value。

  #### 示例

  - #### 计算指定field key对应的field value的平均值

  ```sql
  > SELECT MEAN("temperature") FROM "air"
  name: air
  time                   mean
  ----                   ----
  1970-01-01T00:00:00Z   4.442107025822522
  ```
  该查询返回`measurement` `air`中`field key` `temperature`对应的`field value`的平均值。

  - #### 计算measurement中每个field key对应的field value的平均值

  ```sql
  > SELECT MEAN(*) FROM "air" 
  name: air
  time                 mean_pressure     mean_temperature  mean_visibility
  ----                 -------------     ----------------  ---------------
  1970-01-01T00:00:00Z 59.00689862027595 59.04949010197961 62.01889622075585
  ```
  该查询返回`measurement` `air`中每个存储数值的`field key`对应的`field value`的平均值。

  - #### 计算与正则表达式匹配的每个field key对应的field value的平均值

  ```sql
  > SELECT MEAN(/temp/) FROM "air" 
  name: air
  time                   mean_temperature
  ----                   ----------------
  1970-01-01T00:00:00Z   4.442107025822523
  ```

  该查询返回`measurement` `air`中每个存储数值并包含单词`water`的`field key`对应的`field value`的平均值。

  - #### 计算指定field key对应的field value的平均值并包含多个子句

  ```sql
  > SELECT MEAN("temperature") FROM "air" WHERE time <now() GROUP BY time(12m),* fill(9.01) LIMIT 7 SLIMIT 1
  name: air
  tags: station=LianYunGang
  time                 mean
  ----                 ----
  2022-04-11T08:00:00Z 59.06864564007421
  2022-04-11T08:12:00Z 9.01
  2022-04-11T08:24:00Z 9.01
  2022-04-11T08:36:00Z 9.01
  2022-04-11T08:48:00Z 9.01
  2022-04-11T09:00:00Z 9.01
  2022-04-11T09:12:00Z 9.01 
  ```

  该查询返回`measurement` `air`中field key `temperature`对应的field value的平均值，将查询结果按12分钟的时间间隔和每个`tag`进行分组，同时，该查询用`9.01`填充没有数据的时间间隔，并将返回的`point`个数和series个数分别限制为7和1。

- ### MEDIAN()

  返回`field value`的计算中值。

  #### 语法

  ```
  SELECT MEDIAN( [ * | <field_key> | /<regular_expression>/ ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  #### 语法描述

  `MEDIAN(field_key)`返回与`field key`对应的field value的中值。

  `MEDIAN(/regular_expression/)`返回与正则表达式匹配的每个`field key`对应的`field value`的中值。

  `MEDIAN(*)`返回在`measurement`中每个`field key`对应的`field value`的中值。

  `MEDIAN()` 支持数据类型为int64和float64的field value。

  > **注意：**`MEDIAN()`近似于`PERCENTILE(field_key, 50)`，除非`field key`包含的`field value`有偶数个，那么这时候`MEDIAN()`将返回两个中间值的平均数。

  #### 示例

  - #### 计算指定field key对应的field value的中值

  ```sql
  > SELECT MEDIAN("pressure") FROM "air"
  name: air
  time                 median
  ----                 ------
  1970-01-01T00:00:00Z 59
  ```

  该查询返回`measurement` `air`中field key `pressure`对应的`field value`的中值。

  - #### 计算measurement中每个field key对应的field value的中值

  ```sql
  > SELECT MEDIAN(*) FROM "air"
  name: air
  time                 median_pressure median_temperature median_visibility
  ----                 --------------- ------------------ -----------------
  1970-01-01T00:00:00Z 59              59                 62
  ```

  该查询返回`measurement` `air`中每个存储数值的`field key`对应的`field value`的中值。

  - #### 计算与正则表达式匹配的每个field key对应的field value的中值

  ```sql
  > SELECT MEDIAN(/temp/) FROM "air"
  name: air
  time                 median_temperature
  ----                 ------------------
  1970-01-01T00:00:00Z 59
  ```
  该查询返回measurement `air`中每个存储数值并包含单词`water`的field key对应的field value的中值。

  - #### 计算指定field key对应的field value的中值并包含多个子句

  ```sql
  > SELECT MEDIAN("temperature") FROM "air" WHERE  time<now()  GROUP BY time(1m),* fill(-1) LIMIT 7 SLIMIT 3 SOFFSET 1
  name: air
  tags: station=XiaoMaiDao
  time                 median
  ----                 ------
  2022-04-11T08:03:00Z 59
  2022-04-11T08:04:00Z -1
  2022-04-11T08:05:00Z -1
  2022-04-11T08:06:00Z -1
  2022-04-11T08:07:00Z -1
  2022-04-11T08:08:00Z -1
  2022-04-11T08:09:00Z -1
  ```

  该查询返回`measurement` `air`中`field key` `temperature`对应的`field value`的平均数，它涵盖的时间范围在now()之前，并将查询结果按1分钟的时间间隔和每个`tag`进行分组，同时，该查询用`-1`填充没有数据的时间间隔，将返回的`point`个数和series个数分别限制为3和1，并将返回的`series`偏移一个（即第一个`series`的数据不返回）。

- ### MODE()

  返回`field value`中出现频率最高的值。

  #### 语法

  ```
  SELECT MODE( [ * | <field_key> | /<regular_expression>/ ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `MODE(field_key)`返回`field key`对应的`field value`中出现频率最高的值。

  `MODE(/regular_expression/)`返回与正则表达式匹配的每个`field key`对应的`field value`中出现频率最高的值。

  `MODE(*)`返回在`measurement`中每个`field key`对应的`field value`中出现频率最高的值。

  `MODE()` 支持所有数据类型的`field value`。

  > **注意：**如果出现频率最高的值有两个或多个并且它们之间有关联，那么`MODE()`返回具有最早时间戳的`field value`。

  #### 示例

  - #### 计算指定field key对应的field value中出现频率最高的值

  ```sql
  > SELECT MODE("temperature") FROM "air"
  name: air
  time                 mode
  ----                 ----
  1970-01-01T00:00:00Z 62
  ```

  该查询返回`measurement` `air`中某个`field key`对应的`field value`中出现频率最高的值。

  - #### 计算measurement中每个field key对应的field value中出现频率最高的值

  ```sql
  > SELECT MODE(*) FROM "air"
  name: air
  time                 mode_pressure mode_temperature mode_visibility
  ----                 ------------- ---------------- ---------------
  1970-01-01T00:00:00Z 57            62               61
  ```

  - #### 计算与正则表达式匹配的每个field key对应的field value中出现频率最高的值

  ```sql
  SELECT MODE(/temp/) FROM "air"
  name: air
  time                 mode_temperature
  ----                 ----------------
  1970-01-01T00:00:00Z 62
  ```

  - #### 计算指定field key对应的field value中出现频率最高的值并包含多个子句

  ```sql
  > SELECT MODE("temperature") FROM "air" WHERE time <now() GROUP BY time(12m),* LIMIT 3 SLIMIT 1 SOFFSET 1
  name: air
  tags: station=XiaoMaiDao
  time                 mode
  ----                 ----
  2022-04-11T08:00:00Z 59
  2022-04-11T08:12:00Z 
  2022-04-11T08:24:00Z 
  ```

  该查询返回`measurement` `air`中`field key` `temperature`对应的`temperature`中出现频率最高的值，并将查询结果按12分钟的时间间隔和每个`tag`进行分组，同时，该查询将返回的`point`个数和`series`个数分别限制为3和1，并将返回的`series`偏移一个（即第一个`series`的数据不返回）。

- ### SPREAD()

  返回`field value`中最大值和最小值之差。

  #### 语法

  ```sql
  SELECT SPREAD( [ * | <field_key> | /<regular_expression>/ ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  #### 语法描述

  `SPREAD(field_key)`返回`field key`对应的`field value`中最大值和最小值之差。

  `SPREAD(/regular_expression/)`返回与正则表达式匹配的每个`field key`对应的`field value`中最大值和最小值之差。

  `SPREAD(*)`返回在`measurement`中每个`field key`对应的`field value`中最大值和最小值之差。

  `SPREAD()`支持数据类型为int64和float64的`field value`。

  #### 示例

  - #### 计算指定field key对应的field value中最大值和最小值之差

  ```sql
  SELECT SPREAD("temperature") FROM "air"
  name: air
  time                 spread
  ----                 ------
  1970-01-01T00:00:00Z 6
  ```

  该查询返回`measurement` `air`中`field key` `temperature`对应的`field value`中最大值和最小值之差。

  - #### 计算measurement中每个field key对应的field value中最大值和最小值之差

  ```sql
  > SELECT SPREAD(*) FROM "air"
  name: air
  time                 spread_pressure spread_temperature spread_visibility
  ----                 --------------- ------------------ -----------------
  1970-01-01T00:00:00Z 6               6                  6
  ```

  该查询返回`measurement` `air`中每个存储数值的`field key`对应的`field value`中最大值和最小值之差。

  - #### 计算与正则表达式匹配的每个field key对应的field value中最大值和最小值之差

  ```sql
  > SELECT SPREAD(/tem/) FROM "air"
  name: air
  time                 spread_temperature
  ----                 ------------------
  1970-01-01T00:00:00Z 6
  ```

  该查询返回`measurement` `air`中每个存储数值并包含单词`water`的`field key`对应的`field value`中最大值和最小值之差。

  - #### 计算指定field key对应的field value中最大值和最小值之差并包含多个子句

  ```sql
  > SELECT SPREAD("temperature") FROM "air" WHERE time <now() GROUP BY time(12m),* fill(-1) LIMIT 3 SLIMIT 1 SOFFSET 1
  name: air
  tags: station=XiaoMaiDao
  time                 spread
  ----                 ------
  2022-04-11T08:00:00Z 6
  2022-04-11T08:12:00Z -1
  2022-04-11T08:24:00Z -1
  ```

  该查询返回`measurement` `air`中field key `temperature`对应的field value中最大值和最小值之差，将查询结果按12分钟的时间间隔和每个`tag`进行分组，同时，该查询用`-1`填充没有数据的时间间隔，将返回的`point`个数和`series`个数分别限制为3和1，并将返回的`series`偏移一个（即第一个`series`的数据不返回）

- ### STDDEV()

  返回`field value`的标准差。

  #### 语法

  ```sql
  SELECT STDDEV( [ * | <field_key> | /<regular_expression>/ ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `STDDEV(field_key)`返回`field key`对应的`field value`的标准差。

  `STDDEV(/regular_expression/)`返回与正则表达式匹配的每个`field key`对应的`field value`的标准差。

  `STDDEV(*)`返回在measurement中每个field key对应的field value的标准差。

  `STDDEV()`支持数据类型为int64和float64的field value。

  #### 示例

  - #### 计算指定field key对应的field value的标准差

  ```sql
  > SELECT STDDEV("temperature") FROM "air"
  name: air
  time                 stddev
  ----                 ------
  1970-01-01T00:00:00Z 1.9933006709246002
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的标准差。

  - #### 计算measurement中每个field key对应的field value的标准差

  ```sql
  > SELECT STDDEV(*) FROM "air"
  name: air
  time                 stddev_pressure    stddev_temperature stddev_visibility
  ----                 ---------------    ------------------ -----------------
  1970-01-01T00:00:00Z 2.0234776612813525 1.9933006709246002 1.9942769555619093
  ```

  该查询返回measurement `air`中每个存储数值的field key对应的field value的标准差。

  - #### 计算与正则表达式匹配的每个field key对应的field value的标准差

  ```sql
  > SELECT STDDEV(/temp/) FROM "air"
  name: air
  time                   stddev_temperature
  ----                   ------------------
  1970-01-01T00:00:00Z   2.279144584196141
  ```

  该查询返回measurement `air`中每个存储数值并包含单词`water`的field key对应的field value的标准差。

  - #### 计算指定field key对应的field value的标准差并包含多个子句

  ```sql
  SELECT STDDEV("temperature") FROM "air" WHERE time <now() GROUP BY time(12m),* fill(18000) LIMIT 2 SLIMIT 1 SOFFSET 1
  name: air
  tags: station=XiaoMaiDao
  time                 stddev
  ----                 ------
  2022-04-11T08:00:00Z 1.9988781365491315
  2022-04-11T08:12:00Z 18000
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的标准差，并将查询结果按12分钟的时间间隔和每个tag进行分组，同时，该查询用`18000`填充没有数据的时间间隔，将返回的`point`个数和series个数分别限制为2和1，并将返回的series偏移一个（即第一个series的数据不返回）。

- ### SUM()

  返回field value的总和。

  #### 语法

  ```
  SELECT SUM( [ * | <field_key> | /<regular_expression>/ ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  #### 语法描述

  `SUM(field_key)`返回field key对应的field value的总和。

  `SUM(/regular_expression/)`返回与正则表达式匹配的每个field key对应的field value的总和。

  `SUM(*)`返回在measurement中每个field key对应的field value的总和。

  `SUM()`支持数据类型为int64和float64的field value。

  #### 示例

  - #### 计算指定field key对应的field value的总和

  ```sql
  > SELECT SUM("temperature") FROM "air"
  name: air
  time                 sum
  ----                 ---
  1970-01-01T00:00:00Z 196871
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的总和。

  - #### 计算measurement中每个field key对应的field value的总和

  ```sql
  > SELECT SUM(*) FROM "air"
  name: air
  time                 sum_pressure sum_temperature sum_visibility
  ----                 ------------ --------------- --------------
  1970-01-01T00:00:00Z 196729       196871          206771
  ```

  该查询返回measurement `air`中每个存储数值的field key对应的field value的总和。

  - #### 计算与正则表达式匹配的每个field key对应的field value的总和

  ```sql
  > SELECT SUM(/temp/) FROM "air"
  name: air
  time                 sum_temperature
  ----                 ---------------
  1970-01-01T00:00:00Z 196871
  ```

  该查询返回measurement `air`中每个存储数值并包含单词`water`的field key对应的field value的总和。

  - #### 计算指定field key对应的field value的总和并包含多个子句

  ```sql
  > SELECT SUM("temperature") FROM "air" WHERE time <now() GROUP BY time(12m),* fill(18000) LIMIT 4 SLIMIT 1
  name: air
  tags: station=LianYunGang
  time                 sum
  ----                 ---
  2022-04-11T08:00:00Z 95514
  2022-04-11T08:12:00Z 18000
  2022-04-11T08:24:00Z 18000
  2022-04-11T08:36:00Z 18000
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的总和，并将查询结果按12分钟的时间间隔和每个tag进行分组，同时，该查询用`18000`填充没有数据的时间间隔，并将返回的`point`个数和series个数分别限制为4和1。


## 选择函数

- ### BOTTOM()

  返回最小的N个field value。

  #### 语法

  ```
  SELECT BOTTOM(<field_key>[,<tag_key(s)>],<N> )[,<tag_key(s)>|<field_key(s)>] [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  #### 语法描述

  `BOTTOM(field_key,N)`返回field key对应的最小的N个值。

  `BOTTOM(field_key,tag_key(s),N)`返回tag key的N个tag value对应的field key的最小值。

  `BOTTOM(field_key,N),tag_key(s),field_key(s)`返回括号中的field key对应的最小的N个值，以及相关的tag和/或field。

  `BOTTOM()`支持数据类型为int64和float64的field value。

  **注意：**

  * 如果最小值有两个或多个相等的值，`BOTTOM()`返回具有最早时间戳的field value。
  * 当`BOTTOM()`函数与`INTO`子句一起使用时，`BOTTOM()`与其它cnosQL函数不同。请查看`BOTTOM()`的常见问题章节获得更多信息。

  #### 示例

  - #### 选择指定field key对应的最小的三个值

  ```sql
  > SELECT BOTTOM("temperature",3) FROM "air"
  name: air
  time                 bottom
  ----                 ------
  2021-08-31T16:18:00Z 50
  2021-08-31T17:09:00Z 50
  2021-08-31T18:39:00Z 50
  ```

  该查询返回measurement `air`中field key `temperature`对应的最小的三个值。

  - #### 选择两个tag对应的field key的最小值

  ```sql
  > SELECT BOTTOM("temperature","station",2) FROM "air"
  name: air
  time                 bottom station
  ----                 ------ -------
  2021-08-31T16:18:00Z 50     XiaoMaiDao
  2021-08-31T18:39:00Z 50     LianYunGang
  ```

  该查询返回tag key `station`的两个tag value对应的field key `temperature`的最小值。

  - #### 选择指定field key对应的最小的四个值以及相关的tag和field

  ```sql
  > SELECT BOTTOM("temperature",4),"station","pressure" FROM "air"
  name: air
  time                 bottom station     pressure
  ----                 ------ -------     --------
  2021-08-31T16:18:00Z 50     XiaoMaiDao  55
  2021-08-31T17:09:00Z 50     XiaoMaiDao  63
  2021-08-31T18:39:00Z 50     LianYunGang 64
  2021-08-31T19:51:00Z 50     LianYunGang 62
  ```

  该查询返回field key `temperature`对应的最小的四个值，以及相关的tag key `station`和field key `pressure`的值。

  - #### 选择指定field key对应的最小的三个值并包含多个子句

  ```sql
  > SELECT BOTTOM("temperature",3),"station" FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:54:00Z' GROUP BY time(24m) ORDER BY time DESC
  name: air
  time                 bottom station
  ----                 ------ -------
  2021-09-18T00:54:00Z 69     LianYunGang
  2021-09-18T00:51:00Z 65     LianYunGang
  2021-09-18T00:48:00Z 68     XiaoMaiDao
  2021-09-18T00:39:00Z 53     XiaoMaiDao
  2021-09-18T00:36:00Z 52     LianYunGang
  2021-09-18T00:33:00Z 50     LianYunGang
  2021-09-18T00:06:00Z 55     LianYunGang
  2021-09-18T00:03:00Z 53     XiaoMaiDao
  2021-09-18T00:00:00Z 51     LianYunGang
  ```

  该查询返回在`2021-09-28T00:00:00Z`和`2020-08-18T00:54:00Z`之间的每个24分钟间隔内，field key `temperature`对应的最小的三个值，并且以递减的时间戳顺序返回结果。

  请注意，`GROUP BY time()`子句不会覆盖`point`的原始时间戳。请查看下面章节获得更详细的说明。

  #### `BOTTOM()`的常见问题

  - #### `BOTTOM()`和`GROUP BY time()`子句同时使用

  对于同时带有`BOTTOM()`和`GROUP BY time()`子句的查询，将返回每个`GROUP BY time()`时间间隔的指定个数的`point`。对于大多数`GROUP BY time()`查询，返回的时间戳表示`GROUP BY time()`时间间隔的开始时间，但是，带有`BOTTOM()`函数的`GROUP BY time()`查询则不一样，它们保留原始`point`的时间戳。

  以下查询返回每18分钟`GROUP BY time()`间隔对应的两个`point`。请注意，返回的时间戳是`point`的原始时间戳；它们不会被强制要求必须匹配`GROUP BY time()`间隔的开始时间。

  ```sql
  > SELECT BOTTOM("temperature",2) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(18m)
  name: air
  time                   bottom
  ----                   ------
                             __
  2021-09-28T00:00:00Z  2.064 |
  2021-09-18T00:12:00Z  2.028 | <------- Smallest points for the first time interval
                             --
                             __
  2021-09-18T00:24:00Z  2.041 |
  2021-09-18T00:30:00Z  2.051 | <------- Smallest points for the second time interval                      --
  ```

  - #### `BOTTOM()`和具有少于N个tag value的tag key

  使用语法`SELECT BOTTOM(<field_key>,<tag_key>,<N>)`的查询可以返回比预期少的`point`。如果tag key有`X`个tag value，但是查询指定的是`N`个tag value，如果`X`小于`N`，那么查询将返回`X`个`point`。

  以下查询请求的是tag key `station`的三个tag value对于的`temperature`的最小值。因为tag key `station`只有两个tag value(`LianYunGang`和`XiaoMaiDao`)，所以该查询返回两个`point`而不是三个。

  ```sql
  > SELECT BOTTOM("temperature","station",3) FROM "air"
  name: air
  time                 bottom station
  ----                 ------ -------
  2021-08-31T16:18:00Z 50     XiaoMaiDao
  2021-08-31T18:39:00Z 50     LianYunGang
  ```

  - #### `BOTTOM()`、tag和`INTO`子句

  当使用`INTO`子句但没有使用`GROUP BY tag`子句时，大多数cnosQL函数将原始数据中的tag转换为新写入数据中的field。这种行为同样适用于`BOTTOM()`函数除非`BOTTOM()`中包含tag key作为参数：`BOTTOM(field_key,tag_key(s),N)`。在这些情况下，系统会将指定的tag保留为新写入数据中的tag。

  下面代码块中的第一个查询返回tag key `station`的两个tag value对应的field key `temperature`的最小值，并且，它这些结果写入measurement `bottom_temperatures`中。第二个查询展示了CnosDB将tag `station`保留为measurement `bottom_temperatures`中的tag。

  ```sql
  > SELECT BOTTOM("temperature","station",2) INTO "bottom_temperatures" FROM "air"
  name: result
  time                 written
  ----                 -------
  1970-01-01T00:00:00Z 2
  
  > SHOW TAG KEYS FROM "air"
  name: air
  tagKey
  ------
  station
  ```

- ### FIRST()

  返回具有最早时间戳的field value。

  #### 语法

  ```
  SELECT FIRST(<field_key>)[,<tag_key(s)>|<field_key(s)>] [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  #### 语法描述

  `FIRST(field_key)`返回field key对应的具有最早时间戳的field value。

  `FIRST(/regular_expression/)`返回与正则表达式匹配的每个field key对应的具有最早时间戳的field value。

  `FIRST(*)`返回在measurement中每个field key对应的具有最早时间戳的field value。

  `FIRST(field_key),tag_key(s),field_key(s)`返回括号中的field key对应的具有最早时间戳的field value，以及相关的tag或field。

  `FIRST()`支持所有数据类型的field value。

  #### 示例

  - #### 选择指定field key对应的具有最早时间戳的field value

  ```sql
  > SELECT FIRST("pressure") FROM "air"
  name: air
  time                 first
  ----                 -----
  2021-08-31T16:00:00Z 78
  ```

  该查询返回measurement `air`中field key `pressure`对应的具有最早时间戳的field value。

  - #### 选择measurement中每个field key对应的具有最早时间戳的field value

  ```sql
  > SELECT FIRST(*) FROM "air"

  name: air
  time                 first_pressure first_temperature first_visibility
  ----                 -------------- ----------------- ----------------
  1970-01-01T00:00:00Z 78             79                71
  ```

  该查询返回measurement `air`中每个field key对应的具有最早时间戳的field value。measurement `air`中有两个field key：`pressure`和`temperature`。

  - #### 选择与正则表达式匹配的每个field key对应的具有最早时间戳的field value

  ```sql
  > SELECT FIRST(/temp/) FROM "air"
  
  name: air
  time                 first_temperature
  ----                 -----------------
  2021-08-31T16:00:00Z 79
  ```

  该查询返回measurement `air`中每个包含单词`level`的field key对应的具有最早时间戳的field value。

  - #### 选择指定field key对应的具有最早时间戳的field value以及相关的tag和field

  ```sql
  > SELECT FIRST("pressure"),"station","temperature" FROM "air"
  name: air
  time                 first station     temperature
  ----                 ----- -------     -----------
  2021-08-31T16:00:00Z 78    LianYunGang 63
  ```

  该查询返回measurement `air`中field key `pressure`对应的具有最早时间戳的field value，以及相关的tag key `station`和field key `temperature`的值。

  - #### 选择指定field key对应的具有最早时间戳的field value并包含多个子句

  ```sql
  > SELECT FIRST("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-28T00:54:00Z' GROUP BY time(12m),* fill(9.01) LIMIT 4 SLIMIT 1
  name: air
  tags: station=LianYunGang
  time                 first
  ----                 -----
  2021-09-18T00:00:00Z 51
  2021-09-18T00:12:00Z 63
  2021-09-18T00:24:00Z 70
  2021-09-18T00:36:00Z 52
  ```

  该查询返回measurement `air`中field key `temperature`对应的具有最早时间戳的field value，它涵盖的时间范围在`2020-08-17T23:48:00Z`和`2020-08-18T00:54:00Z`之间，并将查询结果按12分钟的时间间隔和每个tag进行分组，同时，该查询用`9.01`填充没有数据的时间间隔，并将返回的`point`个数和series个数分别限制为4和1。

  请注意，`GROUP BY time()`子句会覆盖`point`的原始时间戳。查询结果中的时间戳表示每12分钟时间间隔的开始时间，其中，第一个`point`涵盖的时间间隔在`2020-08-17T23:48:00Z`和`2021-09-28T00:00:00Z`之间，最后一个`point`涵盖的时间间隔在`2020-08-18T00:24:00Z`和`2020-08-18T00:36:00Z`之间。

- ### LAST()

  返回具有最新时间戳的field value。

  #### 语法

  ```sql
  SELECT LAST(<field_key>)[,<tag_key(s)>|<field_keys(s)>] [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `LAST(field_key)`返回field key对应的具有最新时间戳的field value。

  `LAST(/regular_expression/)`返回与正则表达式匹配的每个field key对应的具有最新时间戳的field value。

  `LAST(*)`返回在measurement中每个field key对应的具有最新时间戳的field value。

  `LAST(field_key),tag_key(s),field_key(s)`返回括号中的field key对应的具有最新时间戳的field value，以及相关的tag或field。

  `LAST()`支持所有数据类型的field value。

  #### 示例

  - #### 选择指定field key对应的具有最新时间戳的field value

  ```sql
  > SELECT LAST("pressure") FROM "air"
  name: air
  time                 last
  ----                 ----
  2021-09-30T04:00:00Z 65
  ```

  该查询返回measurement `air`中field key `pressure`对应的具有最新时间戳的field value。

  - #### 选择measurement中每个field key对应的具有最新时间戳的field value

  ```sql
  > SELECT LAST(*) FROM "air"
  name: air
  time                 last_pressure last_temperature last_visibility
  ----                 ------------- ---------------- ---------------
  1970-01-01T00:00:00Z 65            59               78
  ```

  该查询返回measurement `air`中每个field key对应的具有最新时间戳的field value。measurement `air`中有两个field key：`pressure`和`temperature`。

  - #### 选择与正则表达式匹配的每个field key对应的具有最新时间戳的field value

  ```sql
  > SELECT LAST(/temp/) FROM "air"
  name: air
  time                 last_temperature
  ----                 ----------------
  2021-09-30T04:00:00Z 59
  ```

  该查询返回measurement `air`中每个包含单词`level`的field key对应的具有最新时间戳的field value。

  - #### 选择指定field key对应的具有最新时间戳的field value以及相关的tag和field

  ```sql
  > SELECT LAST("pressure"),"station","temperature" FROM "air"
  name: air
  time                 last station     temperature
  ----                 ---- -------     -----------
  2021-09-30T04:00:00Z 65   LianYunGang 50
  ```

  该查询返回measurement `air`中field key `pressure`对应的具有最新时间戳的field value，以及相关的tag key `station`和field key `temperature`的值。

  - #### 选择指定field key对应的具有最新时间戳的field value并包含多个子句

  ```sql
  > SELECT LAST("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-28T00:54:00Z' GROUP BY time(12m),* fill(9.01) LIMIT 4 SLIMIT 1
  name: air
  tags: station=LianYunGang
  time                 last
  ----                 ----
  2021-09-18T00:00:00Z 55
  2021-09-18T00:12:00Z 68
  2021-09-18T00:24:00Z 50
  2021-09-18T00:36:00Z 58
  ```

  该查询返回measurement `air`中field key `temperature`对应的具有最新时间戳的field value，它涵盖的时间范围在`2020-08-17T23:48:00Z`和`2020-08-18T00:54:00Z`之间，并将查询结果按12分钟的时间间隔和每个tag进行分组，同时，该查询用`9.01`填充没有数据的时间间隔，并将返回的`point`个数和series个数分别限制为4和1。

  请注意，`GROUP BY time()`子句会覆盖`point`的原始时间戳。查询结果中的时间戳表示每12分钟时间间隔的开始时间，其中，第一个`point`涵盖的时间间隔在`2020-08-17T23:48:00Z`和`2021-09-28T00:00:00Z`之间，最后一个`point`涵盖的时间间隔在`2020-08-18T00:24:00Z`和`2020-08-18T00:36:00Z`之间。

- ### MAX()

  返回field value的最大值。

  #### 语法

  ```
  SELECT MAX(<field_key>)[,<tag_key(s)>|<field__key(s)>] [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `MAX(field_key)`返回field key对应的field value的最大值。

  `MAX(/regular_expression/)`返回与正则表达式匹配的每个field key对应的field value的最大值。

  `MAX(*)`返回在measurement中每个field key对应的field value的最大值。

  `MAX(field_key),tag_key(s),field_key(s)`返回括号中的field key对应的field value的最大值，以及相关的tag或field。

  `MAX()` 支持数据类型为int64和float64的field value。

  #### 示例

  - #### 选择指定field key对应的field value的最大值

  ```sql
  > SELECT MAX("temperature") FROM "air"
  name: air
  time                 max
  ----                 ---
  2021-08-31T18:03:00Z 80
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的最大值。

  - #### 选择measurement中每个field key对应的field value的最大值

  ```sql
  > SELECT MAX(*) FROM "air"
  name: air
  time                 max_pressure max_temperature max_visibility
  ----                 ------------ --------------- --------------
  1970-01-01T00:00:00Z 80           80              80
  ```

  该查询返回measurement `air`中每个存储数值的field key对应的field value的最大值。。measurement `air`中有三个数值类型的field：`temperature`、`pressure`以及`visibility`。

  - #### 选择与正则表达式匹配的每个field key对应的field value的最大值

  ```sql
  > SELECT MAX(/pres/) FROM "air"
  name: air
  time                 max_pressure
  ----                 ------------
  2021-08-31T17:03:00Z 80
  ```

  该查询返回measurement `air`中每个存储数值并包含单词`water`的field key对应的field value的最大值。

  - #### 选择指定field key对应的field value的最大值以及相关的tag和field

  ```sql
  > SELECT MAX("temperature"),"station","pressure" FROM "air"
  name: air
  time                 max station     pressure
  ----                 --- -------     --------
  2021-08-31T18:03:00Z 80  LianYunGang 74
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的最大值，以及相关的tag key `station`和field key `pressure`的值。

  - #### 选择指定field key对应的field value的最大值并包含多个子句

  ```sql
  > SELECT MAX("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-28T00:54:00Z' GROUP BY time(12m),* fill(9.01) LIMIT 4 SLIMIT 1
  name: air
  tags: station=LianYunGang
  time                 max
  ----                 ---
  2021-09-18T00:00:00Z 60
  2021-09-18T00:12:00Z 79
  2021-09-18T00:24:00Z 79
  2021-09-18T00:36:00Z 70
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的最大值，它涵盖的时间范围在`2020-08-17T23:48:00Z`和`2020-08-18T00:54:00Z`之间，并将查询结果按12分钟的时间间隔和每个tag进行分组，同时，该查询用`9.01`填充没有数据的时间间隔，并将返回的`point`个数和series个数分别限制为4和1。

  请注意，`GROUP BY time()`子句会覆盖`point`的原始时间戳。查询结果中的时间戳表示每12分钟时间间隔的开始时间，其中，第一个`point`涵盖的时间间隔在`2020-08-17T23:48:00Z`和`2021-09-28T00:00:00Z`之间，最后一个`point`涵盖的时间间隔在`2020-08-18T00:24:00Z`和`2020-08-18T00:36:00Z`之间。

- ### MIN()

  返回field value的最小值。

  #### 语法

  ```
  SELECT MIN(<field_key>)[,<tag_key(s)>|<field_key(s)>] [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `MIN(field_key)`返回field key对应的field value的最小值。

  `MIN(/regular_expression/)`返回与正则表达式匹配的每个field key对应的field value的最小值。

  `MIN(*)`返回在measurement中每个field key对应的field value的最小值。

  `MIN(field_key),tag_key(s),field_key(s)`返回括号中的field key对应的field value的最小值，以及相关的tag和/或field。

  `MIN()`支持数据类型为int64和float64的field value。

  #### 示例

  - #### 选择指定field key对应的field value的最小值

  ```sql
  > SELECT MIN("temperature") FROM "air"
  name: air
  time                 min
  ----                 ---
  2021-08-31T16:18:00Z 50
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的最小值。

  - #### 选择measurement中每个field key对应的field value的最小值

  ```sql
  > SELECT MIN(*) FROM "air"

  name: air
  time                 min_pressure min_temperature min_visibility
  ----                 ------------ --------------- --------------
  1970-01-01T00:00:00Z 50           50              50
  ```

  该查询返回measurement `air`中每个存储数值的field key对应的field value的最小值。。measurement `air`中有三个数值类型的field：`temperature`、`pressure`以及`visibility`。

  - #### 选择与正则表达式匹配的每个field key对应的field value的最小值

  ```sql
  > SELECT MIN(/temp/) FROM "air"

  name: air
  time                 min_temperature
  ----                 ---------------
  2021-08-31T16:18:00Z 50
  ```

  该查询返回measurement `air`中每个存储数值并包含单词`water`的field key对应的field value的最小值。

  - #### 选择指定field key对应的field value的最小值以及相关的tag和field

  ```sql
  > SELECT MIN("temperature"),"station","pressure" FROM "air"
  name: air
  time                 min station    pressure
  ----                 --- -------    --------
  2021-08-31T16:18:00Z 50  XiaoMaiDao 55
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的最小值，以及相关的tag key `station`和field key `pressure`的值。

  - #### 选择指定field key对应的field value的最小值并包含多个子句

  ```sql
  > SELECT MIN("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-28T00:54:00Z' GROUP BY time(12m),* fill(9.01) LIMIT 4 SLIMIT 1
  name: air
  tags: station=LianYunGang
  time                 min
  ----                 ---
  2021-09-18T00:00:00Z 51
  2021-09-18T00:12:00Z 63
  2021-09-18T00:24:00Z 50
  2021-09-18T00:36:00Z 52
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的最小值，它涵盖的时间范围在`2020-08-17T23:48:00Z`和`2020-08-18T00:54:00Z`之间，并将查询结果按12分钟的时间间隔和每个tag进行分组，同时，该查询用`9.01`填充没有数据的时间间隔，并将返回的`point`个数和series个数分别限制为4和1。

  请注意，`GROUP BY time()`子句会覆盖`point`的原始时间戳。查询结果中的时间戳表示每12分钟时间间隔的开始时间，其中，第一个`point`涵盖的时间间隔在`2020-08-17T23:48:00Z`和`2021-09-28T00:00:00Z`之间，最后一个`point`涵盖的时间间隔在`2020-08-18T00:24:00Z`和`2020-08-18T00:36:00Z`之间。

- ### PERCENTILE()

  返回第N个百分位数的`field value`

  #### 语法

  ```
  SELECT PERCENTILE(<field_key>, <N>)[,<tag_key(s)>|<field_key(s)>] [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `PERCENTILE(field_key,N)`返回指定field key对应的第N个百分位数的field value。

  `PERCENTILE(/regular_expression/,N)`返回与正则表达式匹配的每个field key对应的第N个百分位数的field value。

  `PERCENTILE(*,N)`返回在measurement中每个field key对应的第N个百分位数的field value。

  `PERCENTILE(field_key,N),tag_key(s),field_key(s)`返回括号中的field key对应的第N个百分位数的field value，以及相关的tag和/或field。

  `N`必须是0到100之间的整数或浮点数。

  `PERCENTILE()`支持数据类型为int64和float64的field value。

  #### 示例

  - #### 选择指定field key对应的第五个百分位数的field value

  ```sql
  > SELECT PERCENTILE("temperature",5) FROM "air"

  name: air
  time                 percentile
  ----                 ----------
  2021-09-03T23:51:00Z 51
  ```

  该查询返回的field value大于measurement `air`中field key `temperature`对应的所有field value中的百分之五。

  - #### 选择measurement中每个field key对应的第五个百分位数的field value

  ```sql
  > SELECT PERCENTILE(*,5) FROM "air"

  name: air
  time                 percentile_pressure percentile_temperature percentile_visibility
  ----                 ------------------- ---------------------- ---------------------
  1970-01-01T00:00:00Z 51                  51                     51
  ```

  该查询返回的field value大于measurement `air`中每个存储数值的field key对应的所有field value中的百分之五。。measurement `air`中有三个数值类型的field：`temperature`、`pressure`以及`visibility`。

  - #### 选择与正则表达式匹配的每个field key对应的第五个百分位数的field value

  ```sql
  > SELECT PERCENTILE(/visi/,5) FROM "air"
  name: air
  time                 percentile_visibility
  ----                 ---------------------
  2021-09-29T09:54:00Z 51
  ```

  该查询返回的field value大于measurement `air`中每个存储数值并包含单词`water`的field key对应的所有field value中的百分之五。

  - #### 选择指定field key对应的第五个百分位数的field value以及相关的tag和field

  ```sql
  > SELECT PERCENTILE("temperature",5),"station","pressure" FROM "air"
  name: air
  time                 percentile station    pressure
  ----                 ---------- -------    --------
  2021-09-03T23:51:00Z 51         XiaoMaiDao 65
  ```

  该查询返回的field value大于measurement `air`中field key `temperature`对应的所有field value中的百分之五，以及相关的tag key `station`和field key `pressure`的值。

  - #### 选择指定field key对应的第20个百分位数的field value并包含多个子句

  ```sql
  > SELECT PERCENTILE("temperature",20) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-28T00:54:00Z' GROUP BY time(24m) fill(15) LIMIT 2
  name: air
  time                 percentile
  ----                 ----------
  2020-08-17T23:36:00Z 15
  2020-08-18T00:00:00Z 15
  ```

  该查询返回的field value大于measurement `air`中field key `temperature`对应的所有field value中的百分之二十，它涵盖的时间范围在`2020-08-17T23:48:00Z`和`2020-08-18T00:54:00Z`之间，并将查询结果按24分钟的时间间隔进行分组，同时，该查询用`15`填充没有数据的时间间隔，并将返回的`point`个数限制为2。

  请注意，`GROUP BY time()`子句会覆盖`point`的原始时间戳。查询结果中的时间戳表示每24分钟时间间隔的开始时间，其中，第一个`point`涵盖的时间间隔在`2020-08-17T23:36:00Z`和`2021-09-28T00:00:00Z`之间，最后一个`point`涵盖的时间间隔在`2021-09-28T00:00:00Z`和`2020-08-18T00:24:00Z`之间。

  #### `PERCENTILE()`的常见问题

  - #### `PERCENTILE()` vs 其它cnosQL函数

  * `PERCENTILE(<field_key>,100)`相当于`MAX(<field_key>)`。
  * `PERCENTILE(<field_key>, 50)`近似于`MEDIAN(<field_key>)`，除非field key包含的field value有偶数个，那么这时候`MEDIAN()`将返回两个中间值的平均数。
  * `PERCENTILE(<field_key>,0)`不等于`MIN(<field_key>)`，`PERCENTILE(<field_key>,0)`会返回`null`。

- ### SAMPLE()

  返回包含N个field value的随机样本。`SAMPLE()`使用[reservoir sampling](https://en.wikipedia.org/wiki/Reservoir_sampling)来生成随机`point`。

  #### 语法

  ```
  SELECT SAMPLE(<field_key>, <N>)[,<tag_key(s)>|<field_key(s)>] [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `SAMPLE(field_key,N)`返回指定field key对应的N个随机选择的field value。

  `SAMPLE(/regular_expression/,N)`返回与正则表达式匹配的每个field key对应的N个随机选择的field value。

  `SAMPLE(*,N)`返回在measurement中每个field key对应的N个随机选择的field value。

  `SAMPLE(field_key,N),tag_key(s),field_key(s)`返回括号中的field key对应的N个随机选择的field value，以及相关的tag和/或field。

  `N`必须是整数。

  `SAMPLE()`支持所有数据类型的field value。

  #### 示例

  - #### 选择指定field key对应的field value的随机样本

  ```sql
  > SELECT SAMPLE("temperature",2) FROM "air"
  name: air
  time                 sample
  ----                 ------
  2021-09-07T02:18:00Z 77
  2021-09-13T12:00:00Z 62
  ```

  该查询返回measurement `air`中field key `temperature`对应的两个随机选择的`point`。

  - #### 选择measurement中每个field key对应的field value的随机样本

  ```sql
  > SELECT SAMPLE(*,2) FROM "air"
  name: air
  time                 sample_pressure sample_temperature sample_visibility
  ----                 --------------- ------------------ -----------------
  2021-08-31T16:18:00Z                 52                 
  2021-09-03T14:33:00Z 74                                 
  2021-09-12T19:39:00Z 59                                 
  2021-09-17T11:33:00Z                 51                 
  2021-09-20T04:09:00Z                                    50
  2021-09-22T19:15:00Z                                    80
  ```

  该查询返回measurement `air`中每个field key对应的两个随机选择的`point`。measurement `air`中有两个field key：`pressure`和`temperature`。

  - #### 选择与正则表达式匹配的每个field key对应的field value的随机样本

  ```sql
  > SELECT SAMPLE(/pres/,2) FROM "air"
  name: air
  time                 sample_pressure
  ----                 ---------------
  2021-09-25T20:27:00Z 77
  2021-09-26T20:33:00Z 52
  ```

  该查询返回measurement `air`中每个包含单词`level`的field key对应的两个随机选择的`point`。

  - #### 选择指定field key对应的field value的随机样本以及相关的tag和field

  ```sql
  > SELECT SAMPLE("temperature",2),"station","pressure" FROM "air"
  name: air
  time                 sample station     pressure
  ----                 ------ -------     --------
  2021-09-09T00:03:00Z 71     LianYunGang 61
  2021-09-11T01:39:00Z 53     LianYunGang 51
  ```

  该查询返回measurement `air`中field key `temperature`对应的两个随机选择的`point`，以及相关的tag key `station`和field key `pressure`的值。

  - #### 选择指定field key对应field value的随机样本并包含多个子句

  ```sql
  > SELECT SAMPLE("temperature",1) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(18m)
  name: air
  time                 sample
  ----                 ------
  2021-09-18T00:09:00Z 55
  2021-09-18T00:27:00Z 79
  ```

  该查询返回measurement `air`中field key `temperature`对应的一个随机选择的`point`，它涵盖的时间范围在`2021-09-28T00:00:00Z`和`2021-09-18T00:30:00Z`之间，并将查询结果按18分钟的时间间隔进行分组。

  请注意，`GROUP BY time()`子句不会覆盖`point`的原始时间戳。请查看下面章节获得更详细的说明。

  #### `SAMPLE()`的常见问题

  - #### `SAMPLE()`和`GROUP BY time()`子句同时使用

  对于同时带有`SAMPLE()`和`GROUP BY time()`子句的查询，将返回每个`GROUP BY time()`时间间隔的指定个数(`N`)的`point`。对于大多数`GROUP BY time()`查询，返回的时间戳表示`GROUP BY time()`时间间隔的开始时间，但是，带有`SAMPLE()`函数的`GROUP BY time()`查询则不一样，它们保留原始`point`的时间戳。

  以下查询返回每18分钟`GROUP BY time()`间隔对应的两个随机选择的`point`。请注意，返回的时间戳是`point`的原始时间戳；它们不会被强制要求必须匹配`GROUP BY time()`间隔的开始时间。

  ```sql
  > SELECT SAMPLE("temperature",2) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(18m)
  name: air
  time                   sample
  ----                   ------
                             __
  2021-09-18T00:09:00Z      55   |
  2021-09-18T00:12:00Z      63   | <------- Randomly-selected points for the first time interval
                             --
                             __
  2021-09-18T00:18:00Z      79  |
  2021-09-18T00:21:00Z      68  | <------- Randomly-selected points for the second time interval
                             --
  ```

- ### TOP()

  返回最大的N个field value

  #### 语法
  ```
  SELECT TOP( <field_key>[,<tag_key(s)>],<N> )[,<tag_key(s)>|<field_key(s)>] [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `TOP(field_key,N)`返回field key对应的最大的N个值。

  `TOP(field_key,tag_key(s),N)`返回tag key的N个tag value对应的field key的最大值。

  `TOP(field_key,N),tag_key(s),field_key(s)`返回括号中的field key对应的最大的N个值，以及相关的tag和/或field。

  `TOP()`支持数据类型为int64和float64的field value。

  **注意：**

  * 如果最大值有两个或多个并且它们之间有关联，`TOP()`返回具有最早时间戳的field value。
  #### 示例

  - #### 选择指定field key对应的最大的三个值

  ```sql
  > SELECT TOP("temperature",3) FROM "air"
  name: air
  time                 top
  ----                 ---
  2021-08-31T18:03:00Z 80
  2021-08-31T18:18:00Z 80
  2021-08-31T18:57:00Z 80
  ```

  该查询返回measurement `air`中field key `temperature`对应的最大的三个值。

  - #### 选择两个tag对应的field key的最大值
  ```sql
  > SELECT TOP("temperature","station",2) FROM "air"
  name: air
  time                 top station
  ----                 --- -------
  2021-08-31T18:03:00Z 80  LianYunGang
  2021-08-31T18:18:00Z 80  XiaoMaiDao
  ```

  该查询返回tag key `station`的两个tag value对应的field key `temperature`的最大值。

  - #### 选择指定field key对应的最大的四个值以及相关的tag和field

  ```sql
  > SELECT TOP("temperature",4),"station","pressure" FROM "air"
  name: air
  time                 top station     pressure
  ----                 --- -------     --------
  2021-08-31T18:03:00Z 80  LianYunGang 74
  2021-08-31T18:18:00Z 80  XiaoMaiDao  53
  2021-08-31T18:57:00Z 80  LianYunGang 51
  2021-08-31T20:15:00Z 80  XiaoMaiDao  53
    ```

  该查询返回field key `temperature`对应的最大的四个值，以及相关的tag key `station`和field key `pressure`的值。

  - #### 选择指定field key对应的最大的三个值并包含多个子句

  ```sql
  > SELECT TOP("temperature",3),"station" FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:54:00Z' GROUP BY time(24m) ORDER BY time DESC
  name: air
  time                 top station
  ----                 --- -------
  2021-09-18T00:54:00Z 79  XiaoMaiDao
  2021-09-18T00:51:00Z 71  XiaoMaiDao
  2021-09-18T00:48:00Z 77  LianYunGang
  2021-09-18T00:30:00Z 75  LianYunGang
  2021-09-18T00:27:00Z 79  LianYunGang
  2021-09-18T00:24:00Z 70  LianYunGang
  2021-09-18T00:18:00Z 79  LianYunGang
  2021-09-18T00:09:00Z 80  XiaoMaiDao
  2021-09-18T00:00:00Z 77  XiaoMaiDao
  ```

  该查询返回在`2021-09-28T00:00:00Z`和`2020-08-18T00:54:00Z`之间的每个24分钟间隔内，field key `temperature`对应的最大的三个值，并且以递减的时间戳顺序返回结果。

  请注意，`GROUP BY time()`子句不会覆盖`point`的原始时间戳。请查看下面章节获得更详细的说明。

  #### `TOP()`的常见问题

  - #### `TOP()`和`GROUP BY time()`子句同时使用

  对于同时带有`TOP()`和`GROUP BY time()`子句的查询，将返回每个`GROUP BY time()`时间间隔的指定个数的`point`。对于大多数`GROUP BY time()`查询，返回的时间戳表示`GROUP BY time()`时间间隔的开始时间，但是，带有`TOP()`函数的`GROUP BY time()`查询则不一样，它们保留原始`point`的时间戳。

  以下查询返回每18分钟`GROUP BY time()`间隔对应的两个`point`。请注意，返回的时间戳是`point`的原始时间戳；它们不会被强制要求必须匹配`GROUP BY time()`间隔的开始时间。

  ```sql
  > SELECT TOP("temperature",2) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(18m)
  
  name: air
  time                   top
  ----                   ------
                          __
  2021-09-18T00:12:00Z    63   |
  2021-09-18T00:15:00Z    74   | <------- Greatest points for the first time interval
                          --
                          __
  2021-09-18T00:18:00Z    79   |
  2021-09-18T00:27:00Z   79    | <------- Greatest points for the second time interval
                          --
  ```

  - #### `TOP()`和具有少于N个tag value的tag key

  使用语法`SELECT TOP(<field_key>,<tag_key>,<N>)`的查询可以返回比预期少的`point`。如果tag key有`X`个tag value，但是查询指定的是`N`个tag value，如果`X`小于`N`，那么查询将返回`X`个`point`。

  以下查询请求的是tag key `station`的三个tag value对于的`temperature`的最大值。因为tag key `station`只有两个tag value(`LianYunGang`和`XiaoMaiDao`)，所以该查询返回两个`point`而不是三个。

  ```sql
  > SELECT TOP("temperature","station",3) FROM "air"
  name: air
  time                 top station
  ----                 --- -------
  2021-08-31T18:03:00Z 80  LianYunGang
  2021-08-31T18:18:00Z 80  XiaoMaiDao
  ```

  - #### `TOP()`、tag和`INTO`子句

  当使用`INTO`子句但没有使用`GROUP BY tag`子句时，大多数cnosQL函数将原始数据中的tag转换为新写入数据中的field。这种行为同样适用于`TOP()`函数，除非`TOP()`中包含tag key作为参数：`TOP(field_key,tag_key(s),N)`。在这些情况下，系统会将指定的tag保留为新写入数据中的tag。

  下面代码块中的第一个查询返回tag key `station`的两个tag value对应的field key `temperature`的最大值，并且，它这些结果写入measurement `top_temperatures`中。第二个查询展示了CnosDB将tag `station`保留为measurement `top_temperatures`中的tag。

  ```sql
  > SELECT TOP("temperature","station",2) INTO "top_temperatures" FROM "air"
  name: result
  time                 written
  ----                 -------
  1970-01-01T00:00:00Z 2
  
  > SHOW TAG KEYS FROM "top_temperatures"
  name: top_temperatures
  tagKey
  ------
  station
  ```
### 转换函数

- ### ABS()

  返回field value的绝对值

  #### 基本语法

  ```sql
  SELECT ABS( [ * | <field_key> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `ABS(field_key)`返回field key对应的field value的绝对值。

  `ABS(*)`返回在measurement中每个field key对应的field value的绝对值。

  `ABS()`支持数据类型为int64和float64的field value。

  基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`ABS()`和`GROUP BY time()`子句。

  #### 示例

  下面的示例将使用[示例数据](https://gist.github.com/sanderson/8f8aec94a60b2c31a61f44a37737bfea)中的如下数据：

  ```sql
  > SELECT * FROM "air" WHERE time >= '2021-09-24T12:00:00Z' AND time <= '2021-09-24T12:05:00Z'
  name: air
  time                 pressure station     temperature visibility
  ----                 -------- -------     ----------- ----------
  2021-09-24T12:00:00Z 76       LianYunGang 61          59
  2021-09-24T12:00:00Z 58       XiaoMaiDao  52          77
  2021-09-24T12:03:00Z 64       LianYunGang 57          72
  2021-09-24T12:03:00Z 50       XiaoMaiDao  70          77
  ```

  - #### 计算指定field key对应的field value的绝对值

  ```sql
  > SELECT ABS("pressure") FROM "air" WHERE time >= '2021-09-24T12:00:00Z' AND time <= '2021-09-24T12:05:00Z'
  name: air
  time                 abs
  ----                 ---
  2021-09-24T12:00:00Z 76
  2021-09-24T12:00:00Z 58
  2021-09-24T12:03:00Z 64
  2021-09-24T12:03:00Z 50
  ```

  该查询返回measurement `data`中field key `a`对应的field value的绝对值。

- #### 计算measurement中每个field key对应的field value的绝对值

  ```sql
  > SELECT ABS(*) FROM "air" WHERE time >= '2021-09-24T12:00:00Z' AND time <= '2021-09-24T12:05:00Z'
  name: air
  time                 abs_pressure abs_temperature abs_visibility
  ----                 ------------ --------------- --------------
  2021-09-24T12:00:00Z 76           61              59
  2021-09-24T12:00:00Z 58           52              77
  2021-09-24T12:03:00Z 64           57              72
  2021-09-24T12:03:00Z 50           70              77
  ```

  该查询返回measurement `data`中每个存储数值的field key对应的field value的绝对值。measurement `air`中有三个数值类型的field：`temperature`,`pressure`和`visibility`。

- #### 计算指定field key对应的field value的绝对值并包含多个子句

  ```sql
  > SELECT ABS("pressure") FROM "air" WHERE time >= '2021-09-24T12:00:00Z' AND time <= '2021-09-24T12:05:00Z' ORDER BY time DESC LIMIT 4 OFFSET 2
  name: air
  time                 abs
  ----                 ---
  2021-09-24T12:00:00Z 58
  2021-09-24T12:00:00Z 76
  ```

  该查询返回measurement `data`中field key `a`对应的field value的绝对值，它涵盖的时间范围在`2020-06-24T12:00:00Z`和`2020-06-24T12:05:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的`point`个数限制为4，并将返回的`point`偏移两个（即前两个`point`不返回）。

  #### 高级语法

  ```sql
  SELECT ABS(<function>( [ * | <field_key> ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  高级语法需要一个`GROUP BY time()`子句和一个嵌套的cnosQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的绝对值。

  `ABS()`支持以下嵌套函数：

  - [`COUNT()`](#count)
  - [`MEAN()`](#mean)
  - [`MEDIAN()`](#median)
  - [`MODE()`](#mode)
  - [`SUM()`](#sum)
  - [`FIRST()`](#first)
  - [`LAST()`](#last)
  - [`MIN()`](#min)
  - [`MAX()`](#max)
  - [`PERCENTILE()`](#percentile)

  #### 计算平均值的绝对值

  ```sql
  > SELECT ABS(MEAN("temperature")) FROM "air" WHERE time >= '2021-09-24T12:00:00Z' AND time <= '2021-09-24T13:00:00Z' GROUP BY time(12m)
  name: air
  time                 abs
  ----                 ---
  2021-09-24T12:00:00Z 62.75
  2021-09-24T12:12:00Z 64.25
  2021-09-24T12:24:00Z 66
  2021-09-24T12:36:00Z 64.375
  2021-09-24T12:48:00Z 63.875
  2021-09-24T13:00:00Z 59.5
  ```

  该查询返回field key `a`对应的每12分钟的时间间隔的field value的平均值的绝对值。

  为了得到这些结果，CnosDB首先计算field key `a`对应的每12分钟的时间间隔的field value的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`ABS()`的情形一样：

  ```sql
  > SELECT MEAN("pressure") FROM "air" WHERE time >= '2021-09-24T12:00:00Z' AND time <= '2021-09-24T13:00:00Z' GROUP BY time(12m)
  name: air
  time                 mean
  ----                 ----
  2021-09-24T12:00:00Z 61.75
  2021-09-24T12:12:00Z 68.25
  2021-09-24T12:24:00Z 66.125
  2021-09-24T12:36:00Z 58
  2021-09-24T12:48:00Z 68.625
  2021-09-24T13:00:00Z 71
  ```

  然后，CnosDB计算这些平均值的绝对值。

- ### ACOS()

  返回field value的反余弦(以弧度表示)。field value必须在-1和1之间。

  #### 基本语法

  ```
  SELECT ACOS( [ * | <field_key> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `ACOS(field_key)`返回field key对应的field value的反余弦。

  `ACOS(*)`返回在measurement中每个field key对应的field value的反余弦。

  `ACOS()`支持数据类型为int64和float64的field value，并且field value必须在-1和1之间。

  基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`ACOS()`和`GROUP BY time()`子句。

  #### 示例

  下面的示例将使用如下模拟的公园占有率(相对于总空间)的数据。需要注意的重要事项是，所有的field value都在`ACOS()`函数的可计算范围里(-1到1)：

  ```sql
  > SELECT "temperature" FROM "air" WHERE time >= '2021-09-11T00:00:00Z' AND time <= '2021-09-19T00:00:00Z'
  name: air
  time                  capacity
  ----                  --------
  2020-05-01T00:00:00Z  0.83
  2020-05-02T00:00:00Z  0.3
  2020-05-03T00:00:00Z  0.84
  2020-05-04T00:00:00Z  0.22
  2020-05-05T00:00:00Z  0.17
  2020-05-06T00:00:00Z  0.77
  2020-05-07T00:00:00Z  0.64
  2020-05-08T00:00:00Z  0.72
  2020-05-09T00:00:00Z  0.16
  ```

  - #### 计算指定field key对应的field value的反余弦

  ```sql
  > SELECT ACOS("temperature") FROM "air" WHERE time >= '2021-09-11T00:00:00Z' AND time <= '2021-09-19T00:00:00Z'
  name: air
  time                  acos
  ----                  ----
  2020-05-01T00:00:00Z  0.591688642426544
  2020-05-02T00:00:00Z  1.266103672779499
  2020-05-03T00:00:00Z  0.5735131044230969
  2020-05-04T00:00:00Z  1.3489818562981022
  2020-05-05T00:00:00Z  1.399966657665792
  2020-05-06T00:00:00Z  0.6919551751263169
  2020-05-07T00:00:00Z  0.8762980611683406
  2020-05-08T00:00:00Z  0.7669940078618667
  2020-05-09T00:00:00Z  1.410105673842986
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的反余弦。

  - #### 计算measurement中每个field key对应的field value的反余弦

  ```sql
  > SELECT ACOS(*) FROM "air" WHERE time >= '2021-09-11T00:00:00Z' AND time <= '2021-09-11T01:00:00Z'
  name: air
  time                 acos_pressure acos_temperature acos_visibility
  ----                 ------------- ---------------- ---------------
  2021-09-11T00:00:00Z                                
  2021-09-11T00:00:00Z                                
  2021-09-11T00:03:00Z                                
  2021-09-11T00:03:00Z                                
  2021-09-11T00:06:00Z                                
  2021-09-11T00:06:00Z                                
  2021-09-11T00:09:00Z                                
  2021-09-11T00:09:00Z                                
  2021-09-11T00:12:00Z                                
  2021-09-11T00:12:00Z                                
  2021-09-11T00:15:00Z                                
  2021-09-11T00:15:00Z                                
  2021-09-11T00:18:00Z                                
  2021-09-11T00:18:00Z                                
  2021-09-11T00:21:00Z                                
  2021-09-11T00:21:00Z                                
  2021-09-11T00:24:00Z                                
  2021-09-11T00:24:00Z                                
  2021-09-11T00:27:00Z                                
  2021-09-11T00:27:00Z                                
  2021-09-11T00:30:00Z                                
  2021-09-11T00:30:00Z                                
  2021-09-11T00:33:00Z                                
  2021-09-11T00:33:00Z                                
  2021-09-11T00:36:00Z                                
  2021-09-11T00:36:00Z                                
  2021-09-11T00:39:00Z                                
  2021-09-11T00:39:00Z                                
  2021-09-11T00:42:00Z                                
  2021-09-11T00:42:00Z                                
  2021-09-11T00:45:00Z                                
  2021-09-11T00:45:00Z                                
  2021-09-11T00:48:00Z                                
  2021-09-11T00:48:00Z                                
  2021-09-11T00:51:00Z                                
  2021-09-11T00:51:00Z                                
  2021-09-11T00:54:00Z                                
  2021-09-11T00:54:00Z                                
  2021-09-11T00:57:00Z                                
  2021-09-11T00:57:00Z                                
  2021-09-11T01:00:00Z                                
  2021-09-11T01:00:00Z
  ```

  该查询返回measurement `air`中每个存储数值的field key对应的field value的反余弦。。measurement `air`中有三个数值类型的field：`temperature`、`pressure`以及`visibility`。但由于这三个field key对应的field value超过余弦函数的范围，因此其反余弦值并不存在。

  - #### 计算指定field key对应的field value的反余弦并包含多个子句

  ```sql
  > SELECT ACOS(temperature/100) FROM "air" WHERE time >= '2021-09-11T00:00:00Z' AND time <= '2021-09-19T00:00:00Z' ORDER BY time DESC LIMIT 4 OFFSET 2
  name: air
  time                 acos
  ----                 ----
  2021-09-18T23:57:00Z 0.6435011087932843
  2021-09-18T23:57:00Z 0.6599873293874983
  2021-09-18T23:54:00Z 0.7669940078618667
  2021-09-18T23:54:00Z 1.0003592173949745
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的反余弦，它涵盖的时间范围在`2020-05-01T00:00:00Z`和`2020-05-09T00:00:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的`point`个数限制为4，并将返回的`point`偏移两个（即前两个`point`不返回）。

  #### 高级语法

  ```sql
  SELECT ACOS(<function>( [ * | <field_key> ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  高级语法需要一个`GROUP BY time()`子句和一个嵌套的cnosQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的反余弦。

  ACOS()支持以下嵌套函数：

  - [`COUNT()`](#count)
  - [`MEAN()`](#mean)
  - [`MEDIAN()`](#median)
  - [`MODE()`](#mode)
  - [`SUM()`](#sum)
  - [`FIRST()`](#first)
  - [`LAST()`](#last)
  - [`MIN()`](#min)
  - [`MAX()`](#max)
  - [`PERCENTILE()`](#percentile)

  ####示例

  -  #### 计算平均值的反余弦

  ```sql
  > SELECT ACOS(MEAN("temperature")) FROM "air" WHERE time >= '2021-09-11T00:00:00Z' AND time <= '2021-09-19T00:00:00Z' GROUP BY time(3d)
  name: air
  time                 acos
  ----                 ----
  2021-09-09T00:00:00Z
  2021-09-12T00:00:00Z
  2021-09-15T00:00:00Z
  2021-09-18T00:00:00Z  、
  ```

  该查询返回field key `temperature`对应的每三天的时间间隔的field value的平均值的反余弦。

  为了得到这些结果，CnosDB首先计算field key `temperature`对应的每三天的时间间隔的field value的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`ACOS()`的情形一样：

  ```sql
  > SELECT MEAN("temperature") FROM "air" WHERE time >= '2021-09-11T00:00:00Z' AND time <= '2021-09-19T00:00:00Z' GROUP BY time(3d)
  name: air
  time                 mean
  ----                 ----
  2021-09-09T00:00:00Z 65.26041666666667
  2021-09-12T00:00:00Z 64.96944444444445
  2021-09-15T00:00:00Z 65.00902777777777
  2021-09-18T00:00:00Z 65.32952182952182
  ```

  然后，CnosDB计算这些平均值的反余弦。

- ### ASIN()

  返回field value的反正弦(以弧度表示)。field value必须在-1和1之间。

  #### 基本语法

  ```
  SELECT ASIN( [ * | <field_key> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `ASIN(field_key)`返回field key对应的field value的反正弦。

  `ASIN(*)`返回在measurement中每个field key对应的field value的反正弦。

  `ASIN()`支持数据类型为int64和float64的field value，并且field value必须在-1和1之间。

  基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`ASIN()`和`GROUP BY time()`子句。

  #### 示例

  ```sql
  > SELECT "temperature" FROM "air" WHERE time >= '2021-09-11T00:00:00Z' AND time <= '2021-09-11T01:00:00Z'
  name: air
  time                 temperature
  ----                 -----------
  2021-09-11T00:00:00Z 74
  2021-09-11T00:00:00Z 79
  2021-09-11T00:03:00Z 61
  2021-09-11T00:03:00Z 73
  2021-09-11T00:06:00Z 72
  2021-09-11T00:06:00Z 61
  2021-09-11T00:09:00Z 61
  2021-09-11T00:09:00Z 72
  2021-09-11T00:12:00Z 52
  2021-09-11T00:12:00Z 58
  2021-09-11T00:15:00Z 74
  2021-09-11T00:15:00Z 78
  2021-09-11T00:18:00Z 67
  2021-09-11T00:18:00Z 74
  2021-09-11T00:21:00Z 71
  2021-09-11T00:21:00Z 55
  2021-09-11T00:24:00Z 66
  2021-09-11T00:24:00Z 67
  2021-09-11T00:27:00Z 72
  2021-09-11T00:27:00Z 66
  2021-09-11T00:30:00Z 61
  2021-09-11T00:30:00Z 54
  2021-09-11T00:33:00Z 55
  2021-09-11T00:33:00Z 75
  2021-09-11T00:36:00Z 65
  2021-09-11T00:36:00Z 66
  2021-09-11T00:39:00Z 68
  2021-09-11T00:39:00Z 58
  2021-09-11T00:42:00Z 59
  2021-09-11T00:42:00Z 58
  2021-09-11T00:45:00Z 69
  2021-09-11T00:45:00Z 71
  2021-09-11T00:48:00Z 69
  2021-09-11T00:48:00Z 57
  2021-09-11T00:51:00Z 55
  2021-09-11T00:51:00Z 73
  2021-09-11T00:54:00Z 69
  2021-09-11T00:54:00Z 64
  2021-09-11T00:57:00Z 73
  2021-09-11T00:57:00Z 52
  2021-09-11T01:00:00Z 59
  2021-09-11T01:00:00Z 68
  ```

  - #### 计算指定field key对应的field value的反正弦

  ```sql
  > SELECT ASIN(temperature/100) FROM "air" WHERE time >= '2021-09-11T00:00:00Z' AND time <= '2021-09-11T01:00:00Z'
  name: air
  time                 asin
  ----                 ----
  2021-09-11T00:00:00Z 0.8330703583416478
  2021-09-11T00:00:00Z 0.9108089974073983
  2021-09-11T00:03:00Z 0.6560605909249226
  2021-09-11T00:03:00Z 0.8183219506315597
  2021-09-11T00:06:00Z 0.8038023189330299
  2021-09-11T00:06:00Z 0.6560605909249226
  2021-09-11T00:09:00Z 0.6560605909249226
  2021-09-11T00:09:00Z 0.8038023189330299
  2021-09-11T00:12:00Z 0.546850950695944
  2021-09-11T00:12:00Z 0.618728690672251
  2021-09-11T00:15:00Z 0.8330703583416478
  2021-09-11T00:15:00Z 0.8946658172342352
  2021-09-11T00:18:00Z 0.7342087874533589
  2021-09-11T00:18:00Z 0.8330703583416478
  2021-09-11T00:21:00Z 0.7894982093461719
  2021-09-11T00:21:00Z 0.5823642378687435
  2021-09-11T00:24:00Z 0.7208187608700896
  2021-09-11T00:24:00Z 0.7342087874533589
  2021-09-11T00:27:00Z 0.8038023189330299
  2021-09-11T00:27:00Z 0.7208187608700896
  2021-09-11T00:30:00Z 0.6560605909249226
  2021-09-11T00:30:00Z 0.570437109399922
  2021-09-11T00:33:00Z 0.5823642378687435
  2021-09-11T00:33:00Z 0.848062078981481
  2021-09-11T00:36:00Z 0.7075844367253555
  2021-09-11T00:36:00Z 0.7208187608700896
  2021-09-11T00:39:00Z 0.7477626346599205
  2021-09-11T00:39:00Z 0.618728690672251
  2021-09-11T00:42:00Z 0.6310588407780212
  2021-09-11T00:42:00Z 0.618728690672251
  2021-09-11T00:45:00Z 0.7614890527476331
  2021-09-11T00:45:00Z 0.7894982093461719
  2021-09-11T00:48:00Z 0.7614890527476331
  2021-09-11T00:48:00Z 0.6065058552130869
  2021-09-11T00:51:00Z 0.5823642378687435
  2021-09-11T00:51:00Z 0.8183219506315597
  2021-09-11T00:54:00Z 0.7614890527476331
  2021-09-11T00:54:00Z 0.6944982656265559
  2021-09-11T00:57:00Z 0.8183219506315597
  2021-09-11T00:57:00Z 0.546850950695944
  2021-09-11T01:00:00Z 0.6310588407780212
  2021-09-11T01:00:00Z 0.7477626346599205    
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的反正弦。

  - #### 计算measurement中每个field key对应的field value的反正弦

  ```sql
  > SELECT ASIN(*) FROM "air" WHERE time >= '2021-09-11T00:00:00Z' AND time <= '2021-09-11T01:00:00Z'
  name: air
  time                 asin_pressure asin_temperature asin_visibility
  ----                 ------------- ---------------- ---------------
  2021-09-11T00:00:00Z                                
  2021-09-11T00:00:00Z                                
  2021-09-11T00:03:00Z                                
  2021-09-11T00:03:00Z                                
  2021-09-11T00:06:00Z                                
  2021-09-11T00:06:00Z                                
  2021-09-11T00:09:00Z                                
  2021-09-11T00:09:00Z                                
  2021-09-11T00:12:00Z                                
  2021-09-11T00:12:00Z                                
  2021-09-11T00:15:00Z                                
  2021-09-11T00:15:00Z                                
  2021-09-11T00:18:00Z                                
  2021-09-11T00:18:00Z                                
  2021-09-11T00:21:00Z                                
  2021-09-11T00:21:00Z                                
  2021-09-11T00:24:00Z                                
  2021-09-11T00:24:00Z                                
  2021-09-11T00:27:00Z                                
  2021-09-11T00:27:00Z                                
  2021-09-11T00:30:00Z                                
  2021-09-11T00:30:00Z                                
  2021-09-11T00:33:00Z                                
  2021-09-11T00:33:00Z                                
  2021-09-11T00:36:00Z                                
  2021-09-11T00:36:00Z                                
  2021-09-11T00:39:00Z                                
  2021-09-11T00:39:00Z                                
  2021-09-11T00:42:00Z                                
  2021-09-11T00:42:00Z                                
  2021-09-11T00:45:00Z                                
  2021-09-11T00:45:00Z                                
  2021-09-11T00:48:00Z                                
  2021-09-11T00:48:00Z                                
  2021-09-11T00:51:00Z                                
  2021-09-11T00:51:00Z                                
  2021-09-11T00:54:00Z                                
  2021-09-11T00:54:00Z                                
  2021-09-11T00:57:00Z                                
  2021-09-11T00:57:00Z                                
  2021-09-11T01:00:00Z                                
  2021-09-11T01:00:00Z
  ```
  该查询返回measurement `air`中每个存储数值的field key对应的field value的反正弦。。measurement `air`中有三个数值类型的field：`temperature`、`pressure`以及`visibility`。但是由于这三个field value全部大于1，因此其反正弦值不存在。

  - #### 计算指定field key对应的field value的反正弦并包含多个子句

  ```sql
  > SELECT ASIN(temperature/100) FROM "air" WHERE time >= '2021-09-11T00:00:00Z' AND time <= '2021-09-19T00:00:00Z' ORDER BY time DESC LIMIT 4 OFFSET 2
  name: air
  time                 asin
  ----                 ----
  2021-09-18T23:57:00Z 0.9272952180016123
  2021-09-18T23:57:00Z 0.9108089974073983
  2021-09-18T23:54:00Z 0.8038023189330299
  2021-09-18T23:54:00Z 0.570437109399922
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的反正弦，它涵盖的时间范围在`2020-05-01T00:00:00Z`和`2020-05-09T00:00:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的`point`个数限制为4，并将返回的`point`偏移两个（即前两个`point`不返回）。

  #### 高级语法

  ```sql
  SELECT ASIN(<function>( [ * | <field_key> ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  高级语法需要一个`GROUP BY time()`子句和一个嵌套的cnosQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的反正弦。

  ASIN()支持以下嵌套函数：

  [`COUNT()`](#count),
  [`MEAN()`](#mean),
  [`MEDIAN()`](#median),
  [`MODE()`](#mode),
  [`SUM()`](#sum),
  [`FIRST()`](#first),
  [`LAST()`](#last),
  [`MIN()`](#min),
  [`MAX()`](#max),
  [`PERCENTILE()`](#percentile).

  #### 示例

  - #### 计算平均值的反正弦

  ```sql
  > SELECT ASIN(MEAN("speed")) FROM "wind" WHERE time >= '2021-09-01T00:00:00Z' AND time <= '2021-09-30T00:00:00Z' GROUP BY time(1d)
  name: air
  time                  asin
  ----                  ----
  2020-04-30T00:00:00Z  0.6004332535805232
  2020-05-03T00:00:00Z  0.42245406218675574
  2020-05-06T00:00:00Z  0.7894982093461719
  2020-05-09T00:00:00Z  0.1606906529519106
  ```

  该查询返回field key `temperature`对应的每三天的时间间隔的field value的平均值的反正弦。

  为了得到这些结果，CnosDB首先计算field key `temperature`对应的每三天的时间间隔的field value的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`ASIN()`的情形一样：

  ```sql
  > SELECT MEAN("temperature") FROM "air" WHERE time >= '2021-09-11T00:00:00Z' AND time <= '2021-09-19T00:00:00Z' GROUP BY time(3d)
  name: air
  time                 mean
  ----                 ----
  2021-09-09T00:00:00Z 65.26041666666667
  2021-09-12T00:00:00Z 64.96944444444445
  2021-09-15T00:00:00Z 65.00902777777777
  2021-09-18T00:00:00Z 65.32952182952182
  ```

  然后，CnosDB计算这些平均值的反正弦。

- ### ATAN()

  返回field value的反正切（以弧度表示)。field value必须在-1和1之间。

  #### 基本语法

  ```sql
  SELECT ATAN( [ * | <field_key> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `ATAN(field_key)`返回field key对应的field value的反正切。

  `ATAN(*)`返回在measurement中每个field key对应的field value的反正切。

  `ATAN()`支持数据类型为int64和float64的field value，并且field value必须在-1和1之间。

  基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`ATAN()`和`GROUP BY time()`子句。

  #### 示例

  下面的示例将使用如下模拟的公园占有率(相对于总空间)的数据。需要注意的重要事项是，所有的field value都在`ATAN()`函数的可计算范围里(-1到1)：

  ```sql
  > SELECT "temperature" FROM "air" WHERE time >= '2021-09-11T00:00:00Z' AND time <= '2021-09-11T01:00:00Z'
  name: air
  time                 temperature
  ----                 -----------
  2021-09-11T00:00:00Z 74
  2021-09-11T00:00:00Z 79
  2021-09-11T00:03:00Z 61
  2021-09-11T00:03:00Z 73
  2021-09-11T00:06:00Z 72
  2021-09-11T00:06:00Z 61
  2021-09-11T00:09:00Z 61
  2021-09-11T00:09:00Z 72
  2021-09-11T00:12:00Z 52
  2021-09-11T00:12:00Z 58
  2021-09-11T00:15:00Z 74
  2021-09-11T00:15:00Z 78
  2021-09-11T00:18:00Z 67
  2021-09-11T00:18:00Z 74
  2021-09-11T00:21:00Z 71
  2021-09-11T00:21:00Z 55
  2021-09-11T00:24:00Z 66
  2021-09-11T00:24:00Z 67
  2021-09-11T00:27:00Z 72
  2021-09-11T00:27:00Z 66
  2021-09-11T00:30:00Z 61
  2021-09-11T00:30:00Z 54
  2021-09-11T00:33:00Z 55
  2021-09-11T00:33:00Z 75
  2021-09-11T00:36:00Z 65
  2021-09-11T00:36:00Z 66
  2021-09-11T00:39:00Z 68
  2021-09-11T00:39:00Z 58
  2021-09-11T00:42:00Z 59
  2021-09-11T00:42:00Z 58
  2021-09-11T00:45:00Z 69
  2021-09-11T00:45:00Z 71
  2021-09-11T00:48:00Z 69
  2021-09-11T00:48:00Z 57
  2021-09-11T00:51:00Z 55
  2021-09-11T00:51:00Z 73
  2021-09-11T00:54:00Z 69
  2021-09-11T00:54:00Z 64
  2021-09-11T00:57:00Z 73
  2021-09-11T00:57:00Z 52
  2021-09-11T01:00:00Z 59
  2021-09-11T01:00:00Z 68
  ```

  - #### 计算指定field key对应的field value的反正切

  ```sql
  > SELECT ATAN("temperature") FROM "air" WHERE time >= '2021-09-11T00:00:00Z' AND time <= '2021-09-11T01:00:00Z'
  name: air
  time                 atan
  ----                 ----
  2021-09-11T00:00:00Z 1.5572836357815683
  2021-09-11T00:00:00Z 1.5581387749608446
  2021-09-11T00:03:00Z 1.5544043524868913
  2021-09-11T00:03:00Z 1.5570985534220307
  2021-09-11T00:06:00Z 1.5569083308639295
  2021-09-11T00:06:00Z 1.5544043524868913
  2021-09-11T00:09:00Z 1.5544043524868913
  2021-09-11T00:09:00Z 1.5569083308639295
  2021-09-11T00:12:00Z 1.5515679276951893
  2021-09-11T00:12:00Z 1.5535566556003668
  2021-09-11T00:15:00Z 1.5572836357815683
  2021-09-11T00:15:00Z 1.557976516321996
  2021-09-11T00:18:00Z 1.5558720618048116
  2021-09-11T00:18:00Z 1.5572836357815683
  2021-09-11T00:21:00Z 1.5567127509720364
  2021-09-11T00:21:00Z 1.5526165117219182
  2021-09-11T00:24:00Z 1.5556459709201267
  2021-09-11T00:24:00Z 1.5558720618048116
  2021-09-11T00:27:00Z 1.5569083308639295
  2021-09-11T00:27:00Z 1.5556459709201267
  2021-09-11T00:30:00Z 1.5544043524868913
  2021-09-11T00:30:00Z 1.5522799247268875
  2021-09-11T00:33:00Z 1.5526165117219182
  2021-09-11T00:33:00Z 1.557463783500751
  2021-09-11T00:36:00Z 1.5554129250143014
  2021-09-11T00:36:00Z 1.5556459709201267
  2021-09-11T00:39:00Z 1.5560915044170451
  2021-09-11T00:39:00Z 1.5535566556003668
  2021-09-11T00:42:00Z 1.5538487969884915
  2021-09-11T00:42:00Z 1.5535566556003668
  2021-09-11T00:45:00Z 1.5563045877293966
  2021-09-11T00:45:00Z 1.5567127509720364
  2021-09-11T00:48:00Z 1.5563045877293966
  2021-09-11T00:48:00Z 1.553254266737494
  2021-09-11T00:51:00Z 1.5526165117219182
  2021-09-11T00:51:00Z 1.5570985534220307
  2021-09-11T00:54:00Z 1.5563045877293966
  2021-09-11T00:54:00Z 1.5551725981744198
  2021-09-11T00:57:00Z 1.5570985534220307
  2021-09-11T00:57:00Z 1.5515679276951893
  2021-09-11T01:00:00Z 1.5538487969884915
  2021-09-11T01:00:00Z 1.5560915044170451
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的反正切。

  - #### 计算measurement中每个field key对应的field value的反正切

  ```sql
  > SELECT ATAN(*) FROM "air" WHERE time >= '2021-09-11T00:00:00Z' AND time <= '2021-09-11T01:00:00Z'
  name: air
  time                 atan_pressure      atan_temperature   atan_visibility
  ----                 -------------      ----------------   ---------------
  2021-09-11T00:00:00Z 1.5544043524868913 1.5572836357815683 1.5526165117219182
  2021-09-11T00:00:00Z 1.5576391913221408 1.5581387749608446 1.550798992821746
  2021-09-11T00:03:00Z 1.5535566556003668 1.5544043524868913 1.551190995937692
  2021-09-11T00:03:00Z 1.5541312030809558 1.5570985534220307 1.5581387749608446
  2021-09-11T00:06:00Z 1.5549246438031066 1.5569083308639295 1.5556459709201267
  2021-09-11T00:06:00Z 1.557976516321996  1.5544043524868913 1.5541312030809558
  2021-09-11T00:09:00Z 1.553254266737494  1.5544043524868913 1.5560915044170451
  2021-09-11T00:09:00Z 1.5556459709201267 1.5569083308639295 1.557463783500751
  2021-09-11T00:12:00Z 1.5541312030809558 1.5515679276951893 1.5563045877293966
  2021-09-11T00:12:00Z 1.550798992821746  1.5535566556003668 1.5565115842075
  2021-09-11T00:15:00Z 1.5554129250143014 1.5572836357815683 1.5535566556003668
  2021-09-11T00:15:00Z 1.5572836357815683 1.557976516321996  1.557976516321996
  2021-09-11T00:18:00Z 1.557463783500751  1.5558720618048116 1.5526165117219182
  2021-09-11T00:18:00Z 1.557810043874724  1.5572836357815683 1.551190995937692
  2021-09-11T00:21:00Z 1.5544043524868913 1.5567127509720364 1.552941081655344
  2021-09-11T00:21:00Z 1.5576391913221408 1.5526165117219182 1.5570985534220307
  2021-09-11T00:24:00Z 1.552941081655344  1.5556459709201267 1.5541312030809558
  2021-09-11T00:24:00Z 1.5570985534220307 1.5558720618048116 1.550798992821746
  2021-09-11T00:27:00Z 1.550798992821746  1.5569083308639295 1.552941081655344
  2021-09-11T00:27:00Z 1.5582969777755349 1.5556459709201267 1.5551725981744198
  2021-09-11T00:30:00Z 1.5582969777755349 1.5544043524868913 1.5567127509720364
  2021-09-11T00:30:00Z 1.5549246438031066 1.5522799247268875 1.5546686929512603
  2021-09-11T00:33:00Z 1.5576391913221408 1.5526165117219182 1.5560915044170451
  2021-09-11T00:33:00Z 1.5519306407732258 1.557463783500751  1.5560915044170451
  2021-09-11T00:36:00Z 1.5558720618048116 1.5554129250143014 1.5519306407732258
  2021-09-11T00:36:00Z 1.5560915044170451 1.5556459709201267 1.5563045877293966
  2021-09-11T00:39:00Z 1.5526165117219182 1.5560915044170451 1.5567127509720364
  2021-09-11T00:39:00Z 1.5563045877293966 1.5535566556003668 1.557810043874724
  2021-09-11T00:42:00Z 1.5569083308639295 1.5538487969884915 1.5565115842075
  2021-09-11T00:42:00Z 1.5522799247268875 1.5535566556003668 1.5549246438031066
  2021-09-11T00:45:00Z 1.557810043874724  1.5563045877293966 1.5576391913221408
  2021-09-11T00:45:00Z 1.5560915044170451 1.5567127509720364 1.557810043874724
  2021-09-11T00:48:00Z 1.5535566556003668 1.5563045877293966 1.5551725981744198
  2021-09-11T00:48:00Z 1.5546686929512603 1.553254266737494  1.5560915044170451
  2021-09-11T00:51:00Z 1.5526165117219182 1.5526165117219182 1.5570985534220307
  2021-09-11T00:51:00Z 1.557463783500751  1.5570985534220307 1.5572836357815683
  2021-09-11T00:54:00Z 1.5563045877293966 1.5563045877293966 1.5558720618048116
  2021-09-11T00:54:00Z 1.5538487969884915 1.5551725981744198 1.5544043524868913
  2021-09-11T00:57:00Z 1.5565115842075    1.5570985534220307 1.5572836357815683
  2021-09-11T00:57:00Z 1.5576391913221408 1.5515679276951893 1.5572836357815683
  2021-09-11T01:00:00Z 1.5522799247268875 1.5538487969884915 1.5522799247268875
  2021-09-11T01:00:00Z 1.557810043874724  1.5560915044170451 1.5551725981744198
  ```

  该查询返回measurement `air`中每个存储数值的field key对应的field value的反正切。。measurement `air`中有三个数值类型的field：`temperature`、`pressure`以及`visibility`。

  - #### 计算指定field key对应的field value的反正切并包含多个子句

  ```sql
  > SELECT ATAN("temperature") FROM "air" WHERE time >= '2021-09-11T00:00:00Z' AND time <= '2021-09-19T00:00:00Z' ORDER BY time DESC LIMIT 4 OFFSET 2
  name: air
  time                 atan
  ----                 ----
  2021-09-18T23:57:00Z 1.5582969777755349
  2021-09-18T23:57:00Z 1.5581387749608446
  2021-09-18T23:54:00Z 1.5569083308639295
  2021-09-18T23:54:00Z 1.5522799247268875
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的反正切，它涵盖的时间范围在`2020-05-01T00:00:00Z`和`2020-05-09T00:00:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的`point`个数限制为4，并将返回的`point`偏移两个（即前两个`point`不返回）。

  #### 高级语法

  ```sql
  SELECT ATAN(<function>( [ * | <field_key> ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  高级语法需要一个`GROUP BY time()`子句和一个嵌套的cnosQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的反正切。

  `ATAN()`支持以下嵌套函数：

  - [`COUNT()`](#count)
  - [`MEAN()`](#mean)
  - [`MEDIAN()`](#median)
  - [`MODE()`](#mode)
  - [`SUM()`](#sum)
  - [`FIRST()`](#first)
  - [`LAST()`](#last)
  - [`MIN()`](#min)
  - [`MAX()`](#max)
  - [`PERCENTILE()`](#percentile)

  #### 示例

  - #### 计算平均值的反正切

  ```sql
  > SELECT ATAN(MEAN("temperature")) FROM "air" WHERE time >= '2021-09-11T00:00:00Z' AND time <= '2021-09-19T00:00:00Z' GROUP BY time(3d)
  name: air
  time                 atan
  ----                 ----
  2021-09-09T00:00:00Z 1.5554743016680184
  2021-09-12T00:00:00Z 1.5554056912417906
  2021-09-15T00:00:00Z 1.555415060964228
  2021-09-18T00:00:00Z 1.555490506678637
  ```

  该查询返回field key `temperature`对应的每三天的时间间隔的field value的平均值的反正切。

  为了得到这些结果，CnosDB首先计算field key `temperature`对应的每三天的时间间隔的field value的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`ATAN()`的情形一样：

  ```sql
  > SELECT MEAN("temperature") FROM "air" WHERE time >= '2021-09-11T00:00:00Z' AND time <= '2021-09-19T00:00:00Z' GROUP BY time(3d)
  name: air
  time                 mean
  ----                 ----
  2021-09-09T00:00:00Z 65.26041666666667
  2021-09-12T00:00:00Z 64.96944444444445
  2021-09-15T00:00:00Z 65.00902777777777
  2021-09-18T00:00:00Z 65.32952182952182
  ```

  然后，CnosDB计算这些平均值的反正切。

- ### ATAN2()

  返回以弧度表示的`y/x`的反正切。

  #### 基本语法

  ```
  SELECT ATAN2( [ * | <field_key> | num ], [ <field_key> | num ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `ATAN2(field_key_y, field_key_x)`返回field key “field_key_y”对应的field value除以field key “field_key_x”对应的field value的反正切。

  `ATAN2(*, field_key_x)<br />`返回在measurement中每个field key对应的field value除以field key “field_key_x”对应的field value的反正切。

  `ATAN2()`支持数据类型为int64和float64的field value。

  基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`ATAN2()`和`GROUP BY time()`子句。

  #### 示例

  下面的示例将使用如下模拟的飞行数据：

  ```sql
  > SELECT "temperature", "pressure" FROM "air" WHERE time >= '2021-09-06T12:01:00Z' AND time <= '2021-09-06T12:15:00Z'
  name: air
  time                 temperature pressure
  ----                 ----------- --------
  2021-09-06T12:03:00Z 53          78
  2021-09-06T12:03:00Z 72          71
  2021-09-06T12:06:00Z 69          58
  2021-09-06T12:06:00Z 59          76
  2021-09-06T12:09:00Z 71          55
  2021-09-06T12:09:00Z 57          76
  2021-09-06T12:12:00Z 53          75
  2021-09-06T12:12:00Z 65          52
  2021-09-06T12:15:00Z 69          67
  2021-09-06T12:15:00Z 64          56
  ```

  - #### 计算field_key_y除以field_key_x的反正切

  ```sql
  > SELECT ATAN2("temperature", "pressure") FROM "air" WHERE time >= '2021-09-06T12:01:00Z' AND time <= '2021-09-06T13:01:00Z'
  name: air
  time                 atan2
  ----                 -----
  2021-09-06T12:03:00Z 0.5968259039857009
  2021-09-06T12:03:00Z 0.7923910564027816
  2021-09-06T12:06:00Z 0.8717967127558954
  2021-09-06T12:06:00Z 0.6601315920749263
  2021-09-06T12:09:00Z 0.9117062804606886
  2021-09-06T12:09:00Z 0.6435011087932844
  2021-09-06T12:12:00Z 0.6151862381119739
  2021-09-06T12:12:00Z 0.8960553845713439
  2021-09-06T12:15:00Z 0.8001029857752997
  2021-09-06T12:15:00Z 0.851966327173272
  2021-09-06T12:18:00Z 0.6960841704042261
  2021-09-06T12:18:00Z 0.8010218920179252
  2021-09-06T12:21:00Z 0.7594299761858918
  2021-09-06T12:21:00Z 0.7028792089644667
  2021-09-06T12:24:00Z 0.812418612584713
  2021-09-06T12:24:00Z 0.7309067071567171
  2021-09-06T12:27:00Z 0.9948777271765435
  2021-09-06T12:27:00Z 0.7546386373269791
  2021-09-06T12:30:00Z 0.7785017210090998
  2021-09-06T12:30:00Z 0.6435011087932844
  2021-09-06T12:33:00Z 0.8960553845713439
  2021-09-06T12:33:00Z 0.8007815651780434
  2021-09-06T12:36:00Z 0.8498250028230019
  2021-09-06T12:36:00Z 0.8736040677941312
  2021-09-06T12:39:00Z 0.7168036599431737
  2021-09-06T12:39:00Z 0.9296875579351908
  2021-09-06T12:42:00Z 0.8633647972289906
  2021-09-06T12:42:00Z 0.9437256642058782
  2021-09-06T12:45:00Z 0.6215266244966218
  2021-09-06T12:45:00Z 0.8152400480645576
  2021-09-06T12:48:00Z 0.7378150601204648
  2021-09-06T12:48:00Z 0.7638187798309181
  2021-09-06T12:51:00Z 0.9179496956941223
  2021-09-06T12:51:00Z 0.7935280655773922
  2021-09-06T12:54:00Z 0.9572401812829798
  2021-09-06T12:54:00Z 0.6593100683328579
  2021-09-06T12:57:00Z 0.8674056089236339
  2021-09-06T12:57:00Z 0.8674056089236339
  2021-09-06T13:00:00Z 0.8187191592756955
  2021-09-06T13:00:00Z 0.8134282033572947
  ```

  该查询返回field key `temperature`对应的field value除以field key `pressure`对应的field value的反正切。这两个field key都在measurement `wind`中。

  - #### 计算measurement中每个field key除以field_key_x的反正切

  ```sql
  > SELECT ATAN2(*, "pressure") FROM "air" WHERE time >= '2021-09-06T12:01:00Z' AND time <= '2021-09-06T12:06:00Z'
  name: air
  time                 atan2_pressure     atan2_temperature  atan2_visibility
  ----                 --------------     -----------------  ----------------
  2021-09-06T12:03:00Z 0.7853981633974483 0.5968259039857009 0.60554466360497
  2021-09-06T12:03:00Z 0.7853981633974483 0.7923910564027816 0.7257674502662789
  2021-09-06T12:06:00Z 0.7853981633974483 0.8717967127558954 0.8645972343668997
  2021-09-06T12:06:00Z 0.7853981633974483 0.6601315920749263 0.6435011087932844
  ```

  该查询返回measurement `wind`中每个存储数值的field key对应的field value除以field key `pressure`对应的field value的反正切。measurement `wind`中有两个数值类型的field：`temperature`和`pressure`。

  - #### 计算field value的反正切并包含多个子句

  ```sql
  > SELECT ATAN2("temperature", "pressure") FROM "air" WHERE time >= '2021-09-06T12:01:00Z' AND time <= '2021-09-16T13:01:00Z' ORDER BY time DESC LIMIT 4 OFFSET 2
  name: air
  time                 atan2
  ----                 -----
  2021-09-16T12:57:00Z 0.8773368222796695
  2021-09-16T12:57:00Z 0.8114792046882006
  2021-09-16T12:54:00Z 0.8007815651780434
  2021-09-16T12:54:00Z 1.003258702010146
  ```

  该查询返回field key `temperature`对应的field value除以field key `pressure`对应的field value的反正切，它涵盖的时间范围在`2020-05-16T12:10:00Z`和`2020-05-16T12:10:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的`point`个数限制为4，并将返回的`point`偏移两个(即前两个`point`不返回）。

  #### 高级语法

  ```sql
  SELECT ATAN2(<function()>, <function()>) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  高级语法需要一个`GROUP BY time()`子句和一个嵌套的cnosQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的反正切(`ATAN2()`)。

  ATAN2()支持以下嵌套函数：

  - COUNT()
  - MEAN()
  - MEDIAN()
  - MODE()
  - SUM()
  - FIRST()
  - LAST()
  - MIN()
  - MAX()
  - PERCENTILE()

  #### 示例

  - #### 计算平均值的反正切

  ```sql
  > SELECT ATAN2(MEAN("temperature"), MEAN("pressure")) FROM "air" WHERE time >= '2021-09-16T12:01:00Z' AND time <= '2021-09-16T14:02:00Z' GROUP BY time(12m)
  name: air
  time                 atan2
  ----                 -----
  2021-09-16T12:00:00Z 0.7916716068182019
  2021-09-16T12:12:00Z 0.7687819020057319
  2021-09-16T12:24:00Z 0.8293469014295621
  2021-09-16T12:36:00Z 0.7483094274728471
  2021-09-16T12:48:00Z 0.8579805385837196
  2021-09-16T13:00:00Z 0.7640815957515122
  2021-09-16T13:12:00Z 0.7660813391498594
  2021-09-16T13:24:00Z 0.7595170787800846
  2021-09-16T13:36:00Z 0.781755192263569
  2021-09-16T13:48:00Z 0.8137459550765823
  2021-09-16T14:00:00Z 0.7572931159369924
  ```

  该查询返回field key `temperature`对应的field value的平均值除以field key `pressure`对应的field value的平均值的反正切。平均值是按每12分钟的时间间隔计算的。

  为了得到这些结果，CnosDB首先计算field key `temperature`和`pressure`对应的每12分钟的时间间隔的field value的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`ATAN2()`的情形一样：

  ```sql
  > SELECT MEAN("temperature"), MEAN("pressure") FROM "air" WHERE time >= '2021-09-16T12:01:00Z' AND time <= '2021-09-16T14:02:00Z' GROUP BY time(12m)
  name: air
  time                 mean              mean_1
  ----                 ----              ------
  2021-09-16T12:00:00Z 66.83333333333333 66
  2021-09-16T12:12:00Z 62.875            65
  2021-09-16T12:24:00Z 68.25             62.5
  2021-09-16T12:36:00Z 64.875            69.875
  2021-09-16T12:48:00Z 71                61.375
  2021-09-16T13:00:00Z 60.25             62.875
  2021-09-16T13:12:00Z 66.625            69.25
  2021-09-16T13:24:00Z 63.5              66.875
  2021-09-16T13:36:00Z 68.375            68.875
  2021-09-16T13:48:00Z 68                64.25
  2021-09-16T14:00:00Z 60.5              64
  ```

  然后，CnosDB计算这些平均值的反正切。

- ### CEIL()

  返回大于指定值的最小整数。

  #### 基本语法

  ```
  SELECT CEIL( [ * | <field_key> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `CEIL(field_key)`返回field key对应的大于field value的最小整数。

  `CEIL(*)`返回在measurement中每个field key对应的大于field value的最小整数。

  `CEIL()`支持数据类型为int64和float64的field value。

  基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`CEIL()`和`GROUP BY time()`子句。

  #### 示例

  下面的示例将使用[`oceanic_station`数据集](oceanic_station.txt)的如下数据：

  ```sql
  > SELECT "temperature" FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 temperature
  ----                 -----------
  2021-09-18T00:00:00Z 51
  2021-09-18T00:03:00Z 60
  2021-09-18T00:06:00Z 55
  2021-09-18T00:09:00Z 55
  2021-09-18T00:12:00Z 63
  2021-09-18T00:15:00Z 74
  2021-09-18T00:18:00Z 79
  2021-09-18T00:21:00Z 68
  2021-09-18T00:24:00Z 70
  2021-09-18T00:27:00Z 79
  2021-09-18T00:30:00Z 75
  ```

  - #### 计算指定field key对应的大于field value的最小整数

  ```sql
  > SELECT CEIL("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 ceil
  ----                 ----
  2021-09-18T00:00:00Z 51
  2021-09-18T00:03:00Z 60
  2021-09-18T00:06:00Z 55
  2021-09-18T00:09:00Z 55
  2021-09-18T00:12:00Z 63
  2021-09-18T00:15:00Z 74
  2021-09-18T00:18:00Z 79
  2021-09-18T00:21:00Z 68
  2021-09-18T00:24:00Z 70
  2021-09-18T00:27:00Z 79
  2021-09-18T00:30:00Z 75
  ```

  该查询返回measurement `air`中field key `temperature`对应的大于field value的最小整数。

  - #### 计算measurement中每个field key对应的大于field value的最小整数

  ```sql
  > SELECT CEIL(*) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 ceil_pressure ceil_temperature ceil_visibility
  ----                 ------------- ---------------- ---------------
  2021-09-18T00:00:00Z 64            51               68
  2021-09-18T00:03:00Z 72            60               74
  2021-09-18T00:06:00Z 54            55               77
  2021-09-18T00:09:00Z 66            55               55
  2021-09-18T00:12:00Z 64            63               70
  2021-09-18T00:15:00Z 58            74               62
  2021-09-18T00:18:00Z 55            79               54
  2021-09-18T00:21:00Z 64            68               58
  2021-09-18T00:24:00Z 66            70               69
  2021-09-18T00:27:00Z 77            79               78
  2021-09-18T00:30:00Z 62            75               80
  ```

  该查询返回measurement `air`中每个存储数值的field key对应的大于field value的最小整数。measurement `air`只有一个数值类型的field：`temperature`。

  - #### 计算指定field key对应的大于field value的最小整数并包含多个子句

  ```sql
  > SELECT CEIL("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' ORDER BY time DESC LIMIT 4 OFFSET 2
  name: air
  time                 ceil
  ----                 ----
  2021-09-18T00:24:00Z 70
  2021-09-18T00:21:00Z 68
  2021-09-18T00:18:00Z 79
  2021-09-18T00:15:00Z 74
  ```

  该查询返回field key `temperature`对应的大于field value的最小整数，它涵盖的时间范围在`2021-09-28T00:00:00Z`和`2021-09-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的`point`个数限制为4，并将返回的`point`偏移两个（即前两个`point`不返回)。

  #### 高级语法

  ```
  SELECT CEIL(<function>( [ * | <field_key> | /<regular_expression>/ ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  高级语法需要一个`GROUP BY time()`子句和一个嵌套的cnosQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后将`CEIL()`应用于这些结果。

  `CEIL()`支持以下嵌套函数：

  - [`COUNT()`](#count)
  - [`MEAN()`](#mean)
  - [`MEDIAN()`](#median)
  - [`MODE()`](#mode)
  - [`SUM()`](#sum)
  - [`FIRST()`](#first)
  - [`LAST()`](#last)
  - [`MIN()`](#min)
  - [`MAX()`](#max)
  - [`PERCENTILE()`](#percentile)

  #### 示例

  - #### 计算大于平均值的最小整数

  ```sql
  > SELECT CEIL(MEAN("temperature")) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(12m)
  name: air
  time                 ceil
  ----                 ----
  2021-09-18T00:00:00Z 56
  2021-09-18T00:12:00Z 71
  2021-09-18T00:24:00Z 75
  ```

  该查询返回每12分钟的时间间隔对应的大于`temperature`平均值的最小整数。

  为了得到这些结果，CnosDB首先计算每12分钟的时间间隔对应的大于`temperature`的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`CEIL()`的情形一样：

  ```sql
  > SELECT MEAN("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(12m)
  name: air
  time                 mean
  ----                 ----
  2021-09-18T00:00:00Z 55.25
  2021-09-18T00:12:00Z 71
  2021-09-18T00:24:00Z 74.66666666666667
  ```

  然后，CnosDB计算大于这些平均值的最小整数。

- ### COS()

  返回field value的余弦值。

  #### 基本语法

  ```
  SELECT COS( [ * | <field_key> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `COS(field_key)`返回field key对应的field value的余弦值。

  `COS(*)`返回在measurement中每个field key对应的field value的余弦值。

  `COS()`支持数据类型为int64和float64的field value。

  基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`COS()`和`GROUP BY time()`子句。

  #### 示例

  - #### 下面的示例将使用`oceanic_station`数据集的如下数据：

  ```sql
  > SELECT "temperature" FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 temperature
  ----                 -----------
  2021-09-18T00:00:00Z 51
  2021-09-18T00:03:00Z 60
  2021-09-18T00:06:00Z 55
  2021-09-18T00:09:00Z 55
  2021-09-18T00:12:00Z 63
  2021-09-18T00:15:00Z 74
  2021-09-18T00:18:00Z 79
  2021-09-18T00:21:00Z 68
  2021-09-18T00:24:00Z 70
  2021-09-18T00:27:00Z 79
  2021-09-18T00:30:00Z 75
  ```

  - #### 计算指定field key对应的field value的余弦值

  ```sql
  > SELECT COS("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 cos
  ----                 ---
  2021-09-18T00:00:00Z 0.7421541968137826
  2021-09-18T00:03:00Z -0.9524129804151563
  2021-09-18T00:06:00Z 0.022126756261955732
  2021-09-18T00:09:00Z 0.022126756261955732
  2021-09-18T00:12:00Z 0.9858965815825497
  2021-09-18T00:15:00Z 0.17171734183077755
  2021-09-18T00:18:00Z -0.8959709467909631
  2021-09-18T00:21:00Z 0.4401430224960407
  2021-09-18T00:24:00Z 0.6333192030862999
  2021-09-18T00:27:00Z -0.8959709467909631
  2021-09-18T00:30:00Z 0.9217512697247493
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的余弦值。

  - #### 计算measurement中每个field key对应的field value的余弦值

  ```sql
  > SELECT COS(*) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 cos_pressure          cos_temperature      cos_visibility
  ----                 ------------          ---------------      --------------
  2021-09-18T00:00:00Z 0.39185723042955      0.7421541968137826   0.4401430224960407
  2021-09-18T00:03:00Z -0.9672505882738824   -0.9524129804151563  0.17171734183077755
  2021-09-18T00:06:00Z -0.8293098328631501   0.022126756261955732 -0.030975031731216456
  2021-09-18T00:09:00Z -0.9996474559663501   0.022126756261955732 0.022126756261955732
  2021-09-18T00:12:00Z 0.39185723042955      0.9858965815825497   0.6333192030862999
  2021-09-18T00:15:00Z 0.11918013544881928   0.17171734183077755  0.6735071623235862
  2021-09-18T00:18:00Z 0.022126756261955732  -0.8959709467909631  -0.8293098328631501
  2021-09-18T00:21:00Z 0.39185723042955      0.4401430224960407   0.11918013544881928
  2021-09-18T00:24:00Z -0.9996474559663501   0.6333192030862999   0.9933903797222716
  2021-09-18T00:27:00Z -0.030975031731216456 -0.8959709467909631  -0.8578030932449878
  2021-09-18T00:30:00Z 0.6735071623235862    0.9217512697247493   -0.11038724383904756
  ```

  该查询返回measurement `air`中每个存储数值的field key对应的field value的余弦值。。measurement `air`中有三个数值类型的field：`temperature`、`pressure`以及`visibility`。

  - #### 计算指定field key对应的field value的余弦值并包含多个子句

  ```sql
  > SELECT COS("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' ORDER BY time DESC LIMIT 4 OFFSET 2
  name: air
  time                 cos
  ----                 ---
  2021-09-18T00:24:00Z 0.6333192030862999
  2021-09-18T00:21:00Z 0.4401430224960407
  2021-09-18T00:18:00Z -0.8959709467909631
  2021-09-18T00:15:00Z 0.17171734183077755
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的余弦值，它涵盖的时间范围在`2021-09-28T00:00:00Z`和`2021-09-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的`point`个数限制为4，并将返回的`point`偏移两个（即前两个`point`不返回）。

  #### 高级语法

  ```
  SELECT COS(<function>( [ * | <field_key> ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  高级语法需要一个`GROUP BY time()`子句和一个嵌套的cnosQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的余弦值。

  `COS()`支持以下嵌套函数：

  - [`COUNT()`](#count)
  - [`MEAN()`](#mean)
  - [`MEDIAN()`](#median)
  - [`MODE()`](#mode)
  - [`SUM()`](#sum)
  - [`FIRST()`](#first)
  - [`LAST()`](#last)
  - [`MIN()`](#min)
  - [`MAX()`](#max)
  - [`PERCENTILE()`](#percentile)

  #### 示例

  - #### 计算平均值的余弦值

  ```sql
  > SELECT COS(MEAN("temperature")) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(12m)
  name: air
  time                 cos
  ----                 ---
  2021-09-18T00:00:00Z 0.2687822771684872
  2021-09-18T00:12:00Z -0.3090227281660707
  2021-09-18T00:24:00Z 0.7441351704799297
  ```

  该查询返回field key `temperature`对应的每12分钟的时间间隔的field value的平均值的余弦值。

  为了得到这些结果，CnosDB首先计算field key `temperature`对应的每12分钟的时间间隔的field value的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`COS()`的情形一样：

  ```sql
  > SELECT MEAN("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(12m)
  name: air
  time                 mean
  ----                 ----
  2021-09-18T00:00:00Z 55.25
  2021-09-18T00:12:00Z 71
  2021-09-18T00:24:00Z 74.66666666666667
  ```

  然后，CnosDB计算这些平均值的余弦值。

- ### CUMULATIVE_SUM()

  返回field value的累积总和。

  #### 基本语法

  ```
  SELECT CUMULATIVE_SUM( [ * | <field_key> | /<regular_expression>/ ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `CUMULATIVE_SUM(field_key)`返回field key对应的field value的累积总和。

  `CUMULATIVE_SUM(/regular_expression/)`返回与正则表达式匹配的每个field key对应的field value的累积总和。

  `CUMULATIVE_SUM(*)`返回在measurement中每个field key对应的field value的累积总和。

  `CUMULATIVE_SUM()`支持数据类型为int64和float64的field value。

  基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`CUMULATIVE_SUM()`和`GROUP BY time()`子句。

  #### 示例

  下面的示例将使用`oceanic_station`数据集的如下数据：

  ```sql
  > SELECT "temperature" FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 temperature
  ----                 -----------
  2021-09-18T00:00:00Z 51
  2021-09-18T00:03:00Z 60
  2021-09-18T00:06:00Z 55
  2021-09-18T00:09:00Z 55
  2021-09-18T00:12:00Z 63
  2021-09-18T00:15:00Z 74
  2021-09-18T00:18:00Z 79
  2021-09-18T00:21:00Z 68
  2021-09-18T00:24:00Z 70
  2021-09-18T00:27:00Z 79
  2021-09-18T00:30:00Z 75
  ```

  - #### 计算指定field key对应的field value的累积总和

  ```sql
  > SELECT CUMULATIVE_SUM("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 cumulative_sum
  ----                 --------------
  2021-09-18T00:00:00Z 51
  2021-09-18T00:03:00Z 111
  2021-09-18T00:06:00Z 166
  2021-09-18T00:09:00Z 221
  2021-09-18T00:12:00Z 284
  2021-09-18T00:15:00Z 358
  2021-09-18T00:18:00Z 437
  2021-09-18T00:21:00Z 505
  2021-09-18T00:24:00Z 575
  2021-09-18T00:27:00Z 654
  2021-09-18T00:30:00Z 729
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的累积总和。

  - #### 计算measurement中每个field key对应的field value的累积总和

  ```sql
  > SELECT CUMULATIVE_SUM(*) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 cumulative_sum_pressure cumulative_sum_temperature cumulative_sum_visibility
  ----                 ----------------------- -------------------------- -------------------------
  2021-09-18T00:00:00Z 64                      51                         68
  2021-09-18T00:03:00Z 136                     111                        142
  2021-09-18T00:06:00Z 190                     166                        219
  2021-09-18T00:09:00Z 256                     221                        274
  2021-09-18T00:12:00Z 320                     284                        344
  2021-09-18T00:15:00Z 378                     358                        406
  2021-09-18T00:18:00Z 433                     437                        460
  2021-09-18T00:21:00Z 497                     505                        518
  2021-09-18T00:24:00Z 563                     575                        587
  2021-09-18T00:27:00Z 640                     654                        665
  2021-09-18T00:30:00Z 702                     729                        745
  ```

  该查询返回measurement `air`中每个存储数值的field key对应的field value的累积总和。。measurement `air`中有三个数值类型的field：`temperature`、`pressure`以及`visibility`。

  - #### 计算与正则表达式匹配的每个field key对应的field value的累积总和

  ```sql
  > SELECT CUMULATIVE_SUM(/temp/) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  time                 cumulative_sum_temperature
  ----                 --------------------------
  2021-09-18T00:00:00Z 51
  2021-09-18T00:03:00Z 111
  2021-09-18T00:06:00Z 166
  2021-09-18T00:09:00Z 221
  2021-09-18T00:12:00Z 284
  2021-09-18T00:15:00Z 358
  2021-09-18T00:18:00Z 437
  2021-09-18T00:21:00Z 505
  2021-09-18T00:24:00Z 575
  2021-09-18T00:27:00Z 654
  2021-09-18T00:30:00Z 729
  ```

  该查询返回measurement `air`中每个存储数值并包含单词`water`的field key对应的field value的累积总和。

  - #### 计算指定field key对应的field value的累积总和并包含多个子句

  ```sql
  > SELECT CUMULATIVE_SUM("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' ORDER BY time DESC LIMIT 4 OFFSET 2
  name: air
  time                 cumulative_sum
  ----                 --------------
  2021-09-18T00:24:00Z 224
  2021-09-18T00:21:00Z 292
  2021-09-18T00:18:00Z 371
  2021-09-18T00:15:00Z 445
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的累积总和，它涵盖的时间范围在`2021-09-28T00:00:00Z`和`2021-09-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的`point`个数限制为4，并将返回的`point`偏移两个（即前两个`point`不返回）。

  #### 高级语法

  ```sql
  SELECT CUMULATIVE_SUM(<function>( [ * | <field_key> | /<regular_expression>/ ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  高级语法需要一个`GROUP BY time()`子句和一个嵌套的cnosQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的累积总和。

  `CUMULATIVE_SUM()`支持以下嵌套函数：

  - [`COUNT()`](#count)
  - [`MEAN()`](#mean)
  - [`MEDIAN()`](#median)
  - [`MODE()`](#mode)
  - [`SUM()`](#sum)
  - [`FIRST()`](#first)
  - [`LAST()`](#last)
  - [`MIN()`](#min)
  - [`MAX()`](#max)
  - [`PERCENTILE()`](#percentile)

  ####示例

  - #### 计算平均值的累积总和

  ```sql
  > SELECT CUMULATIVE_SUM(MEAN("temperature")) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(12m)
  name: air
  time                 cumulative_sum
  ----                 --------------
  2021-09-18T00:00:00Z 55.25
  2021-09-18T00:12:00Z 126.25
  2021-09-18T00:24:00Z 200.91666666666669
  ```

  该查询返回field key `temperature`对应的每12分钟的时间间隔的field value的平均值的累积总和。

  为了得到这些结果，CnosDB首先计算field key `temperature`对应的每12分钟的时间间隔的field value的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`CUMULATIVE_SUM()`的情形一样：

  ```sql
  > SELECT MEAN("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(12m)
  name: air
  time                 mean
  ----                 ----
  2021-09-18T00:00:00Z 55.25
  2021-09-18T00:12:00Z 71
  2021-09-18T00:24:00Z 74.66666666666667
  ```

  然后，CnosDB计算这些平均值的累积总和。最终查询结果中的第二个`point`(`4.167`)是`2.09`和`2.077`的总和，第三个`point`(`6.213`)是`2.09`、`2.077`和`2.0460000000000003`的总和。

- ### DERIVATIVE()

  返回field value之间的变化率，即导数。

  #### 基本语法

  ```
  SELECT DERIVATIVE( [ * | <field_key> | /<regular_expression>/ ] [ , <unit> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  CnosDB计算field value之间的差值，并将这些结果转换为每个`unit`的变化率。参数`unit`的值是一个整数，后跟一个时间单位。这个参数是可选的，不是必须要有的。如果查询没有指定`unit`的值，那么`unit`默认为一秒(`1s`)。

  `DERIVATIVE(field_key)`返回field key对应的field value的变化率。

  `DERIVATIVE(/regular_expression/)`返回与正则表达式匹配的每个field key对应的field value的变化率。

  `DERIVATIVE(*)`返回在measurement中每个field key对应的field value的变化率。

  `DERIVATIVE()`支持数据类型为int64和float64的field value。

  基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`DERIVATIVE()`和`GROUP BY time()`子句。

  #### 示例

  下面的示例将使用`oceanic_station`数据集的如下数据：

  ```sql
  > SELECT "temperature" FROM "air" WHERE "station" = 'LianYunGang' AND time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z'
  name: air
  time                 temperature
  ----                 -----------
  2021-09-18T00:00:00Z 51
  2021-09-18T00:03:00Z 60
  2021-09-18T00:06:00Z 55
  2021-09-18T00:09:00Z 55
  2021-09-18T00:12:00Z 63
  2021-09-18T00:15:00Z 74
  2021-09-18T00:18:00Z 79
  2021-09-18T00:21:00Z 68
  2021-09-18T00:24:00Z 70
  2021-09-18T00:27:00Z 79
  2021-09-18T00:30:00Z 75
  ```

  - #### 计算指定field key对应的field value的导数

  ```sql
  > SELECT DERIVATIVE("temperature") FROM "air" WHERE "station" = 'LianYunGang' AND time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z'
  name: air
  time                 derivative
  ----                 ----------
  2021-09-18T00:03:00Z 0.05
  2021-09-18T00:06:00Z -0.027777777777777776
  2021-09-18T00:09:00Z 0
  2021-09-18T00:12:00Z 0.044444444444444446
  2021-09-18T00:15:00Z 0.06111111111111111
  2021-09-18T00:18:00Z 0.027777777777777776
  2021-09-18T00:21:00Z -0.06111111111111111
  2021-09-18T00:24:00Z 0.011111111111111112
  2021-09-18T00:27:00Z 0.05
  2021-09-18T00:30:00Z -0.022222222222222223
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的每秒变化率。

  第一个结果(`0.05`)是原始数据中前两个field value在一秒内的变化率。CnosDB计算两个field value之间的差值，并将该值标准化为一秒的变化率。


- #### 计算指定field key对应的field value的导数并指定`unit`

  ```sql
  > SELECT DERIVATIVE("temperature",6m) FROM "air" WHERE "station" = 'LianYunGang' AND time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z'
  name: air
  time                 derivative
  ----                 ----------
  2021-09-18T00:03:00Z 18
  2021-09-18T00:06:00Z -10
  2021-09-18T00:09:00Z 0
  2021-09-18T00:12:00Z 16
  2021-09-18T00:15:00Z 22
  2021-09-18T00:18:00Z 10
  2021-09-18T00:21:00Z -22
  2021-09-18T00:24:00Z 4
  2021-09-18T00:27:00Z 18
  2021-09-18T00:30:00Z -8
  ```

该查询返回measurement `air`中field key `temperature`对应的field value的每六分钟的变化率。

第一个结果(`0.052000000000000046`)是原始数据中前两个field value在六分钟内的变化率。CnosDB计算两个field value之间的差值，并将该值标准化为六分钟的变化率：

  ```
  (2.116 - 2.064) / (6m / 6m)
  --------------    ----------
         |              |
         |          the difference between the field values' timestamps / the specified unit
  second field value - first field value
  ```

- #### 计算measurement中每个field key对应的field value的导数并指定`unit`

  ```sql
  > SELECT DERIVATIVE(*,3m) FROM "air" WHERE "station" = 'LianYunGang' AND time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z'
  name: air
  time                 derivative_pressure derivative_temperature derivative_visibility
  ----                 ------------------- ---------------------- ---------------------
  2021-09-18T00:03:00Z 8                   9                      6
  2021-09-18T00:06:00Z -18                 -5                     3
  2021-09-18T00:09:00Z 12                  0                      -22
  2021-09-18T00:12:00Z -2                  8                      15
  2021-09-18T00:15:00Z -6                  11                     -8
  2021-09-18T00:18:00Z -3                  5                      -8
  2021-09-18T00:21:00Z 9                   -11                    4
  2021-09-18T00:24:00Z 2                   2                      11
  2021-09-18T00:27:00Z 11                  9                      9
  2021-09-18T00:30:00Z -15                 -4                     2
  ```

该查询返回measurement `air`中每个存储数值的field key对应的field value的每三分钟的变化率。measurement `air`中数值类型的field：`temperature`,`pressure`,`visibility`。


- #### 计算与正则表达式匹配的每个field key对应的field value的导数并指定`unit`

  ```sql
  > SELECT DERIVATIVE(/temp/,2m) FROM "air" WHERE "station" = 'LianYunGang' AND time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z'
  name: air
  time                 derivative_temperature
  ----                 ----------------------
  2021-09-18T00:03:00Z 6
  2021-09-18T00:06:00Z -3.3333333333333335
  2021-09-18T00:09:00Z 0
  2021-09-18T00:12:00Z 5.333333333333333
  2021-09-18T00:15:00Z 7.333333333333333
  2021-09-18T00:18:00Z 3.3333333333333335
  2021-09-18T00:21:00Z -7.333333333333333
  2021-09-18T00:24:00Z 1.3333333333333333
  2021-09-18T00:27:00Z 6
  2021-09-18T00:30:00Z -2.6666666666666665
  ```

该查询返回measurement `air`中的对应field key"temperature"对应的field value的每两分钟的变化率。

第一个结果(`6`)是原始数据中前两个field value在两分钟内的变化率。CnosDB计算两个field value之间的差值，并将该值标准化为两分钟的变化率：

  ```
  (-3.3333333333333335 6) / (6m / 2m)
  --------------            ----------
         |                      |
         |                the difference between the field values' timestamps / the specified unit
  second field value - first field value
  ```

- #### 计算指定field key对应的field value的导数并包含多个子句

  ```sql
  > SELECT DERIVATIVE("temperature") FROM "air" WHERE "station" = 'LianYunGang' AND time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' ORDER BY time DESC LIMIT 1 OFFSET 2
  name: air
  time                 derivative
  ----                 ----------
  2021-09-18T00:21:00Z -0.011111111111111112
  ```

该查询返回measurement `air`中field key `temperature`对应的field value的每秒变化率，它涵盖的时间范围在`2021-09-28T00:00:00Z`和`2021-09-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的`point`个数限制为1，并将返回的`point`偏移两个(即前两个`point`不返回）。

唯一的结果(`-0.011111111111111112`)是原始数据中前两个field value在一秒内的变化率。CnosDB计算两个field value之间的差值，并将该值标准化为一秒的变化率。

#### 高级语法

  ```
  SELECT DERIVATIVE(<function> ([ * | <field_key> | /<regular_expression>/ ]) [ , <unit> ] ) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

高级语法需要一个`GROUP BY time()`子句和一个嵌套的cnosQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的导数。

参数`unit`的值是一个整数，后跟一个时间单位。这个参数是可选的，不是必须要有的。如果查询没有指定`unit`的值，那么`unit`默认为`GROUP BY time()`的时间间隔。请注意，这里`unit`的默认值跟基本语法中`unit`的默认值不一样。

`DERIVATIVE()`支持以下嵌套函数：

- [`COUNT()`](#count)
- [`MEAN()`](#mean)
- [`MEDIAN()`](#median)
- [`MODE()`](#mode)
- [`SUM()`](#sum)
- [`FIRST()`](#first)
- [`LAST()`](#last)
- [`MIN()`](#min)
- [`MAX()`](#max)
- [`PERCENTILE()`](#percentile)

####示例

- #### 计算平均值的导数

  ```sql
  > SELECT DERIVATIVE(MEAN("temperature")) FROM "air" WHERE "station" = 'LianYunGang' AND time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' GROUP BY time(12m)
  name: air
  time                 derivative
  ----                 ----------
  2021-09-18T00:00:00Z -14.25
  2021-09-18T00:12:00Z 15.75
  2021-09-18T00:24:00Z 3.6666666666666714
  ```

该查询返回field key `temperature`对应的每12分钟的时间间隔的field value的平均值的每12分钟变化率。

为了得到这些结果，CnosDB首先计算field key `temperature`对应的每12分钟的时间间隔的field value的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`DERIVATIVE()`的情形一样：

  ```sql
  > SELECT MEAN("temperature") FROM "air" WHERE "station" = 'LianYunGang' AND time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' GROUP BY time(12m)
  name: air
  time                 mean
  ----                 ----
  2021-09-18T00:00:00Z 55.25
  2021-09-18T00:12:00Z 71
  2021-09-18T00:24:00Z 74.66666666666667
  ```

然后，CnosDB计算这些平均值的每12分钟的变化率。第一个结果(`55.25`)是原始数据中前两个field value在12分钟内的变化率。CnosDB计算两个field value之间的差值，并将该值标准化为12分钟的变化率：

  ```
  (71 - 74.66666666666667)  / (12m / 12m)
  -------------                   ----------
         |                           |
         |                     the difference between the field values' timestamps / the default unit
  second field value - first field value
  ```

- #### 计算平均值的导数并指定`unit`

  ```sql
  > SELECT DERIVATIVE(MEAN("temperature"),6m) FROM "air" WHERE "station" = 'LianYunGang' AND time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' GROUP BY time(12m)
  name: air
  time                 derivative
  ----                 ----------
  2021-09-18T00:00:00Z -7.125
  2021-09-18T00:12:00Z 7.875
  2021-09-18T00:24:00Z 1.8333333333333357
  ```

该查询返回field key `temperature`对应的每12分钟的时间间隔的field value的平均值的每六分钟变化率。

为了得到这些结果，CnosDB首先计算field key `temperature`对应的每12分钟的时间间隔的field value的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`DERIVATIVE()`的情形一样：

  ```sql
  > SELECT MEAN("temperature") FROM "air" WHERE "station" = 'LianYunGang' AND time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' GROUP BY time(12m)
  
  name: air
  time                 mean
  ----                 ----
  2021-09-18T00:00:00Z 55.25
  2021-09-18T00:12:00Z 71
  2021-09-18T00:24:00Z 74.66666666666667
  ```

然后，CnosDB计算这些平均值的每六分钟的变化率。第一个结果(`-55.25`)是原始数据中前两个field value在六分钟内的变化率。CnosDB计算两个field value之间的差值，并将该值标准化为六分钟的变化率：

  ```sql
  (71 - 74.66666666666667) / (12m / 6m)
  -------------    ----------
         |                         |
         |                    the difference between the field values' timestamps / the specified unit
  second field value - first field value
  ```

- ### DIFFERENCE()

  返回field value之间的差值。

  #### 基本语法

  ```sql
  SELECT DIFFERENCE( [ * | <field_key> | /<regular_expression>/ ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `DIFFERENCE(field_key)`返回field key对应的field value的差值。

  `DIFFERENCE(/regular_expression/)`返回与正则表达式匹配的每个field key对应的field value的差值。

  `DIFFERENCE(*)`返回在measurement中每个field key对应的field value的差值。

  `DIFFERENCE()`支持数据类型为int64和float64的field value。

  基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`DIFFERENCE()`和`GROUP BY time()`子句。

  #### 示例

  下面的示例将使用`oceanic_station`数据集的如下数据：

  ```sql
  > SELECT "temperature" FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 temperature
  ----                 -----------
  2021-09-18T00:00:00Z 51
  2021-09-18T00:03:00Z 60
  2021-09-18T00:06:00Z 55
  2021-09-18T00:09:00Z 55
  2021-09-18T00:12:00Z 63
  2021-09-18T00:15:00Z 74
  2021-09-18T00:18:00Z 79
  2021-09-18T00:21:00Z 68
  2021-09-18T00:24:00Z 70
  2021-09-18T00:27:00Z 79
  2021-09-18T00:30:00Z 75
  ```

  - #### 计算指定field key对应的field value的差值

  ```sql
  > SELECT DIFFERENCE("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 difference
  ----                 ----------
  2021-09-18T00:03:00Z 9
  2021-09-18T00:06:00Z -5
  2021-09-18T00:09:00Z 0
  2021-09-18T00:12:00Z 8
  2021-09-18T00:15:00Z 11
  2021-09-18T00:18:00Z 5
  2021-09-18T00:21:00Z -11
  2021-09-18T00:24:00Z 2
  2021-09-18T00:27:00Z 9
  2021-09-18T00:30:00Z -4
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value之间的差值。

  - #### 计算measurement中每个field key对应的field value的差值

  ```sql
  > SELECT DIFFERENCE(*) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 difference_pressure difference_temperature difference_visibility
  ----                 ------------------- ---------------------- ---------------------
  2021-09-18T00:03:00Z 8                   9                      6
  2021-09-18T00:06:00Z -18                 -5                     3
  2021-09-18T00:09:00Z 12                  0                      -22
  2021-09-18T00:12:00Z -2                  8                      15
  2021-09-18T00:15:00Z -6                  11                     -8
  2021-09-18T00:18:00Z -3                  5                      -8
  2021-09-18T00:21:00Z 9                   -11                    4
  2021-09-18T00:24:00Z 2                   2                      11
  2021-09-18T00:27:00Z 11                  9                      9
  2021-09-18T00:30:00Z -15                 -4                     2
  ```

  该查询返回measurement `air`中每个存储数值的field key对应的field value之间的差值。。measurement `air`中有三个数值类型的field：`temperature`、`pressure`以及`visibility`。

  - #### 计算与正则表达式匹配的每个field key对应的field value的差值

  ```sql
  > SELECT DIFFERENCE(/visi/) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 difference_visibility
  ----                 ----------
  2021-09-18T00:03:00Z 6
  2021-09-18T00:06:00Z 3
  2021-09-18T00:09:00Z -22
  2021-09-18T00:12:00Z 15
  2021-09-18T00:15:00Z -8
  2021-09-18T00:18:00Z -8
  2021-09-18T00:21:00Z 4
  2021-09-18T00:24:00Z 11
  2021-09-18T00:27:00Z 9
  2021-09-18T00:30:00Z 2
  ```

  该查询返回measurement `air`中每个存储数值并包含单词`water`的field key对应的field value之间的差值。

  - #### 计算指定field key对应的field value的差值并包含多个子句

  ```sql
  > SELECT DIFFERENCE("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' ORDER BY time DESC LIMIT 2 OFFSET 2
  name: air
  time                 difference
  ----                 ----------
  2021-09-18T00:21:00Z -2
  2021-09-18T00:18:00Z 11
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value之间的差值，它涵盖的时间范围在`2021-09-28T00:00:00Z`和`2021-09-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的`point`个数限制为2，并将返回的`point`偏移两个（即前两个`point`不返回）。

  #### 高级语法

  ```sql
  SELECT DIFFERENCE(<function>( [ * | <field_key> | /<regular_expression>/ ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  高级语法需要一个`GROUP BY time()`子句和一个嵌套的cnosQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果之间的差值。

  DIFFERENCE()支持以下嵌套函数：
  [`COUNT()`](#count),
  [`MEAN()`](#mean),
  [`MEDIAN()`](#median),
  [`MODE()`](#mode),
  [`SUM()`](#sum),
  [`FIRST()`](#first),
  [`LAST()`](#last),
  [`MIN()`](#min),
  [`MAX()`](#max), and
  [`PERCENTILE()`](#percentile).

  #### 示例

  - #### 计算最大值之间的差值

  ```sql
  > SELECT DIFFERENCE(MAX("temperature")) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(12m)
  name: air
  time                 difference
  ----                 ----------
  2021-09-18T00:00:00Z -19
  2021-09-18T00:12:00Z 19
  2021-09-18T00:24:00Z 0
  ```

  该查询返回field key `temperature`对应的每12分钟的时间间隔的field value的最大值之间的差值。

  为了得到这些结果，CnosDB首先计算field key `temperature`对应的每12分钟的时间间隔的field value的最大值。这一步跟同时使用`MAX()`函数和`GROUP BY time()`子句、但不使用`DIFFERENCE()`的情形一样：

  ```sql
  > SELECT MAX("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(12m)
  name: air
  time                 max
  ----                 ---
  2021-09-18T00:00:00Z 60
  2021-09-18T00:12:00Z 79
  2021-09-18T00:24:00Z 79
  ```

  然后，CnosDB计算这些最大值之间的差值。最终查询结果中的第一个`point`(`0.009999999999999787`)是`2.126`和`2.116`的差，第二个`point`(`-0.07499999999999973`)是`2.051`和`2.126`的差。

- ### ELAPSED()

  返回field value的时间戳之间的差值。

  #### 语法

  ```
  SELECT ELAPSED( [ * | <field_key> | /<regular_expression>/ ] [ , <unit> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  CnosDB计算时间戳之间的差值。参数`unit`的值是一个整数，后跟一个时间单位，它决定了返回的差值的单位。这个参数是可选的，不是必须要有的。如果没有指定`unit`的值，那么查询将返回以纳秒为单位的两个时间戳之间的差值。

  `ELAPSED(field_key)`返回field key对应的时间戳之间的差值。

  `ELAPSED(/regular_expression/)`返回与正则表达式匹配的每个field key对应的时间戳之间的差值。

  `ELAPSED(*)`返回在measurement中每个field key对应的时间戳之间的差值。

  `ELAPSED()`支持所有数据类型的field value。

  #### 示例

  下面的示例将使用`oceanic_station`数据集的如下数据：

  ```sql
  > SELECT "temperature" FROM "air" WHERE "station" = 'LianYunGang' AND time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:24:00Z'
  name: air
  time                 temperature
  ----                 -----------
  2021-09-18T00:00:00Z 51
  2021-09-18T00:03:00Z 60
  2021-09-18T00:06:00Z 55
  2021-09-18T00:09:00Z 55
  2021-09-18T00:12:00Z 63
  2021-09-18T00:15:00Z 74
  2021-09-18T00:18:00Z 79
  2021-09-18T00:21:00Z 68
  2021-09-18T00:24:00Z 70
  ```

  - #### 计算指定field key对应的field value之间的时间间隔

  ```sql
  > SELECT ELAPSED("temperature") FROM "air" WHERE "station" = 'LianYunGang' AND time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:24:00Z'
  name: air
  time                 elapsed
  ----                 -------
  2021-09-18T00:03:00Z 180000000000
  2021-09-18T00:06:00Z 180000000000
  2021-09-18T00:09:00Z 180000000000
  2021-09-18T00:12:00Z 180000000000
  2021-09-18T00:15:00Z 180000000000
  2021-09-18T00:18:00Z 180000000000
  2021-09-18T00:21:00Z 180000000000
  2021-09-18T00:24:00Z 180000000000
  ```

  该查询返回measurement `air`中field key `temperature`对应的时间戳之间的差值(以纳秒为单位)。

  - #### 计算指定field key对应的field value之间的时间间隔并指定`unit`

  ```sql
  > SELECT ELAPSED("temperature",1m) FROM "air" WHERE "station" = 'LianYunGang' AND time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:24:00Z'
  name: air
  time                 elapsed
  ----                 -------
  2021-09-18T00:03:00Z 3
  2021-09-18T00:06:00Z 3
  2021-09-18T00:09:00Z 3
  2021-09-18T00:12:00Z 3
  2021-09-18T00:15:00Z 3
  2021-09-18T00:18:00Z 3
  2021-09-18T00:21:00Z 3
  2021-09-18T00:24:00Z 3
  ```

  该查询返回measurement `air`中每个field key对应的时间戳之间的差值(以分钟为单位)。measurement `air`中有两个field key：`pressure`和`temperature`。

  - #### 计算与正则表达式匹配的每个field key对应的field value之间的时间间隔并指定`unit`

  ```sql
  > SELECT ELAPSED(/press/,1m) FROM "air" WHERE "station" = 'LianYunGang' AND time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:24:00Z'
  name: air
  time                 elapsed_pressure
  ----                 ----------------
  2021-09-18T00:03:00Z 3
  2021-09-18T00:06:00Z 3
  2021-09-18T00:09:00Z 3
  2021-09-18T00:12:00Z 3
  2021-09-18T00:15:00Z 3
  2021-09-18T00:18:00Z 3
  2021-09-18T00:21:00Z 3
  2021-09-18T00:24:00Z 3
  ```

  该查询返回measurement `air`中每个包含单词`level`的field key对应的时间戳之间的差值(以秒为单位)。

  - #### 计算指定field key对应的field value之间的时间间隔并包含多个子句

  ```sql
  > SELECT ELAPSED("temperature",1ms) FROM "air" WHERE "station" = 'LianYunGang' AND time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:24:00Z' ORDER BY time DESC LIMIT 1 OFFSET 1
  name: air
  time                 elapsed
  ----                 -------
  2021-09-18T00:18:00Z -180000
  ```

  该查询返回measurement `air`中field key `temperature`对应的时间戳之间的差值(以毫秒为单位)，它涵盖的时间范围在`2021-09-28T00:00:00Z`和`2020-08-18T00:12:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的`point`个数限制为1，并将返回的`point`偏移一个（即前一个`point`不返回）。

  请注意，查询结果是负数；因为`ORDER BY time DESC`子句按递减的顺序对时间戳进行排序，所以`ELAPSED()`以相反的顺序计算时间戳的差值。

  #### `ELAPSED()`的常见问题

  - #### `ELAPSED()`和大于经过时间的单位

  I如果`unit`的值大于时间戳之间的差值，那么CnosDB将会返回`0`。

  measurement `air`中每六分钟有一个`point`。如果查询将`unit`设置为一小时，CnosDB将会返回`0`：

  ```sql
  > SELECT ELAPSED("temperature",1h) FROM "air" WHERE "station" = 'LianYunGang' AND time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:12:00Z'
  name: air
  time                 elapsed
  ----                 -------
  2021-09-18T00:03:00Z 0
  2021-09-18T00:06:00Z 0
  2021-09-18T00:09:00Z 0
  2021-09-18T00:12:00Z 0
  ```

  - #### `ELAPSED()`和`GROUP BY time()`子句同时使用

  `ELAPSED()`函数支持`GROUP BY time()`子句，但是查询结果不是特别有用。目前，如果`ELAPSED()`查询包含一个嵌套的cnosQL函数和一个`GROUP BY time()`子句，那么只会返回指定`GROUP BY time()`子句中的时间间隔。

  `GROUP BY time()`子句决定了查询结果中的时间戳：每个时间戳表示时间间隔的开始时间。该行为也适用于嵌套的selector函数(例如`FIRST()`或`MAX()`)，而在其它的所有情况下，这些函数返回的是原始数据的特定时间戳。因为`GROUP BY time()`子句会覆盖原始时间戳，所以`ELAPSED()`始终返回与`GROUP BY time()`的时间间隔相同的时间戳。

  下面代码块中的第一个查询尝试使用`ELAPSED()`和`GROUP BY time()`子句来查找最小的`temperature`的值之间经过的时间(以分钟为单位)。查询的两个时间间隔都返回了12分钟。

  为了得到这些结果，CnosDB首先计算每12分钟的时间间隔的`temperature`的最小值。代码块中的第二个查询展示了这一步的结果。这一步跟同时使用`MIN()`函数和`GROUP BY time()`子句、但不使用`ELAPSED()`的情形一样。请注意，第二个查询返回的时间戳间隔12分钟。在原始数据中，第一个结果(`2.057`)发生在`2020-08-18T00:42:00Z`，但是`GROUP BY time()`子句覆盖了原始的时间戳。因为时间戳由`GROUP BY time()`的时间间隔(而不是原始数据)决定，所以`ELAPSED()`始终返回与GROUP BY time()的时间间隔相同的时间戳。

  ```sql
  > SELECT ELAPSED(MIN("temperature"),1m) FROM "air" WHERE "station" = 'LianYunGang' AND time >= '2021-09-08T00:36:00Z' AND time <= '2021-09-08T00:54:00Z' GROUP BY time(12m)
  name: air
  time                 elapsed
  ----                 -------
  2021-09-08T00:36:00Z 12
  2021-09-08T00:48:00Z 12
  
  > SELECT MIN("temperature") FROM "air" WHERE "station" = 'LianYunGang' AND time >= '2021-09-08T00:36:00Z' AND time <= '2021-09-08T00:54:00Z' GROUP BY time(12m)
  name: air
  time                 min
  ----                 ---
  2021-09-08T00:36:00Z 50
  2021-09-08T00:48:00Z 73  <--- Actually occurs at 2021-09-08T00:48:00Z
  ```

- ### EXP()

  返回field value的指数。

  #### 基本语法

  ```
  SELECT EXP( [ * | <field_key> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `EXP(field_key)`返回field key对应的field value的指数。

  `EXP(*)`返回在measurement中每个field key对应的field value的指数。

  `EXP()`支持数据类型为int64和float64的field value。

  基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`EXP()`和`GROUP BY time()`子句。

  #### 示例

  下面的示例将使用[示例数据](https://gist.github.com/sanderson/8f8aec94a60b2c31a61f44a37737bfea?spm=a2c4g.11186623.2.85.41fc3ee27HC1R6)中的如下数据：

  ```sql
  > SELECT "temperature" FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 temperature
  ----                 -----------
  2021-09-18T00:00:00Z 51
  2021-09-18T00:03:00Z 60
  2021-09-18T00:06:00Z 55
  2021-09-18T00:09:00Z 55
  2021-09-18T00:12:00Z 63
  2021-09-18T00:15:00Z 74
  2021-09-18T00:18:00Z 79
  2021-09-18T00:21:00Z 68
  2021-09-18T00:24:00Z 70
  2021-09-18T00:27:00Z 79
  2021-09-18T00:30:00Z 75
  ```

  - #### 计算指定field key对应的field value的指数

  ```sql
  > SELECT EXP("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 exp
  ----                 ---
  2021-09-18T00:00:00Z 1.4093490824269389e+22
  2021-09-18T00:03:00Z 1.1420073898156842e+26
  2021-09-18T00:06:00Z 7.694785265142018e+23
  2021-09-18T00:09:00Z 7.694785265142018e+23
  2021-09-18T00:12:00Z 2.29378315946961e+27
  2021-09-18T00:15:00Z 1.3733829795401763e+32
  2021-09-18T00:18:00Z 2.0382810665126688e+34
  2021-09-18T00:21:00Z 3.404276049931741e+29
  2021-09-18T00:24:00Z 2.515438670919167e+30
  2021-09-18T00:27:00Z 2.0382810665126688e+34
  2021-09-18T00:30:00Z 3.7332419967990015e+32
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的指数。

  - #### 计算measurement中每个field key对应的field value的指数

  ```sql
  > SELECT EXP(*) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 exp_pressure           exp_temperature        exp_visibility
  ----                 ------------           ---------------        --------------
  2021-09-18T00:00:00Z 6.235149080811617e+27  1.4093490824269389e+22 3.404276049931741e+29
  2021-09-18T00:03:00Z 1.8586717452841279e+31 1.1420073898156842e+26 1.3733829795401763e+32
  2021-09-18T00:06:00Z 2.830753303274694e+23  7.694785265142018e+23  2.7585134545231703e+33
  2021-09-18T00:09:00Z 4.607186634331292e+28  7.694785265142018e+23  7.694785265142018e+23
  2021-09-18T00:12:00Z 6.235149080811617e+27  2.29378315946961e+27   2.515438670919167e+30
  2021-09-18T00:15:00Z 1.545538935590104e+25  1.3733829795401763e+32 8.438356668741455e+26
  2021-09-18T00:18:00Z 7.694785265142018e+23  2.0382810665126688e+34 2.830753303274694e+23
  2021-09-18T00:21:00Z 6.235149080811617e+27  3.404276049931741e+29  1.545538935590104e+25
  2021-09-18T00:24:00Z 4.607186634331292e+28  2.515438670919167e+30  9.253781725587789e+29
  2021-09-18T00:27:00Z 2.7585134545231703e+33 2.0382810665126688e+34 7.49841699699012e+33
  2021-09-18T00:30:00Z 8.438356668741455e+26  3.7332419967990015e+32 5.54062238439351e+34
  ```

  该查询返回measurement `air`中每个存储数值的field key对应的field value的指数。。measurement `air`中有三个数值类型的field：`temperature`、`pressure`以及`visibility`。

  - #### 计算指定field key对应的field value的指数并包含多个子句

  ```sql
  > SELECT EXP("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' ORDER BY time DESC LIMIT 4 OFFSET 2
  name: air
  time                 exp
  ----                 ---
  2021-09-18T00:24:00Z 2.515438670919167e+30
  2021-09-18T00:21:00Z 3.404276049931741e+29
  2021-09-18T00:18:00Z 2.0382810665126688e+34
  2021-09-18T00:15:00Z 1.3733829795401763e+32
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的指数，它涵盖的时间范围在`2021-09-28T00:00:00Z`和`2021-09-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的`point`个数限制为4，并将返回的`point`偏移两个(即前两个`point`不返回)。

  #### 高级语法

  ```
  SELECT EXP(<function>( [ * | <field_key> ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  高级语法需要一个`GROUP BY time()`子句和一个嵌套的cnosQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的指数。

  EXP()支持以下嵌套函数：

  [`COUNT()`](#count),
  [`MEAN()`](#mean),
  [`MEDIAN()`](#median),
  [`MODE()`](#mode),
  [`SUM()`](#sum),
  [`FIRST()`](#first),
  [`LAST()`](#last),
  [`MIN()`](#min),
  [`MAX()`](#max), and
  [`PERCENTILE()`](#percentile).

  #### 示例

  - #### 计算平均值的指数

  ```sql
  > SELECT EXP(MEAN("temperature")) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(12m)
  name: air
  time                 exp
  ----                 ---
  2021-09-18T00:00:00Z 9.880299856396672e+23
  2021-09-18T00:12:00Z 6.837671229762744e+30
  2021-09-18T00:24:00Z 2.674984780655511e+32
  ```

  该查询返回每12分钟的时间间隔对应的`temperature`的平均值的绝对值。

  为了得到这些结果，CnosDB首先计算每12分钟的时间间隔对应的`temperature`的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`EXP()`的情形一样：

  ```sql
  > SELECT MEAN("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(12m)
  name: air
  time                 mean
  ----                 ----
  2021-09-18T00:00:00Z 55.25
  2021-09-18T00:12:00Z 71
  2021-09-18T00:24:00Z 74.66666666666667
  ```

  .然后，CnosDB计算这些平均值的指数。

  ### FLOOR()

  返回小于指定值的最大整数。

  #### 基本语法

  ```
  SELECT FLOOR( [ * | <field_key> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `FLOOR(field_key)`返回field key对应的小于field value的最大整数。

  `FLOOR(*)`返回在measurement中每个field key对应的小于field value的最大整数。

  `FLOOR()`支持数据类型为int64和float64的field value。

  基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`FLOOR()`和`GROUP BY time()`子句。

  #### 示例

  下面的示例将使用`oceanic_station`数据集的如下数据：

  ```sql
  > SELECT "temperature" FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 temperature
  ----                 -----------
  2021-09-18T00:00:00Z 51
  2021-09-18T00:03:00Z 60
  2021-09-18T00:06:00Z 55
  2021-09-18T00:09:00Z 55
  2021-09-18T00:12:00Z 63
  2021-09-18T00:15:00Z 74
  2021-09-18T00:18:00Z 79
  2021-09-18T00:21:00Z 68
  2021-09-18T00:24:00Z 70
  2021-09-18T00:27:00Z 79
  2021-09-18T00:30:00Z 75
  ```

  - #### 计算指定field key对应的小于field value的最大整数

  ```sql
  > SELECT FLOOR("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 floor
  ----                 -----
  2021-09-18T00:00:00Z 51
  2021-09-18T00:03:00Z 60
  2021-09-18T00:06:00Z 55
  2021-09-18T00:09:00Z 55
  2021-09-18T00:12:00Z 63
  2021-09-18T00:15:00Z 74
  2021-09-18T00:18:00Z 79
  2021-09-18T00:21:00Z 68
  2021-09-18T00:24:00Z 70
  2021-09-18T00:27:00Z 79
  2021-09-18T00:30:00Z 75
  ```

  该查询返回measurement `air`中field key `temperature`对应的小于field value的最大整数。

  - #### 计算measurement中每个field key对应的小于field value的最大整数

  ```sql
  > SELECT FLOOR(*) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 floor_pressure floor_temperature floor_visibility
  ----                 -------------- ----------------- ----------------
  2021-09-18T00:00:00Z 64             51                68
  2021-09-18T00:03:00Z 72             60                74
  2021-09-18T00:06:00Z 54             55                77
  2021-09-18T00:09:00Z 66             55                55
  2021-09-18T00:12:00Z 64             63                70
  2021-09-18T00:15:00Z 58             74                62
  2021-09-18T00:18:00Z 55             79                54
  2021-09-18T00:21:00Z 64             68                58
  2021-09-18T00:24:00Z 66             70                69
  2021-09-18T00:27:00Z 77             79                78
  2021-09-18T00:30:00Z 62             75                80
  ```

  该查询返回measurement `air`中每个存储数值的field key对应的小于field value的最大整数。measurement `air`只有一个数值类型的field：`temperature`。

  - #### 计算指定field key对应的小于field value的最大整数并包含多个子句

  ```sql
  > SELECT FLOOR("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' ORDER BY time DESC LIMIT 4 OFFSET 2
  name: air
  time                 floor
  ----                 -----
  2021-09-18T00:24:00Z 70
  2021-09-18T00:21:00Z 68
  2021-09-18T00:18:00Z 79
  2021-09-18T00:15:00Z 74
  ```

  该查询返回field key `temperature`对应的小于field value的最大整数，它涵盖的时间范围在`2021-09-28T00:00:00Z`和`2021-09-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的`point`个数限制为4，并将返回的`point`偏移两个(即前两个`point`不返回)。

  #### 高级语法

  ```
  SELECT FLOOR(<function>( [ * | <field_key> ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  高级语法需要一个`GROUP BY time()`子句和一个嵌套的cnosQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后将`FLOOR()`应用于这些结果。

  `FLOOR()`支持以下嵌套函数：

  - [`COUNT()`](#count)
  - [`MEAN()`](#mean)
  - [`MEDIAN()`](#median)
  - [`MODE()`](#mode)
  - [`SUM()`](#sum)
  - [`FIRST()`](#first)
  - [`LAST()`](#last)
  - [`MIN()`](#min)
  - [`MAX()`](#max)
  - [`PERCENTILE()`](#percentile)

  ####示例

  - #### 计算小于平均值的最大整数

  ```sql
  > SELECT FLOOR(MEAN("temperature")) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(12m)
  name: air
  time                 floor
  ----                 -----
  2021-09-18T00:00:00Z 55
  2021-09-18T00:12:00Z 71
  2021-09-18T00:24:00Z 74
  ```

  该查询返回每12分钟的时间间隔对应的小于`temperature`平均值的最大整数。

  为了得到这些结果，CnosDB首先计算每12分钟的时间间隔对应的`temperature`的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`FLOOR()`的情形一样：

  ```sql
  > SELECT MEAN("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(12m)
  name: air
  time                 mean
  ----                 ----
  2021-09-18T00:00:00Z 55.25
  2021-09-18T00:12:00Z 71
  2021-09-18T00:24:00Z 74.66666666666667
  ```

  然后，CnosDB计算小于这些平均值的最大整数。

- ### LN()

  返回field value的自然对数。

  #### 基本语法

  ```
  SELECT LN( [ * | <field_key> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `LN(field_key)`返回field key对应的field value的自然对数。

  `LN(*)`返回在measurement中每个field key对应的field value的自然对数。

  `LN()`支持数据类型为int64和float64的field value。

  基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`LN()`和`GROUP BY time()`子句。

  #### 示例

  下面的示例将使用[示例数据](https://gist.github.com/sanderson/8f8aec94a60b2c31a61f44a37737bfea?spm=a2c4g.11186623.2.86.41fc3ee27HC1R6)中的如下数据：

  ```sql
  > SELECT "temperature" FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 temperature
  ----                 -----------
  2021-09-18T00:00:00Z 51
  2021-09-18T00:03:00Z 60
  2021-09-18T00:06:00Z 55
  2021-09-18T00:09:00Z 55
  2021-09-18T00:12:00Z 63
  2021-09-18T00:15:00Z 74
  2021-09-18T00:18:00Z 79
  2021-09-18T00:21:00Z 68
  2021-09-18T00:24:00Z 70
  2021-09-18T00:27:00Z 79
  2021-09-18T00:30:00Z 75
  ```

  - #### 计算指定field key对应的field value的自然对数

  ```sql
  > SELECT LN("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 ln
  ----                 --
  2021-09-18T00:00:00Z 3.9318256327243257
  2021-09-18T00:03:00Z 4.0943445622221
  2021-09-18T00:06:00Z 4.007333185232471
  2021-09-18T00:09:00Z 4.007333185232471
  2021-09-18T00:12:00Z 4.143134726391533
  2021-09-18T00:15:00Z 4.304065093204169
  2021-09-18T00:18:00Z 4.3694478524670215
  2021-09-18T00:21:00Z 4.219507705176107
  2021-09-18T00:24:00Z 4.248495242049359
  2021-09-18T00:27:00Z 4.3694478524670215
  2021-09-18T00:30:00Z 4.31748811353631
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的自然对数。

  - #### 计算measurement中每个field key对应的field value的自然对数

  ```sql
  > SELECT LN(*) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 ln_pressure        ln_temperature     ln_visibility
  ----                 -----------        --------------     -------------
  2021-09-18T00:00:00Z 4.1588830833596715 3.9318256327243257 4.219507705176107
  2021-09-18T00:03:00Z 4.276666119016055  4.0943445622221    4.304065093204169
  2021-09-18T00:06:00Z 3.9889840465642745 4.007333185232471  4.343805421853684
  2021-09-18T00:09:00Z 4.189654742026425  4.007333185232471  4.007333185232471
  2021-09-18T00:12:00Z 4.1588830833596715 4.143134726391533  4.248495242049359
  2021-09-18T00:15:00Z 4.060443010546419  4.304065093204169  4.127134385045092
  2021-09-18T00:18:00Z 4.007333185232471  4.3694478524670215 3.9889840465642745
  2021-09-18T00:21:00Z 4.1588830833596715 4.219507705176107  4.060443010546419
  2021-09-18T00:24:00Z 4.189654742026425  4.248495242049359  4.23410650459726
  2021-09-18T00:27:00Z 4.343805421853684  4.3694478524670215 4.356708826689592
  2021-09-18T00:30:00Z 4.127134385045092  4.31748811353631   4.382026634673881
  ```

  该查询返回measurement `air`中每个存储数值的field key对应的field value的自然对数。。measurement `air`中有三个数值类型的field：`temperature`、`pressure`以及`visibility`。

  - #### 计算指定field key对应的field value的自然对数并包含多个子句

  ```sql
  > SELECT LN("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' ORDER BY time DESC LIMIT 4 OFFSET 2
  name: air
  time                 ln
  ----                 --
  2021-09-18T00:24:00Z 4.248495242049359
  2021-09-18T00:21:00Z 4.219507705176107
  2021-09-18T00:18:00Z 4.3694478524670215
  2021-09-18T00:15:00Z 4.304065093204169
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的自然对数，它涵盖的时间范围在`2021-09-28T00:00:00Z`和`2021-09-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的`point`个数限制为4，并将返回的`point`偏移两个(即前两个`point`不返回）。

  #### 高级语法

  ```
  SELECT LN(<function>( [ * | <field_key> ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  高级语法需要一个 GROUP BY time() ` 和一个嵌套的cnosQL 函数.
  该查询受限以指定 `GROUP BY time()`间隔计算嵌套函数的结果 `LN()` .

  LN()支持以下嵌套函数：

  [`COUNT()`](#count),
  [`MEAN()`](#mean),
  [`MEDIAN()`](#median),
  [`MODE()`](#mode),
  [`SUM()`](#sum),
  [`FIRST()`](#first),
  [`LAST()`](#last),
  [`MIN()`](#min),
  [`MAX()`](#max), and
  [`PERCENTILE()`](#percentile).


#### 示例

- #### 计算平均值的自然对数

  ```sql
  > SELECT LN(MEAN("temperature")) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(12m)
  name: air
  time                 ln
  ----                 --
  2021-09-18T00:00:00Z 4.0118683403978626
  2021-09-18T00:12:00Z 4.2626798770413155
  2021-09-18T00:24:00Z 4.31303376318693
  ```

该查询返回每12分钟的时间间隔对应的`temperature`的平均值的自然对数。

为了得到这些结果，CnosDB首先计算每12分钟的时间间隔对应的`temperature`的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`LN()`的情形一样：

  ```sql
  > SELECT MEAN("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(12m)
  name: air
  time                 mean
  ----                 ----
  2021-09-18T00:00:00Z 55.25
  2021-09-18T00:12:00Z 71
  2021-09-18T00:24:00Z 74.66666666666667
  ```

然后，CnosDB计算这些平均值的自然对数。

- ### LOG()

  返回field value的以`b`为底数的对数。

  #### 基本语法

  ```sql
  SELECT LOG( [ * | <field_key> ], <b> ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `LOG(field_key, b)`返回field key对应的field value的以`b`为底数的对数。

  `LOG(*, b)`返回在measurement中每个field key对应的field value的以`b`为底数的对数。

  `LOG()`支持数据类型为int64和float64的field value。

  基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`LOG()`和`GROUP BY time()`子句。

  ####示例

  下面的示例将使用[示例数据](https://gist.github.com/sanderson/8f8aec94a60b2c31a61f44a37737bfea?spm=a2c4g.11186623.2.87.41fc3ee27HC1R6)中的如下数据：

  ```sql
  > SELECT "temperature" FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 temperature
  ----                 -----------
  2021-09-18T00:00:00Z 51
  2021-09-18T00:03:00Z 60
  2021-09-18T00:06:00Z 55
  2021-09-18T00:09:00Z 55
  2021-09-18T00:12:00Z 63
  2021-09-18T00:15:00Z 74
  2021-09-18T00:18:00Z 79
  2021-09-18T00:21:00Z 68
  2021-09-18T00:24:00Z 70
  2021-09-18T00:27:00Z 79
  2021-09-18T00:30:00Z 75
  ```

  - #### 计算指定field key对应的field value的以4为底数的对数

  ```sql
  > SELECT LOG("temperature", 4) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 log
  ----                 ---
  2021-09-18T00:00:00Z 2.836212670985748
  2021-09-18T00:03:00Z 2.9534452978042594
  2021-09-18T00:06:00Z 2.89067985676233
  2021-09-18T00:09:00Z 2.89067985676233
  2021-09-18T00:12:00Z 2.9886399617499584
  2021-09-18T00:15:00Z 3.1047266828144746
  2021-09-18T00:18:00Z 3.1518903740885515
  2021-09-18T00:21:00Z 3.04373142062517
  2021-09-18T00:24:00Z 3.0646415084724836
  2021-09-18T00:27:00Z 3.1518903740885515
  2021-09-18T00:30:00Z 3.11440934524794
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的以4为底数的对数。

  - #### 计算measurement中每个field key对应的field value的以4为底数的对数
  ```sql
  > SELECT LOG(*, 4) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 log_pressure       log_temperature    log_visibility
  ----                 ------------       ---------------    --------------
  2021-09-18T00:00:00Z 3                  2.836212670985748  3.04373142062517
  2021-09-18T00:03:00Z 3.084962500721156  2.9534452978042594 3.1047266828144746
  2021-09-18T00:06:00Z 2.8774437510817346 2.89067985676233   3.133393270347451
  2021-09-18T00:09:00Z 3.0221970596792267 2.89067985676233   2.89067985676233
  2021-09-18T00:12:00Z 3                  2.9886399617499584 3.0646415084724836
  2021-09-18T00:15:00Z 2.928990497563786  3.1047266828144746 2.977098155193438
  2021-09-18T00:18:00Z 2.89067985676233   3.1518903740885515 2.8774437510817346
  2021-09-18T00:21:00Z 3                  3.04373142062517   2.928990497563786
  2021-09-18T00:24:00Z 3.0221970596792267 3.0646415084724836 3.054262228389085
  2021-09-18T00:27:00Z 3.133393270347451  3.1518903740885515 3.1427011094311244
  2021-09-18T00:30:00Z 2.977098155193438  3.11440934524794   3.160964047443681
  ```

  该查询返回measurement `air`中每个存储数值的field key对应的field value的以4为底数的对数。。measurement `air`中有三个数值类型的field：`temperature`、`pressure`以及`visibility`。

  - #### 计算指定field key对应的field value的以4为底数的对数并包含多个子句

  ```sql
  > SELECT LOG("temperature", 4) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' ORDER BY time DESC LIMIT 4 OFFSET 2
  name: air
  time                 log
  ----                 ---
  2021-09-18T00:24:00Z 3.0646415084724836
  2021-09-18T00:21:00Z 3.04373142062517
  2021-09-18T00:18:00Z 3.1518903740885515
  2021-09-18T00:15:00Z 3.1047266828144746
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的以4为底数的对数，它涵盖的时间范围在`2021-09-28T00:00:00Z`和`2021-09-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的`point`个数限制为4，并将返回的`point`偏移两个(即前两个`point`不返回）。

  #### 高级语法

  ```sql
  SELECT LOG(<function>( [ * | <field_key> ] ), <b>) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  高级语法需要一个`GROUP BY time()`子句和一个嵌套的cnosQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的对数。

  `LOG()`支持以下嵌套函数：

  - [`COUNT()`](#count)
  - [`MEAN()`](#mean)
  - [`MEDIAN()`](#median)
  - [`MODE()`](#mode)
  - [`SUM()`](#sum)
  - [`FIRST()`](#first)
  - [`LAST()`](#last)
  - [`MIN()`](#min)
  - [`MAX()`](#max)
  - [`PERCENTILE()`](#percentile)

  ####示例

  - #### 计算平均值的以4为底数的对数

  ```sql
  > SELECT LOG(MEAN("temperature"), 4) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(12m)
  name: air
  time                 log
  ----                 ---
  2021-09-18T00:00:00Z 2.8939512796957163
  2021-09-18T00:12:00Z 3.074873559752341
  2021-09-18T00:24:00Z 3.1111962106682243
  ```

  该查询返回每12分钟的时间间隔对应的`temperature`的平均值的以4为底数的对数。

  为了得到这些结果，CnosDB首先计算每12分钟的时间间隔对应的`temperature`的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`LOG()`的情形一样：

  ```sql
  > SELECT MEAN("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(12m)
  name: air
  time                 mean
  ----                 ----
  2021-09-18T00:00:00Z 55.25
  2021-09-18T00:12:00Z 71
  2021-09-18T00:24:00Z 74.66666666666667
  ```

  然后，CnosDB计算这些平均值的以4为底数的对数。

- ### LOG2()

  返回field value的以2为底数的对数。

  #### 基本语法

  ```sql
  SELECT LOG2( [ * | <field_key> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `LOG2(field_key)`返回field key对应的field value的以2为底数的对数。

  `LOG2(*)`返回在measurement中每个field key对应的field value的以2为底数的对数。

  `LOG2()`支持数据类型为int64和float64的field value。

  基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`LOG2()`和`GROUP BY time()`子句。

  ####示例

  下面的示例将使用[示例数据](https://gist.github.com/sanderson/8f8aec94a60b2c31a61f44a37737bfea?spm=a2c4g.11186623.2.88.41fc3ee27HC1R6)中的如下数据：

  ```sql
  > SELECT "temperature" FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 temperature
  ----                 -----------
  2021-09-18T00:00:00Z 51
  2021-09-18T00:03:00Z 60
  2021-09-18T00:06:00Z 55
  2021-09-18T00:09:00Z 55
  2021-09-18T00:12:00Z 63
  2021-09-18T00:15:00Z 74
  2021-09-18T00:18:00Z 79
  2021-09-18T00:21:00Z 68
  2021-09-18T00:24:00Z 70
  2021-09-18T00:27:00Z 79
  2021-09-18T00:30:00Z 75
  ```

  - #### 计算指定field key对应的field value的以2为底数的对数

  ```sql
  > SELECT LOG2("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 log2
  ----                 ----
  2021-09-18T00:00:00Z 5.672425341971495
  2021-09-18T00:03:00Z 5.906890595608519
  2021-09-18T00:06:00Z 5.78135971352466
  2021-09-18T00:09:00Z 5.78135971352466
  2021-09-18T00:12:00Z 5.977279923499917
  2021-09-18T00:15:00Z 6.20945336562895
  2021-09-18T00:18:00Z 6.303780748177103
  2021-09-18T00:21:00Z 6.087462841250339
  2021-09-18T00:24:00Z 6.129283016944966
  2021-09-18T00:27:00Z 6.303780748177103
  2021-09-18T00:30:00Z 6.22881869049588
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的以2为底数的对数。

  - #### 计算measurement中每个field key对应的field value的以2为底数的对数

  ```sql
  > SELECT LOG2(*) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 log2_pressure     log2_temperature  log2_visibility
  ----                 -------------     ----------------  ---------------
  2021-09-18T00:00:00Z 6                 5.672425341971495 6.087462841250339
  2021-09-18T00:03:00Z 6.169925001442312 5.906890595608519 6.20945336562895
  2021-09-18T00:06:00Z 5.754887502163468 5.78135971352466  6.266786540694901
  2021-09-18T00:09:00Z 6.044394119358453 5.78135971352466  5.78135971352466
  2021-09-18T00:12:00Z 6                 5.977279923499917 6.129283016944966
  2021-09-18T00:15:00Z 5.857980995127572 6.20945336562895  5.954196310386875
  2021-09-18T00:18:00Z 5.78135971352466  6.303780748177103 5.754887502163468
  2021-09-18T00:21:00Z 6                 6.087462841250339 5.857980995127572
  2021-09-18T00:24:00Z 6.044394119358453 6.129283016944966 6.108524456778169
  2021-09-18T00:27:00Z 6.266786540694901 6.303780748177103 6.285402218862249
  2021-09-18T00:30:00Z 5.954196310386875 6.22881869049588  6.321928094887363
  ```

  该查询返回measurement `air`中每个存储数值的field key对应的field value的以2为底数的对数。。measurement `air`中有三个数值类型的field：`temperature`、`pressure`以及`visibility`。

  - #### 计算指定field key对应的field value的以2为底数的对数并包含多个子句

  ```sql
  > SELECT LOG2("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' ORDER BY time DESC LIMIT 4 OFFSET 2
  name: air
  time                 log2
  ----                 ----
  2021-09-18T00:24:00Z 6.129283016944966
  2021-09-18T00:21:00Z 6.087462841250339
  2021-09-18T00:18:00Z 6.303780748177103
  2021-09-18T00:15:00Z 6.20945336562895
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的以2为底数的对数，它涵盖的时间范围在`2021-09-28T00:00:00Z`和`2021-09-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的`point`个数限制为4，并将返回的`point`偏移两个(即前两个`point`不返回）。

  #### 高级语法

  ```sql
  SELECT LOG2(<function>( [ * | <field_key> ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  高级语法需要一个`GROUP BY time()`子句和一个嵌套的cnosQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的以2为底数的对数。

  `LOG2()`支持以下嵌套函数：

  - [`COUNT()`](#count)
  - [`MEAN()`](#mean)
  - [`MEDIAN()`](#median)
  - [`MODE()`](#mode)
  - [`SUM()`](#sum)
  - [`FIRST()`](#first)
  - [`LAST()`](#last)
  - [`MIN()`](#min)
  - [`MAX()`](#max)
  - [`PERCENTILE()`](#percentile)

  ####示例

  - #### 计算平均值的以2为底数的对数

  ```sql
  > SELECT LOG2(MEAN("temperature")) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(12m)
  name: air
  time                 log2
  ----                 ----
  2021-09-18T00:00:00Z 5.787902559391432
  2021-09-18T00:12:00Z 6.149747119504682
  2021-09-18T00:24:00Z 6.222392421336448
  ```

  该查询返回每12分钟的时间间隔对应的`temperature`的平均值的以2为底数的对数。

  为了得到这些结果，CnosDB首先计算每12分钟的时间间隔对应的`temperature`的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`LOG2()`的情形一样：

  ```sql
  > SELECT MEAN("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(12m)
  name: air
  time                 mean
  ----                 ----
  2021-09-18T00:00:00Z 55.25
  2021-09-18T00:12:00Z 71
  2021-09-18T00:24:00Z 74.66666666666667
  ```

  然后，CnosDB计算这些平均值的以2为底数的对数。

- ### LOG10()

  返回field value的以10为底数的对数。

  #### 基本语法

  ```
  SELECT LOG10( [ * | <field_key> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `LOG10(field_key)`返回field key对应的field value的以10为底数的对数。

  `LOG10(*)`返回在measurement中每个field key对应的field value的以10为底数的对数。

  `LOG10()`支持数据类型为int64和float64的field value。

  基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`LOG10()`和`GROUP BY time()`子句。

  ####示例

  下面的示例将使用[示例数据](https://gist.github.com/sanderson/8f8aec94a60b2c31a61f44a37737bfea?spm=a2c4g.11186623.2.89.41fc3ee27HC1R6)中的如下数据：

  ```sql
  > SELECT "temperature" FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 temperature
  ----                 -----------
  2021-09-18T00:00:00Z 51
  2021-09-18T00:03:00Z 60
  2021-09-18T00:06:00Z 55
  2021-09-18T00:09:00Z 55
  2021-09-18T00:12:00Z 63
  2021-09-18T00:15:00Z 74
  2021-09-18T00:18:00Z 79
  2021-09-18T00:21:00Z 68
  2021-09-18T00:24:00Z 70
  2021-09-18T00:27:00Z 79
  2021-09-18T00:30:00Z 75
  ```

  - #### 计算指定field key对应的field value的以10为底数的对数

  ```sql
  > SELECT LOG10("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 log10
  ----                 -----
  2021-09-18T00:00:00Z 1.7075701760979363
  2021-09-18T00:03:00Z 1.7781512503836434
  2021-09-18T00:06:00Z 1.7403626894942439
  2021-09-18T00:09:00Z 1.7403626894942439
  2021-09-18T00:12:00Z 1.7993405494535817
  2021-09-18T00:15:00Z 1.869231719730976
  2021-09-18T00:18:00Z 1.8976270912904414
  2021-09-18T00:21:00Z 1.8325089127062364
  2021-09-18T00:24:00Z 1.845098040014257
  2021-09-18T00:27:00Z 1.8976270912904414
  2021-09-18T00:30:00Z 1.8750612633916999
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的以10为底数的对数。

  - #### 计算measurement中每个field key对应的field value的以10为底数的对数

  ```sql
  > SELECT LOG10(*) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 log10_pressure     log10_temperature  log10_visibility
  ----                 --------------     -----------------  ----------------
  2021-09-18T00:00:00Z 1.806179973983887  1.7075701760979363 1.8325089127062364
  2021-09-18T00:03:00Z 1.8573324964312685 1.7781512503836434 1.869231719730976
  2021-09-18T00:06:00Z 1.7323937598229686 1.7403626894942439 1.8864907251724818
  2021-09-18T00:09:00Z 1.8195439355418686 1.7403626894942439 1.7403626894942439
  2021-09-18T00:12:00Z 1.806179973983887  1.7993405494535817 1.845098040014257
  2021-09-18T00:15:00Z 1.7634279935629371 1.869231719730976  1.792391689498254
  2021-09-18T00:18:00Z 1.7403626894942439 1.8976270912904414 1.7323937598229686
  2021-09-18T00:21:00Z 1.806179973983887  1.8325089127062364 1.7634279935629371
  2021-09-18T00:24:00Z 1.8195439355418686 1.845098040014257  1.8388490907372554
  2021-09-18T00:27:00Z 1.8864907251724818 1.8976270912904414 1.8920946026904804
  2021-09-18T00:30:00Z 1.792391689498254  1.8750612633916999 1.9030899869919433
  ```

  该查询返回measurement `air`中每个存储数值的field key对应的field value的以10为底数的对数。。measurement `air`中有三个数值类型的field：`temperature`、`pressure`以及`visibility`。

  - #### 计算指定field key对应的field value的以10为底数的对数并包含多个子句

  ```sql
  > SELECT LOG10("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' ORDER BY time DESC LIMIT 4 OFFSET 2
  name: air
  time                 log10
  ----                 -----
  2021-09-18T00:24:00Z 1.845098040014257
  2021-09-18T00:21:00Z 1.8325089127062364
  2021-09-18T00:18:00Z 1.8976270912904414
  2021-09-18T00:15:00Z 1.869231719730976
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的以10为底数的对数，它涵盖的时间范围在`2021-09-28T00:00:00Z`和`2021-09-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的`point`个数限制为4，并将返回的`point`偏移两个(即前两个`point`不返回）。

  #### 高级语法

  ```
  SELECT LOG10(<function>( [ * | <field_key> ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  高级语法需要一个`GROUP BY time()`子句和一个嵌套的cnosQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的以10为底数的对数。

  `LOG10()`支持以下嵌套函数：

  - [`COUNT()`](#count)
  - [`MEAN()`](#mean)
  - [`MEDIAN()`](#median)
  - [`MODE()`](#mode)
  - [`SUM()`](#sum)
  - [`FIRST()`](#first)
  - [`LAST()`](#last)
  - [`MIN()`](#min)
  - [`MAX()`](#max)
  - [`PERCENTILE()`](#percentile)

  ####示例

  - #### 计算平均值的以10为底数的对数

  ```sql
  > SELECT LOG10(MEAN("temperature")) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(12m)
  name: air
  time                 log10
  ----                 -----
  2021-09-18T00:00:00Z 1.7423322823571483
  2021-09-18T00:12:00Z 1.8512583487190752
  2021-09-18T00:24:00Z 1.8731267636145004
  ```

  该查询返回每12分钟的时间间隔对应的`temperature`的平均值的以10为底数的对数。

  为了得到这些结果，CnosDB首先计算每12分钟的时间间隔对应的`temperature`的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`LOG10()`的情形一样：

  ```sql
  > SELECT MEAN("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(12m)
  name: air
  time                 mean
  ----                 ----
  2021-09-18T00:00:00Z 55.25
  2021-09-18T00:12:00Z 71
  2021-09-18T00:24:00Z 74.66666666666667
  ```

  然后，CnosDB计算这些平均值的以10为底数的对数。

- ### MOVING_AVERAGE()

  返回field value窗口的滚动平均值。

  #### 基本语法

  ```sql
  SELECT MOVING_AVERAGE( [ * | <field_key> | /<regular_expression>/ ] , <N> ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `MOVING_AVERAGE()`计算包含`N`个连续field value的窗口的滚动平均值。参数`N`是一个整数，并且它是必须的。

  `MOVING_AVERAGE(field_key,N)`返回field key对应的N个field value的滚动平均值。

  `MOVING_AVERAGE(/regular_expression/,N)`返回与正则表达式匹配的每个field key对应的N个field value的滚动平均值。

  `MOVING_AVERAGE(*,N)`返回在measurement中每个field key对应的N个field value的滚动平均值。

  `MOVING_AVERAGE()`支持数据类型为int64和float64的field value。

  基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`MOVING_AVERAGE()`和`GROUP BY time()`子句。

  ####示例

  下面的示例将使用`oceanic_station`数据集的如下数据：


  ```sql
  > SELECT "temperature" FROM "air" WHERE "station" = 'LianYunGang' AND time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z'
  name: air
  time                 temperature
  ----                 -----------
  2021-09-18T00:00:00Z 51
  2021-09-18T00:03:00Z 60
  2021-09-18T00:06:00Z 55
  2021-09-18T00:09:00Z 55
  2021-09-18T00:12:00Z 63
  2021-09-18T00:15:00Z 74
  2021-09-18T00:18:00Z 79
  2021-09-18T00:21:00Z 68
  2021-09-18T00:24:00Z 70
  2021-09-18T00:27:00Z 79
  2021-09-18T00:30:00Z 75
  ```

- #### 计算指定field key对应的field value的滚动平均值

  ```sql
  > SELECT MOVING_AVERAGE("temperature",2) FROM "air" WHERE "station" = 'LianYunGang' AND time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z'
  name: air
  time                 moving_average
  ----                 --------------
  2021-09-18T00:03:00Z 55.5
  2021-09-18T00:06:00Z 57.5
  2021-09-18T00:09:00Z 55
  2021-09-18T00:12:00Z 59
  2021-09-18T00:15:00Z 68.5
  2021-09-18T00:18:00Z 76.5
  2021-09-18T00:21:00Z 73.5
  2021-09-18T00:24:00Z 69
  2021-09-18T00:27:00Z 74.5
  2021-09-18T00:30:00Z 77
  ```

该查询返回measurement `air`中field key `temperature`对应的窗口大小为两个field value的滚动平均值。第一个结果(`2.09`)是原始数据中前两个field value的平均值：(2.064 + 2.116) / 2。第二个结果(`2.072`)是原始数据中第二和第三个field value的平均值：(2.116 + 2.028) / 2。

- #### 计算measurement中每个field key对应的field value的滚动平均值

  ```sql
  > SELECT MOVING_AVERAGE(*,3) FROM "air" WHERE "station" = 'LianYunGang' AND time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z'
  name: air
  time                 moving_average_pressure moving_average_temperature moving_average_visibility
  ----                 ----------------------- -------------------------- -------------------------
  2021-09-18T00:06:00Z 63.333333333333336      55.333333333333336         73
  2021-09-18T00:09:00Z 64                      56.666666666666664         68.66666666666667
  2021-09-18T00:12:00Z 61.333333333333336      57.666666666666664         67.33333333333333
  2021-09-18T00:15:00Z 62.666666666666664      64                         62.333333333333336
  2021-09-18T00:18:00Z 59                      72                         62
  2021-09-18T00:21:00Z 59                      73.66666666666667          58
  2021-09-18T00:24:00Z 61.666666666666664      72.33333333333333          60.333333333333336
  2021-09-18T00:27:00Z 69                      72.33333333333333          68.33333333333333
  2021-09-18T00:30:00Z 68.33333333333333       74.66666666666667          75.66666666666667
  ```

该查询返回measurement `air`中每个存储数值的field key对应的窗口大小为三个field value的滚动平均值。。measurement `air`中有三个数值类型的field：`temperature`、`pressure`以及`visibility`。

- #### 计算与正则表达式匹配的每个field key对应的field value的滚动平均值

  ```
  > SELECT MOVING_AVERAGE(/press/,4) FROM "air" WHERE "station" = 'LianYunGang' AND time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z'
  name: air
  time                 moving_average_pressure
  ----                 -----------------------
  2021-09-18T00:09:00Z 64
  2021-09-18T00:12:00Z 64
  2021-09-18T00:15:00Z 60.5
  2021-09-18T00:18:00Z 60.75
  2021-09-18T00:21:00Z 60.25
  2021-09-18T00:24:00Z 60.75
  2021-09-18T00:27:00Z 65.5
  2021-09-18T00:30:00Z 67.25
  ```

该查询返回measurement `air`中每个存储数值并包含单词`level`的field key对应的窗口大小为四个field value的滚动平均值。

- #### 计算指定field key对应的field value的滚动平均值并包含多个子句

  ```sql
  > SELECT MOVING_AVERAGE("temperature",2) FROM "air" WHERE "station" = 'LianYunGang' AND time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' ORDER BY time DESC LIMIT 2 OFFSET 3
  name: air
  time                 moving_average
  ----                 --------------
  2021-09-18T00:18:00Z 73.5
  2021-09-18T00:15:00Z 76.5
  ```

该查询返回measurement `air`中field key `temperature`对应的窗口大小为两个field value的滚动平均值，它涵盖的时间范围在`2021-09-28T00:00:00Z`和`2021-09-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的`point`个数限制为2，并将返回的`point`偏移三个(即前三个`point`不返回）。

#### 高级语法

  ```
  SELECT MOVING_AVERAGE(<function> ([ * | <field_key> | /<regular_expression>/ ]) , N ) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

高级语法需要一个`GROUP BY time()`子句和一个嵌套的cnosQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果之间的滚动平均值。

`MOVING_AVERAGE()`支持以下嵌套函数：

- [`COUNT()`](#count)
- [`MEAN()`](#mean)
- [`MEDIAN()`](#median)
- [`MODE()`](#mode)
- [`SUM()`](#sum)
- [`FIRST()`](#first)
- [`LAST()`](#last)
- [`MIN()`](#min)
- [`MAX()`](#max)
- [`PERCENTILE()`](#percentile)

####示例

- #### 计算最大值的滚动平均值

  ```sql
  > SELECT MOVING_AVERAGE(MAX("temperature"),2) FROM "air" WHERE "station" = 'LianYunGang' AND time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' GROUP BY time(12m)
  name: air
  time                 moving_average
  ----                 --------------
  2021-09-18T00:00:00Z 69.5
  2021-09-18T00:12:00Z 69.5
  2021-09-18T00:24:00Z 79
  ```

该查询返回每12分钟的时间间隔对应的`temperature`的最大值的窗口大小为两个值的滚动平均值。

为了得到这些结果，CnosDB首先计算每12分钟的时间间隔对应的`temperature`的最大值。这一步跟同时使用`MAX()`函数和`GROUP BY time()`子句、但不使用`MOVING_AVERAGE()`的情形一样：

  ```sql
  > SELECT MAX("temperature") FROM "air" WHERE "station" = 'LianYunGang' AND time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' GROUP BY time(12m)
  name: air
  time                 max
  ----                 ---
  2021-09-18T00:00:00Z 60
  2021-09-18T00:12:00Z 79
  2021-09-18T00:24:00Z 79
  ```

然后，CnosDB计算这些最大值的窗口大小为两个值的滚动平均值。最终查询结果中的第一个`point`(`2.121`)是前两个最大值的平均值(`(2.116 + 2.126) / 2`)。

- ### NON_NEGATIVE_DERIVATIVE()

  返回field value之间的非负变化率。非负变化率包括正的变化率和等于0的变化率。

  #### 基本语法

  ```sql
  SELECT NON_NEGATIVE_DERIVATIVE( [ * | <field_key> | /<regular_expression>/ ] [ , <unit> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  CnosDB计算field value之间的差值，并将这些结果转换为每个`unit`的变化率。参数`unit`的值是一个整数，后跟一个时间单位。这个参数是可选的，不是必须要有的。如果查询没有指定`unit`的值，那么`unit`默认为一秒(`1s`)。`NON_NEGATIVE_DERIVATIVE()`只返回正的变化率和等于0的变化率。

  `NON_NEGATIVE_DERIVATIVE(field_key)`返回field key对应的field value的非负变化率。

  `NON_NEGATIVE_DERIVATIVE(/regular_expression/)`返回与正则表达式匹配的每个field key对应的field value的非负变化率。

  `NON_NEGATIVE_DERIVATIVE(*)`返回在measurement中每个field key对应的field value的非负变化率。

  `NON_NEGATIVE_DERIVATIVE()`支持数据类型为int64和float64的field value。

  基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`NON_NEGATIVE_DERIVATIVE()`和`GROUP BY time()`子句。

  ####示例

  请查看`DERIVATIVE()`文档中的示例，`NON_NEGATIVE_DERIVATIVE()`跟`DERIVATIVE()`的运行方式相同，但是`NON_NEGATIVE_DERIVATIVE()`只返回查询结果中正的变化率和等于0的变化率。

  #### 高级语法

  ```sql
  SELECT NON_NEGATIVE_DERIVATIVE(<function> ([ * | <field_key> | /<regular_expression>/ ]) [ , <unit> ] ) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  高级语法需要一个`GROUP BY time()`子句和一个嵌套的cnosQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的非负导数。

  参数`unit`的值是一个整数，后跟一个时间单位。这个参数是可选的，不是必须要有的。如果查询没有指定`unit`的值，那么`unit`默认为`GROUP BY time()`的时间间隔。请注意，这里`unit`的默认值跟基本语法中`unit`的默认值不一样。`NON_NEGATIVE_DERIVATIVE()`只返回正的变化率和等于0的变化率。

  `NON_NEGATIVE_DERIVATIVE()`支持以下嵌套函数：

  - [`COUNT()`](#count)
  - [`MEAN()`](#mean)
  - [`MEDIAN()`](#median)
  - [`MODE()`](#mode)
  - [`SUM()`](#sum)
  - [`FIRST()`](#first)
  - [`LAST()`](#last)
  - [`MIN()`](#min)
  - [`MAX()`](#max)
  - [`PERCENTILE()`](#percentile)
  ####示例

  请查看`DERIVATIVE()`文档中的示例，`NON_NEGATIVE_DERIVATIVE()`跟`DERIVATIVE()`的运行方式相同，但是`NON_NEGATIVE_DERIVATIVE()`只返回查询结果中正的变化率和等于0的变化率。

- ### NON_NEGATIVE_DIFFERENCE()

  返回field value之间的非负差值。非负差值包括正的差值和等于0的差值。

  #### 基本语法

  ```
  SELECT NON_NEGATIVE_DIFFERENCE( [ * | <field_key> | /<regular_expression>/ ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `NON_NEGATIVE_DIFFERENCE(field_key)`返回field key对应的field value的非负差值。

  `NON_NEGATIVE_DIFFERENCE(/regular_expression/)`返回与正则表达式匹配的每个field key对应的field value的非负差值。

  `NON_NEGATIVE_DIFFERENCE(*)`返回在measurement中每个field key对应的field value的非负差值。

  `NON_NEGATIVE_DIFFERENCE()`支持数据类型为int64和float64的field value。

  基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`NON_NEGATIVE_DIFFERENCE()`和`GROUP BY time()`子句。

  ####示例

  请查看`DIFFERENCE()`文档中的示例，`NON_NEGATIVE_DIFFERENCE()`跟`DIFFERENCE()`的运行方式相同，但是`NON_NEGATIVE_DIFFERENCE()`只返回查询结果中正的差值和等于0的差值。

  #### 高级语法

  ```sql
  SELECT NON_NEGATIVE_DIFFERENCE(<function>( [ * | <field_key> | /<regular_expression>/ ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  高级语法需要一个`GROUP BY time()`子句和一个嵌套的cnosQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果之间的非负差值。

  `NON_NEGATIVE_DIFFERENCE()支持以下嵌套函数：

  - [`COUNT()`](#count)
  - [`MEAN()`](#mean)
  - [`MEDIAN()`](#median)
  - [`MODE()`](#mode)
  - [`SUM()`](#sum)
  - [`FIRST()`](#first)
  - [`LAST()`](#last)
  - [`MIN()`](#min)
  - [`MAX()`](#max)
  - [`PERCENTILE()`](#percentile)

  ####示例

  请查看`DIFFERENCE()`文档中的示例，`NON_NEGATIVE_DIFFERENCE()`跟`DIFFERENCE()`的运行方式相同，但是`NON_NEGATIVE_DIFFERENCE()`只返回查询结果中正的差值和等于0的差值。

- ### POW()

  返回field value的`x`次方。

  #### 基本语法

  ```
  SELECT POW( [ * | <field_key> ], <x> ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `POW(field_key, x)`返回field key对应的field value的`x`次方。

  `POW(*, x)`返回在measurement中每个field key对应的field value的`x`次方。

  `POW()`支持数据类型为int64和float64的field value。

  基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`POW()`和`GROUP BY time()`子句。

  ####示例

  下面的示例将使用[示例数据](https://gist.github.com/sanderson/8f8aec94a60b2c31a61f44a37737bfea?spm=a2c4g.11186623.2.90.41fc3ee27HC1R6)中的如下数据：

  ```sql
  > SELECT "temperature" FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 temperature
  ----                 -----------
  2021-09-18T00:00:00Z 51
  2021-09-18T00:03:00Z 60
  2021-09-18T00:06:00Z 55
  2021-09-18T00:09:00Z 55
  2021-09-18T00:12:00Z 63
  2021-09-18T00:15:00Z 74
  2021-09-18T00:18:00Z 79
  2021-09-18T00:21:00Z 68
  2021-09-18T00:24:00Z 70
  2021-09-18T00:27:00Z 79
  2021-09-18T00:30:00Z 75
  ```

  - #### 计算指定field key对应的field value的4次方

  ```sql
  > SELECT POW("temperature", 4) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 pow
  ----                 ---
  2021-09-18T00:00:00Z 6765201
  2021-09-18T00:03:00Z 12960000
  2021-09-18T00:06:00Z 9150625
  2021-09-18T00:09:00Z 9150625
  2021-09-18T00:12:00Z 15752961
  2021-09-18T00:15:00Z 29986576
  2021-09-18T00:18:00Z 38950081
  2021-09-18T00:21:00Z 21381376
  2021-09-18T00:24:00Z 24010000
  2021-09-18T00:27:00Z 38950081
  2021-09-18T00:30:00Z 31640625
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的4次方。

  - #### 计算measurement中每个field key对应的field value的4次方

  ```sql
  > SELECT POW(*, 4) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 pow_pressure pow_temperature pow_visibility
  ----                 ------------ --------------- --------------
  2021-09-18T00:00:00Z 16777216     6765201         21381376
  2021-09-18T00:03:00Z 26873856     12960000        29986576
  2021-09-18T00:06:00Z 8503056      9150625         35153041
  2021-09-18T00:09:00Z 18974736     9150625         9150625
  2021-09-18T00:12:00Z 16777216     15752961        24010000
  2021-09-18T00:15:00Z 11316496     29986576        14776336
  2021-09-18T00:18:00Z 9150625      38950081        8503056
  2021-09-18T00:21:00Z 16777216     21381376        11316496
  2021-09-18T00:24:00Z 18974736     24010000        22667121
  2021-09-18T00:27:00Z 35153041     38950081        37015056
  2021-09-18T00:30:00Z 14776336     31640625        40960000
  ```

  该查询返回measurement `air`中每个存储数值的field key对应的field value的4次方。。measurement `air`中有三个数值类型的field：`temperature`、`pressure`以及`visibility`。

  - #### 计算指定field key对应的field value的4次方并包含多个子句

  ```sql
  > SELECT POW("temperature", 4) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' ORDER BY time DESC LIMIT 4 OFFSET 2
  name: air
  time                 pow
  ----                 ---
  2021-09-18T00:24:00Z 24010000
  2021-09-18T00:21:00Z 21381376
  2021-09-18T00:18:00Z 38950081
  2021-09-18T00:15:00Z 29986576
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的4次方，它涵盖的时间范围在`2021-09-28T00:00:00Z`和`2021-09-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的`point`个数限制为4，并将返回的`point`偏移两个(即前两个`point`不返回）。

  #### 高级语法

  ```sql
  SELECT POW(<function>( [ * | <field_key> ] ), <x>) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  高级语法需要一个`GROUP BY time()`子句和一个嵌套的cnosQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的`x`次方。

  `POW()`支持以下嵌套函数：

  - [`COUNT()`](#count)
  - [`MEAN()`](#mean)
  - [`MEDIAN()`](#median)
  - [`MODE()`](#mode)
  - [`SUM()`](#sum)
  - [`FIRST()`](#first)
  - [`LAST()`](#last)
  - [`MIN()`](#min)
  - [`MAX()`](#max)
  - [`PERCENTILE()`](#percentile)

  ####示例

  - #### 计算平均值的4次方

  ```sql
  > SELECT POW(MEAN("temperature"), 4) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(12m)
  name: air
  time                 pow
  ----                 ---
  2021-09-18T00:00:00Z 9318137.81640625
  2021-09-18T00:12:00Z 25411681
  2021-09-18T00:24:00Z 31081863.901234582
  ```

  该查询返回每12分钟的时间间隔对应的`temperature`的平均值的4次方。

  为了得到这些结果，CnosDB首先计算每12分钟的时间间隔对应的`temperature`的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`POW()`的情形一样：

  ```sql
  > SELECT MEAN("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(12m)
  name: air
  time                 mean
  ----                 ----
  2021-09-18T00:00:00Z 55.25
  2021-09-18T00:12:00Z 71
  2021-09-18T00:24:00Z 74.66666666666667
  ```

  然后，CnosDB计算这些平均值的4次方。

- ### ROUND()

  返回指定值的四舍五入后的整数。

  #### 基本语法

  ```
  SELECT ROUND( [ * | <field_key> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `ROUND(field_key)`返回field key对应的field value四舍五入后的整数。

  `ROUND(*)`返回在measurement中每个field key对应的field value四舍五入后的整数。

  `ROUND()`支持数据类型为int64和float64的field value。

  基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`ROUND()`和`GROUP BY time()`子句。

  ####示例

  下面的示例将使用[示例数据](https://gist.github.com/sanderson/8f8aec94a60b2c31a61f44a37737bfea?spm=a2c4g.11186623.2.91.41fc3ee27HC1R6)中的如下数据：

  ```sql
  > SELECT "temperature" FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 temperature
  ----                 -----------
  2021-09-18T00:00:00Z 51
  2021-09-18T00:03:00Z 60
  2021-09-18T00:06:00Z 55
  2021-09-18T00:09:00Z 55
  2021-09-18T00:12:00Z 63
  2021-09-18T00:15:00Z 74
  2021-09-18T00:18:00Z 79
  2021-09-18T00:21:00Z 68
  2021-09-18T00:24:00Z 70
  2021-09-18T00:27:00Z 79
  2021-09-18T00:30:00Z 75
  ```

  - #### 计算指定field key对应的field value四舍五入后的整数

  ```sql
  > SELECT ROUND("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 round
  ----                 -----
  2021-09-18T00:00:00Z 51
  2021-09-18T00:03:00Z 60
  2021-09-18T00:06:00Z 55
  2021-09-18T00:09:00Z 55
  2021-09-18T00:12:00Z 63
  2021-09-18T00:15:00Z 74
  2021-09-18T00:18:00Z 79
  2021-09-18T00:21:00Z 68
  2021-09-18T00:24:00Z 70
  2021-09-18T00:27:00Z 79
  2021-09-18T00:30:00Z 75
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value四舍五入后的整数。

  - #### 计算measurement中每个field key对应的field value四舍五入后的整数

  ```sql
  > SELECT ROUND(*) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 round_pressure round_temperature round_visibility
  ----                 -------------- ----------------- ----------------
  2021-09-18T00:00:00Z 64             51                68
  2021-09-18T00:03:00Z 72             60                74
  2021-09-18T00:06:00Z 54             55                77
  2021-09-18T00:09:00Z 66             55                55
  2021-09-18T00:12:00Z 64             63                70
  2021-09-18T00:15:00Z 58             74                62
  2021-09-18T00:18:00Z 55             79                54
  2021-09-18T00:21:00Z 64             68                58
  2021-09-18T00:24:00Z 66             70                69
  2021-09-18T00:27:00Z 77             79                78
  2021-09-18T00:30:00Z 62             75                80
  ```

  - #### 计算指定field key对应的field value四舍五入后的整数并包含多个子句

  ```sql
  > SELECT ROUND("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' ORDER BY time DESC LIMIT 4 OFFSET 2
  name: air
  time                 round
  ----                 -----
  2021-09-18T00:24:00Z 70
  2021-09-18T00:21:00Z 68
  2021-09-18T00:18:00Z 79
  2021-09-18T00:15:00Z 74
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value四舍五入后的整数，它涵盖的时间范围在`2021-09-28T00:00:00Z`和`2021-09-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的`point`个数限制为4，并将返回的`point`偏移两个(即前两个`point`不返回）。

  #### 高级语法

  ```sql
  SELECT ROUND(<function>( [ * | <field_key> ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  高级语法需要一个`GROUP BY time()`子句和一个嵌套的cnosQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果四舍五入后的整数。

  `ROUND()`支持以下嵌套函数：

  - [`COUNT()`](#count)
  - [`MEAN()`](#mean)
  - [`MEDIAN()`](#median)
  - [`MODE()`](#mode)
  - [`SUM()`](#sum)
  - [`FIRST()`](#first)
  - [`LAST()`](#last)
  - [`MIN()`](#min)
  - [`MAX()`](#max)
  - [`PERCENTILE()`](#percentile)

  ####示例

  - #### 计算平均值四舍五入后的整数

  ```sql
  > SELECT ROUND(MEAN("temperature")) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(12m)
  name: air
  time                 round
  ----                 -----
  2021-09-18T00:00:00Z 55
  2021-09-18T00:12:00Z 71
  2021-09-18T00:24:00Z 75
  ```

  该查询返回每12分钟的时间间隔对应的`temperature`的平均值四舍五入后的整数。

  为了得到这些结果，CnosDB首先计算每12分钟的时间间隔对应的`temperature`的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`ROUND()`的情形一样：

  ```sql
  > SELECT MEAN("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(12m)
  name: air
  time                 mean
  ----                 ----
  2021-09-18T00:00:00Z 55.25
  2021-09-18T00:12:00Z 71
  2021-09-18T00:24:00Z 74.66666666666667
  ```

  然后，CnosDB计算这些平均值四舍五入后的整数。

- ### SIN()

  返回field value的正弦值。

  #### 基本语法

  ```sql
  SELECT SIN( [ * | <field_key> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `SIN(field_key)`返回field key对应的field value的正弦值。

  `SIN(*)`返回在measurement中每个field key对应的field value的正弦值。

  `SIN()`支持数据类型为int64和float64的field value。

  基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`SIN()`和`GROUP BY time()`子句。

  ####示例

  下面的示例将使用`oceanic_station`数据集的如下数据：

  ```sql
  > SELECT "temperature" FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 temperature
  ----                 -----------
  2021-09-18T00:00:00Z 51
  2021-09-18T00:03:00Z 60
  2021-09-18T00:06:00Z 55
  2021-09-18T00:09:00Z 55
  2021-09-18T00:12:00Z 63
  2021-09-18T00:15:00Z 74
  2021-09-18T00:18:00Z 79
  2021-09-18T00:21:00Z 68
  2021-09-18T00:24:00Z 70
  2021-09-18T00:27:00Z 79
  2021-09-18T00:30:00Z 75
  ```

  - #### 计算指定field key对应的field value的正弦值

  ```sql
  > SELECT SIN("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 sin
  ----                 ---
  2021-09-18T00:00:00Z 0.6702291758433747
  2021-09-18T00:03:00Z -0.3048106211022167
  2021-09-18T00:06:00Z -0.9997551733586199
  2021-09-18T00:09:00Z -0.9997551733586199
  2021-09-18T00:12:00Z 0.16735570030280694
  2021-09-18T00:15:00Z -0.9851462604682474
  2021-09-18T00:18:00Z -0.4441126687075084
  2021-09-18T00:21:00Z -0.8979276806892912
  2021-09-18T00:24:00Z 0.7738906815578891
  2021-09-18T00:27:00Z -0.4441126687075084
  2021-09-18T00:30:00Z -0.38778163540943045
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的正弦值。

  - #### 计算measurement中每个field key对应的field value的正弦值

  ```sql
  > SELECT SIN(*) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 sin_pressure          sin_temperature      sin_visibility
  ----                 ------------          ---------------      --------------
  2021-09-18T00:00:00Z 0.9200260381967907    0.6702291758433747   -0.8979276806892912
  2021-09-18T00:03:00Z 0.25382336276203626   -0.3048106211022167  -0.9851462604682474
  2021-09-18T00:06:00Z -0.5587890488516162   -0.9997551733586199  0.9995201585807312
  2021-09-18T00:09:00Z -0.026551154023966794 -0.9997551733586199  -0.9997551733586199
  2021-09-18T00:12:00Z 0.9200260381967907    0.16735570030280694  0.7738906815578891
  2021-09-18T00:15:00Z 0.9928726480845371    -0.9851462604682474  -0.7391806966492229
  2021-09-18T00:18:00Z -0.9997551733586199   -0.4441126687075084  -0.5587890488516162
  2021-09-18T00:21:00Z 0.9200260381967907    -0.8979276806892912  0.9928726480845371
  2021-09-18T00:24:00Z -0.026551154023966794 0.7738906815578891   -0.11478481378318722
  2021-09-18T00:27:00Z 0.9995201585807312    -0.4441126687075084  0.5139784559875352
  2021-09-18T00:30:00Z -0.7391806966492229   -0.38778163540943045 -0.9938886539233751
  ```

  该查询返回measurement `air`中每个存储数值的field key对应的field value的正弦值。。measurement `air`中有三个数值类型的field：`temperature`、`pressure`以及`visibility`。

  - #### 计算指定field key对应的field value的正弦值并包含多个子句

  ```sql
  > SELECT SIN("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' ORDER BY time DESC LIMIT 4 OFFSET 2
  name: air
  time                 sin
  ----                 ---
  2021-09-18T00:24:00Z 0.7738906815578891
  2021-09-18T00:21:00Z -0.8979276806892912
  2021-09-18T00:18:00Z -0.4441126687075084
  2021-09-18T00:15:00Z -0.9851462604682474
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的正弦值，它涵盖的时间范围在`2021-09-28T00:00:00Z`和`2021-09-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的`point`个数限制为4，并将返回的`point`偏移两个(即前两个`point`不返回）。

  #### 高级语法

  ```sql
  SELECT SIN(<function>( [ * | <field_key> ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  高级语法需要一个`GROUP BY time()`子句和一个嵌套的cnosQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的正弦值。

  `SIN()`支持以下嵌套函数：

  - [`COUNT()`](#count)
  - [`MEAN()`](#mean)
  - [`MEDIAN()`](#median)
  - [`MODE()`](#mode)
  - [`SUM()`](#sum)
  - [`FIRST()`](#first)
  - [`LAST()`](#last)
  - [`MIN()`](#min)
  - [`MAX()`](#max)
  - [`PERCENTILE()`](#percentile)

  ####示例

  - #### 计算平均值的正弦值

  ```sql
  > SELECT SIN(MEAN("temperature")) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(12m)
  name: air
  time                 sin
  ----                 ---
  2021-09-18T00:00:00Z -0.9632009590319781
  2021-09-18T00:12:00Z 0.9510546532543747
  2021-09-18T00:24:00Z -0.6680290772524845
  ```

  该查询返回每12分钟的时间间隔对应的`temperature`的平均值的正弦值。

  为了得到这些结果，CnosDB首先计算每12分钟的时间间隔对应的`temperature`的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`SIN()`的情形一样：

  ```sql
  > SELECT MEAN("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(12m)
  name: air
  time                 mean
  ----                 ----
  2021-09-18T00:00:00Z 55.25
  2021-09-18T00:12:00Z 71
  2021-09-18T00:24:00Z 74.66666666666667
  ```

  然后，CnosDB计算这些平均值的正弦值。

- ### SQRT()

  返回field value的平方根。

  #### 基本语法

  ```
  SELECT SQRT( [ * | <field_key> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `SQRT(field_key)`返回field key对应的field value的平方根。

  `SQRT(*)`返回在measurement中每个field key对应的field value的平方根。

  `SQRT()`支持数据类型为int64和float64的field value。

  基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`SQRT()`和`GROUP BY time()`子句。

  ####示例

  下面的示例将使用”oceanic_station”数据集的如下数据：

  ```sql
  > SELECT "temperature" FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 temperature
  ----                 -----------
  2021-09-18T00:00:00Z 51
  2021-09-18T00:03:00Z 60
  2021-09-18T00:06:00Z 55
  2021-09-18T00:09:00Z 55
  2021-09-18T00:12:00Z 63
  2021-09-18T00:15:00Z 74
  2021-09-18T00:18:00Z 79
  2021-09-18T00:21:00Z 68
  2021-09-18T00:24:00Z 70
  2021-09-18T00:27:00Z 79
  2021-09-18T00:30:00Z 75
  ```

  - #### 计算指定field key对应的field value的平方根

  ```sql
  > SELECT SQRT("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 sqrt
  ----                 ----
  2021-09-18T00:00:00Z 7.14142842854285
  2021-09-18T00:03:00Z 7.745966692414834
  2021-09-18T00:06:00Z 7.416198487095663
  2021-09-18T00:09:00Z 7.416198487095663
  2021-09-18T00:12:00Z 7.937253933193772
  2021-09-18T00:15:00Z 8.602325267042627
  2021-09-18T00:18:00Z 8.888194417315589
  2021-09-18T00:21:00Z 8.246211251235321
  2021-09-18T00:24:00Z 8.366600265340756
  2021-09-18T00:27:00Z 8.888194417315589
  2021-09-18T00:30:00Z 8.660254037844387
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的平方根。

  - #### 计算measurement中每个field key对应的field value的平方根

  ```sql
  > SELECT SQRT(*) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 sqrt_pressure      sqrt_temperature  sqrt_visibility
  ----                 -------------      ----------------  ---------------
  2021-09-18T00:00:00Z 8                  7.14142842854285  8.246211251235321
  2021-09-18T00:03:00Z 8.48528137423857   7.745966692414834 8.602325267042627
  2021-09-18T00:06:00Z 7.3484692283495345 7.416198487095663 8.774964387392123
  2021-09-18T00:09:00Z 8.12403840463596   7.416198487095663 7.416198487095663
  2021-09-18T00:12:00Z 8                  7.937253933193772 8.366600265340756
  2021-09-18T00:15:00Z 7.615773105863909  8.602325267042627 7.874007874011811
  2021-09-18T00:18:00Z 7.416198487095663  8.888194417315589 7.3484692283495345
  2021-09-18T00:21:00Z 8                  8.246211251235321 7.615773105863909
  2021-09-18T00:24:00Z 8.12403840463596   8.366600265340756 8.306623862918075
  2021-09-18T00:27:00Z 8.774964387392123  8.888194417315589 8.831760866327848
  2021-09-18T00:30:00Z 7.874007874011811  8.660254037844387 8.94427190999916
  ```

  该查询返回measurement `air`中每个存储数值的field key对应的field value的平方根。。measurement `air`中有三个数值类型的field：`temperature`、`pressure`以及`visibility`。

  - #### 计算指定field key对应的field value的平方根并包含多个子句

  ```sql
  > SELECT SQRT("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' ORDER BY time DESC LIMIT 4 OFFSET 2
  name: air
  time                 sqrt
  ----                 ----
  2021-09-18T00:24:00Z 8.366600265340756
  2021-09-18T00:21:00Z 8.246211251235321
  2021-09-18T00:18:00Z 8.888194417315589
  2021-09-18T00:15:00Z 8.602325267042627
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的平方根，它涵盖的时间范围在`2021-09-28T00:00:00Z`和`2021-09-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的`point`个数限制为4，并将返回的`point`偏移两个(即前两个`point`不返回）。

  #### 高级语法

  ```
  SELECT SQRT(<function>( [ * | <field_key> ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  高级语法需要一个`GROUP BY time()`子句和一个嵌套的cnosQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的平方根。

  `SQRT()`支持以下嵌套函数：

  - [`COUNT()`](#count)
  - [`MEAN()`](#mean)
  - [`MEDIAN()`](#median)
  - [`MODE()`](#mode)
  - [`SUM()`](#sum)
  - [`FIRST()`](#first)
  - [`LAST()`](#last)
  - [`MIN()`](#min)
  - [`MAX()`](#max)
  - [`PERCENTILE()`](#percentile)

  ####示例

  - #### 计算平均值的平方根

  ```sql
  > SELECT SQRT(MEAN("temperature")) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(12m)
  name: air
  time                 sqrt
  ----                 ----
  2021-09-18T00:00:00Z 7.433034373659253
  2021-09-18T00:12:00Z 8.426149773176359
  2021-09-18T00:24:00Z 8.640987597877148
  ```

  该查询返回每12分钟的时间间隔对应的`temperature`的平均值的平方根。

  为了得到这些结果，CnosDB首先计算每12分钟的时间间隔对应的`temperature`的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`SQRT()`的情形一样：

  ```sql
  > SELECT MEAN("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(12m)
  name: air
  time                 mean
  ----                 ----
  2021-09-18T00:00:00Z 55.25
  2021-09-18T00:12:00Z 71
  2021-09-18T00:24:00Z 74.66666666666667
  ```

  然后，CnosDB计算这些平均值的平方根。

- ### TAN()

  返回field value的正切值。

  #### 基本语法

  ```
  SELECT TAN( [ * | <field_key> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `TAN(field_key)`返回field key对应的field value的正切值。

  `TAN(*)`返回在measurement中每个field key对应的field value的正切值。

  `TAN()`支持数据类型为int64和float64的field value。

  基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`TAN()`和`GROUP BY time()`子句。

  ####示例

  下面的示例将使用`oceanic_station`数据集的如下数据：

  ```sql
  > SELECT "temperature" FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 temperature
  ----                 -----------
  2021-09-18T00:00:00Z 51
  2021-09-18T00:03:00Z 60
  2021-09-18T00:06:00Z 55
  2021-09-18T00:09:00Z 55
  2021-09-18T00:12:00Z 63
  2021-09-18T00:15:00Z 74
  2021-09-18T00:18:00Z 79
  2021-09-18T00:21:00Z 68
  2021-09-18T00:24:00Z 70
  2021-09-18T00:27:00Z 79
  2021-09-18T00:30:00Z 75
  ```

  - #### 计算指定field key对应的field value的正切值

  ```sql
  > SELECT TAN("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 tan
  ----                 ---
  2021-09-18T00:00:00Z 0.9030861493754311
  2021-09-18T00:03:00Z 0.320040389379563
  2021-09-18T00:06:00Z -45.18308791052113
  2021-09-18T00:09:00Z -45.18308791052113
  2021-09-18T00:12:00Z 0.16974975208268753
  2021-09-18T00:15:00Z -5.737022539278999
  2021-09-18T00:18:00Z 0.49567753318135577
  2021-09-18T00:21:00Z -2.040081598015946
  2021-09-18T00:24:00Z 1.2219599181369432
  2021-09-18T00:27:00Z 0.49567753318135577
  2021-09-18T00:30:00Z -0.42070095062112434
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的正切值。

  - #### 计算measurement中每个field key对应的field value的正切值

  ```sql
  > SELECT TAN(*) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang'
  name: air
  time                 tan_pressure         tan_temperature      tan_visibility
  ----                 ------------         ---------------      --------------
  2021-09-18T00:00:00Z 2.3478603091954366   0.9030861493754311   -2.040081598015946
  2021-09-18T00:03:00Z -0.26241737750193517 0.320040389379563    -5.737022539278999
  2021-09-18T00:06:00Z 0.6738001006480597   -45.18308791052113   -32.268575775934416
  2021-09-18T00:09:00Z 0.026560517776039395 -45.18308791052113   -45.18308791052113
  2021-09-18T00:12:00Z 2.3478603091954366   0.16974975208268753  1.2219599181369432
  2021-09-18T00:15:00Z 8.33085685249046     -5.737022539278999   -1.0975097786622852
  2021-09-18T00:18:00Z -45.18308791052113   0.49567753318135577  0.6738001006480597
  2021-09-18T00:21:00Z 2.3478603091954366   -2.040081598015946   8.33085685249046
  2021-09-18T00:24:00Z 0.026560517776039395 1.2219599181369432   -0.11554854579453279
  2021-09-18T00:27:00Z -32.268575775934416  0.49567753318135577  -0.5991799983411151
  2021-09-18T00:30:00Z -1.0975097786622852  -0.42070095062112434 9.00365494560708
  ```

  该查询返回measurement `air`中每个存储数值的field key对应的field value的正切值。。measurement `air`中有三个数值类型的field：`temperature`、`pressure`以及`visibility`。

  - #### 计算指定field key对应的field value的正切值并包含多个子句

  ```sql
  > SELECT TAN("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' ORDER BY time DESC LIMIT 4 OFFSET 2
  name: air
  time                 tan
  ----                 ---
  2021-09-18T00:24:00Z 1.2219599181369432
  2021-09-18T00:21:00Z -2.040081598015946
  2021-09-18T00:18:00Z 0.49567753318135577
  2021-09-18T00:15:00Z -5.737022539278999
  ```

  该查询返回measurement `air`中field key `temperature`对应的field value的正切值，它涵盖的时间范围在`2021-09-28T00:00:00Z`和`2021-09-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的`point`个数限制为4，并将返回的`point`偏移两个(即前两个`point`不返回）。

  #### 高级语法

  ```sql
  SELECT TAN(<function>( [ * | <field_key> ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  高级语法需要一个`GROUP BY time()`子句和一个嵌套的cnosQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的正切值。

  `TAN()`支持以下嵌套函数：

  - [`COUNT()`](#count)
  - [`MEAN()`](#mean)
  - [`MEDIAN()`](#median)
  - [`MODE()`](#mode)
  - [`SUM()`](#sum)
  - [`FIRST()`](#first)
  - [`LAST()`](#last)
  - [`MIN()`](#min)
  - [`MAX()`](#max)
  - [`PERCENTILE()`](#percentile)

  ####示例

  - #### 计算平均值的正弦值

  ```sql
  > SELECT TAN(MEAN("temperature")) FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(12m)
  name: air
  time                 tan
  ----                 ---
  2021-09-18T00:00:00Z -3.583573177439047
  2021-09-18T00:12:00Z -3.0776204031933605
  2021-09-18T00:24:00Z -0.8977254452596822
  ```

  该查询返回每12分钟的时间间隔对应的`temperature`的平均值的正切值。

  为了得到这些结果，CnosDB首先计算每12分钟的时间间隔对应的`temperature`的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`TAN()`的情形一样：

  ```sql
  > SELECT MEAN("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:30:00Z' AND "station" = 'LianYunGang' GROUP BY time(12m)
  name: air
  time                 mean
  ----                 ----
  2021-09-18T00:00:00Z 55.25
  2021-09-18T00:12:00Z 71
  2021-09-18T00:24:00Z 74.66666666666667
  ```

  然后，CnosDB计算这些平均值的正切值。

### 预测函数

- ### HOLT_WINTERS()

  * 使用[Holt-Winters](https://www.otexts.org/fpp/7/5?spm=a2c4g.11186623.2.92.41fc3ee27HC1R6)的季节性方法返回N个预测的field value。

    `HOLT_WINTERS()`可用于：

    - 预测时间什么时候会超过给定的阈值
    - 将预测值与实际值进行比较，检测数据中的异常

  #### 语法

  ```
  SELECT HOLT_WINTERS[_WITH-FIT](<function>(<field_key>),<N>,<S>) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
  ```

  `HOLT_WINTERS(function(field_key),N,S)`返回field key对应的`N`个季节性调整的预测field value。

  `N`个预测值出现的时间间隔跟group by time时间间隔相同。如果您的`GROUP BY time()`时间间隔是`6m`并且`N`等于`3`，那么您将会得到3个时间间隔为6分钟的预测值。

  `S`是一个季节性模式参数，并且根据`GROUP BY time()`时间间隔限定一个季节性模式的长度。如果您的`GROUP BY time()`时间间隔是`2m`并且`S`等于`3`，那么这个季节性模式每六分钟出现一次，也就是每三个`point`。如果您不希望季节性调整您的预测值，请将`S`设置为`0`或`1`。

  `HOLT_WINTERS_WITH_FIT(function(field_key),N,S)`除了返回field key对应的`N`个季节性调整的预测field value，还返回拟合值。

  `HOLT_WINTERS()`和`HOLT_WINTERS_WITH_FIT()`处理以相同的时间间隔出现的数据；嵌套的cnosQL函数和`GROUP BY time()`子句确保Holt-Winters函数能够对常规数据进行操作。

  `HOLT_WINTERS()`和`HOLT_WINTERS_WITH_FIT()`支持数据类型为int64和float64的field value。

  #### 示例

  - #### 预测指定field key的field value

  - #### 原始数据

  该示例重点关注`oceanic_station`数据集的如下数据：

  ```sql
  SELECT "temperature" FROM "oceanic_station"."autogen"."air" WHERE "station"='LianYunGang' AND time >= '2021-09-12 12:12:00' AND time <= '2021-09-28 04:00:00'
  ```

  - #### 步骤一：匹配原始数据的趋势

  编写一个`GROUP BY time()`查询，使得它匹配原始`temperature`数据的总体趋势。这里，我们使用了`FIRST()`函数：

  ```sql
  SELECT FIRST("temperature") FROM "oceanic_station"."autogen"."air" WHERE "station"='LianYunGang' and time >= '2021-09-12 12:12:00' and time <= '2021-09-28 04:00:00' GROUP BY time(379m,348m)
  ```

  在`GROUP BY time()`子句中，第一个参数(`379m`)匹配`temperature`数据中每个波峰和波谷之间发生的时间长度，第二个参数(`348m`)是一个偏移间隔，它通过改变CnosDB的默认`GROUP BY time()`边界来匹配原始数据的时间范围。

  - #### 步骤二：确定季节性模式

  使用步骤一中查询的信息确定数据中的季节性模式。

  - #### 步骤三：应用`HOLT_WINTERS()`函数

  在查询中加入Holt-Winters函数。这里，我们使用`HOLT_WINTERS_WITH_FIT()`来查看拟合值和预测值：

  ```sql
  SELECT HOLT_WINTERS_WITH_FIT(FIRST("temperature"),10,4) FROM "oceanic_station"."autogen"."air" WHERE "station"='LianYunGang' AND time >= '2021-09-12 12:12:00' AND time <= '2021-09-28 04:00:00' GROUP BY time(379m,348m)
  ```

  在`HOLT_WINTERS_WITH_FIT()`函数中，第一个参数(`10`)请求10个预测的field value。每个预测的`point`相距`379m`，与`GROUP BY time()`子句中的第一个参数相同。`HOLT_WINTERS_WITH_FIT()`函数中的第二个参数(`4`)是我们在上一步骤中确定的季节性模式。

  #### `HOLT_WINTERS()`的常见问题

  - #### `HOLT_WINTERS()`和收到的`point`少于”N”个

  在某些情况下，用户可能会收到比参数`N`请求的更少的预测`point`。当数学计算不稳定和不能预测更多`point`时，这种情况就会发生。这意味着该数据集不适合使用`HOLT_WINTERS()`，或者，季节性调整参数是无效的并且是算法混乱。

### 分析函数

下面技术分析的函数将广泛使用的算法应用在您的数据中。虽然这些函数主要应用在金融和投资领域，但是它们也适用于其它行业和用例。

[CHANDE_MOMENTUM_OSCILLATOR()](#chande_momentum_oscillator)

[EXPONENTIAL_MOVING_AVERAGE()](#exponential_moving_average)

[DOUBLE_EXPONENTIAL_MOVING_AVERAGE()](#double_exponential_moving_average)

[KAUFMANS_EFFICIENCY_RATIO()](#kaufmans_efficiency_ratio)

[KAUFMANS_ADAPTIVE_MOVING_AVERAGE()](#kaufmans_adaptive_moving_average)

[TRIPLE_EXPONENTIAL_MOVING_AVERAGE()](#triple_exponential_moving_average)

[TRIPLE_EXPONENTIAL_DERIVATIVE()](#triple_exponential_derivative)

[RELATIVE_STRENGTH_INDEX()](#relative_strength_index)

- ### 参数

  除了field key，技术分析函数还接受以下参数：

  `PERIOD`

  **必需，整数，min=1**

  算法的样本大小。这基本上是对算法的输出有显著影响的历史样本的数量。例如，`2`表示当前的`point`和前一个`point`。算法使用指数衰减率来决定历史`point`的权重，通常称为`alpha(α)`。参数`PERIOD`控制衰减率。

  > 请注意，历史`point`仍然可以产生影响。

  #### HOLD_PERIOD

  **整数，min=-1**

  算法需要多少个样本才会开始发送结果。默认值`-1`表示该参数的值基于算法、`PERIOD`和`WARMUP_TYPE`，但是这是一个可以使算法发送有意义的结果的值。

  **默认的Hold Periods：**

  对于大多数提供的技术分析，`HOLD_PERIOD`的默认值由您使用的技术分析算法和`WARMUP_TYPE`决定。

| 算法 \ Warmup Type                                           | simple                 | exponential |                 none                 |
| ------------------------------------------------------------ | ---------------------- | ----------- | :----------------------------------: |
| [EXPONENTIAL_MOVING_AVERAGE](#exponential_moving_average)    | PERIOD - 1             | PERIOD - 1  | <span style="opacity:.35">n/a</span> |
| [DOUBLE_EXPONENTIAL_MOVING_AVERAGE](#double_exponential_moving_average) | ( PERIOD - 1 ) * 2     | PERIOD - 1  | <span style="opacity:.35">n/a</span> |
| [TRIPLE_EXPONENTIAL_MOVING_AVERAGE](#triple_exponential_moving_average) | ( PERIOD - 1 ) * 3     | PERIOD - 1  | <span style="opacity:.35">n/a</span> |
| [TRIPLE_EXPONENTIAL_DERIVATIVE](#triple_exponential_derivative) | ( PERIOD - 1 ) * 3 + 1 | PERIOD      | <span style="opacity:.35">n/a</span> |
| [RELATIVE_STRENGTH_INDEX](#relative_strength_index)          | PERIOD                 | PERIOD      | <span style="opacity:.35">n/a</span> |
| [CHANDE_MOMENTUM_OSCILLATOR](#chande_momentum_oscillator)    | PERIOD                 | PERIOD      |              PERIOD - 1              |

_**Kaufman算法默认的Hold Periods：**_

| 算法                                                         | 默认的Hold Period |
| ------------------------------------------------------------ | ----------------- |
| [KAUFMANS_EFFICIENCY_RATIO()](#kaufmans_efficiency_ratio)    | PERIOD            |
| [KAUFMANS_ADAPTIVE_MOVING_AVERAGE()](#kaufmans_adaptive_moving_average) | PERIOD            |

#### WARMUP_TYPE

**默认=”exponential”**

这个参数控制算法如何为第一个`PERIOD`样本初始化自身，它本质上是具有不完整样本集的持续时间。

`simple`
第一个`PERIOD`样本的简单移动平均值(simple moving average，SMA)。这是[ta-lib](https://www.ta-lib.org/?spm=a2c4g.11186623.2.106.41fc3ee27HC1R6)使用的方法。

`exponential`
具有缩放alpha(α)的指数移动平均值(exponential moving average，EMA)。基本上是这样使用EMA：`PERIOD=1`用于第一个点，`PERIOD=2`用于第二个点，以此类推，直至算法已经消耗了`PERIOD`个`point`。由于算法一开始就使用了EMA，当使用此方法并且没有指定`HOLD_PERIOD`的值或`HOLD_PERIOD`的值为`-1`时，算法可能会在比`simple`小得多的样本大小的情况下开始发送`point`。

`none`
算法不执行任何的平滑操作。这是[ta-lib](https://www.ta-lib.org/?spm=a2c4g.11186623.2.107.41fc3ee27HC1R6)使用的方法。当使用此方法并且没有指定`HOLD_PERIOD`时，`HOLD_PERIOD`的默认值是`PERIOD - 1`。

> 类型`none`仅适用于`CHANDE_MOMENTUM_OSCILLATOR()`函数。

- ### CHANDE_MOMENTUM_OSCILLATOR()

  Chande Momentum Oscillator (CMO)是由Tushar Chande开发的一个技术动量指标。通过计算所有最近较高`point`的总和与所有最近较低`point`的总和的差值，然后将结果除以给定时间范围内的所有数据变动的总和来创建CMO指标。将结果乘以100可以得到一个从-100到+100的范围。
  <sup style="line-height:0; font-size:.7rem; font-style:italic; font-weight:normal;"><a href="https://www.fidelity.com/learning-center/trading-investing/technical-analysis/technical-indicator-guide/cmo" target="\_blank">Source</a>

  #### 基本语法

  ```
  CHANDE_MOMENTUM_OSCILLATOR([ * | <field_key> | /regular_expression/ ], <period>[, <hold_period>, [warmup_type]])
  ```

  **可用的参数：**

  [period](#period)
  [hold_period](#warmup-type) （可选项）
  [warmup_type](#warmup_type) （可选项）

  `CHANDE_MOMENTUM_OSCILLATOR(field_key, 2)`返回使用CMO算法处理field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

  `CHANDE_MOMENTUM_OSCILLATOR(field_key, 10, 9, 'none')`返回使用CMO算法处理field key对应的field value后的结果，该算法中，period设为10，hold period设为9，warmup type设为`none`。

  `CHANDE_MOMENTUM_OSCILLATOR(MEAN(<field_key>), 2) ... GROUP BY time(1d)`返回使用CMO算法处理field key对应的field value平均值后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

  > **注意：**当使用`GROUP BY`子句将数据进行聚合时，您必须在`CHANDE_MOMENTUM_OSCILLATOR()`函数中调用聚合函数。

  `CHANDE_MOMENTUM_OSCILLATOR(/regular_expression/, 2)`返回使用CMO算法处理与正则表达式匹配的每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

  `CHANDE_MOMENTUM_OSCILLATOR(*, 2)`返回使用CMO算法处理measurement中每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

  `CHANDE_MOMENTUM_OSCILLATOR()` 支持数据类型为int64和float64的field value。

- ### EXPONENTIAL_MOVING_AVERAGE()

  指数移动平均值 (Exponential Moving Average，EMA)类似于简单移动平均值，不同的是，指数移动平均值对最新数据给予更多的权重，它也被称为”指数加权移动平均值”。与简单移动平均值相比，这种类型的移动平均值对最近数据的变化反应更快。

  <sup style="line-height:0; font-size:.7rem; font-style:italic; font-weight:normal;"><a href="https://www.investopedia.com/terms/e/ema.asp" target="\_blank">Source</a>

  #### 基本语法

  ```
  EXPONENTIAL_MOVING_AVERAGE([ * | <field_key> | /regular_expression/ ], <period>[, <hold_period)[, <warmup_type]])
  ```

  **可用参数:**

  [period](#period)
  [hold_period](#warmup_type) （可选项）
  [warmup_type](#warmup_type) （可选项）

  `EXPONENTIAL_MOVING_AVERAGE(field_key, 2)`返回使用EMA算法处理field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

  `EXPONENTIAL_MOVING_AVERAGE(field_key, 10, 9, 'exponential')`返回使用EMA算法处理field key对应的field value后的结果，该算法中，period设为10，hold period设为9，warmup type设为`exponential`。

  `EXPONENTIAL_MOVING_AVERAGE(MEAN(<field_key>), 2) ... GROUP BY time(1d)`返回使用EMA算法处理field key对应的field value平均值后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

  > **注意：**当使用`GROUP BY`子句将数据进行聚合时，您必须在`EXPONENTIAL_MOVING_AVERAGE()`函数中调用聚合函数。

  `EXPONENTIAL_MOVING_AVERAGE(/regular_expression/, 2)`返回使用EMA算法处理与正则表达式匹配的每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

  `EXPONENTIAL_MOVING_AVERAGE(*, 2)`返回使用EMA算法处理measurement中每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

  `EXPONENTIAL_MOVING_AVERAGE()` 支持数据类型为int64和float64的field value。

- ### DOUBLE_EXPONENTIAL_MOVING_AVERAGE()

  双重指数移动平均值 (Double Exponential Moving Average，DEMA)通过增加最近数据的权重，尝试消除与移动平均值相关的固有滞后。该名字似乎表明这是通过双重指数平滑来实现的，然而事实并非如此，它表示的是将EMA的值翻倍。为了使它与实际数据保持一致，也为了消除滞后，从之前两倍EMA的值中把”EMA of EMA”的值减去，公式为：DEMA = 2 * EMA - EMA(EMA)。

  <sup style="line-height:0; font-size:.7rem; font-style:italic; font-weight:normal;"><a href="https://en.wikipedia.org/wiki/Double_exponential_moving_average" target="\_blank">Source</a>

  #### 基本语法

  ```
  DOUBLE_EXPONENTIAL_MOVING_AVERAGE([ * | <field_key> | /regular_expression/ ], <period>[, <hold_period)[, <warmup_type]])
  ```

  **可用的参数：**

  [period](#period)
  [hold_period](#warmup_type) （可选项）
  [warmup_type](#warmup_type) （可选项）

  `DOUBLE_EXPONENTIAL_MOVING_AVERAGE(field_key, 2)`返回使用DEMA算法处理field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

  `DOUBLE_EXPONENTIAL_MOVING_AVERAGE(field_key, 10, 9, 'exponential')`返回使用DEMA算法处理field key对应的field value后的结果，该算法中，period设为10，hold period设为9，warmup type设为`exponential`。

  `DOUBLE_EXPONENTIAL_MOVING_AVERAGE(MEAN(<field_key>), 2) ... GROUP BY time(1d)`返回使用DEMA算法处理field key对应的field value平均值后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

  > **注意：**当使用`GROUP BY`子句将数据进行聚合时，您必须在`DOUBLE_EXPONENTIAL_MOVING_AVERAGE()`函数中调用聚合函数。

  `DOUBLE_EXPONENTIAL_MOVING_AVERAGE(/regular_expression/, 2)`返回使用DEMA算法处理与正则表达式匹配的每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

  `DOUBLE_EXPONENTIAL_MOVING_AVERAGE(*, 2)`返回使用DEMA算法处理measurement中每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

  `DOUBLE_EXPONENTIAL_MOVING_AVERAGE()`支持数据类型为int64和float64的field value。

- ### KAUFMANS_EFFICIENCY_RATIO()

  Kaufman效率比 (Kaufman’s Efficiency Ration)，或简称为效率比 (Efficiency Ratio，ER)，它的计算方法是：将一段时间内的数据变化除以实现该变化所发生的数据变动的绝对值的总和。得出的比率在0和1之间，比率越高，表示市场越有效率或越有趋势。



ER跟Chande Momentum Oscillator (CMO)非常类似。不同的是，CMO将市场方向考虑在内，但是如果您将CMO的绝对值除以100，就可以得到ER。

<sup style="line-height:0; font-size:.7rem; font-style:italic; font-weight:normal;"><a href="http://etfhq.com/blog/2011/02/07/kaufmans-efficiency-ratio/" target="\_blank">Source</a>

#### 基本语法

  ```sql
  KAUFMANS_EFFICIENCY_RATIO([ * | <field_key> | /regular_expression/ ], <period>[, <hold_period>])
  ```

**可用的参数：**

[period](#period)
[hold_period](#warmup_type) （可选项）

`KAUFMANS_EFFICIENCY_RATIO(field_key, 2)`返回使用效率指数(Efficiency Index)算法处理field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period。

`KAUFMANS_EFFICIENCY_RATIO(field_key, 10, 10)`返回使用效率指数算法处理field key对应的field value后的结果，该算法中，period设为10，hold period设为10。

`KAUFMANS_EFFICIENCY_RATIO(MEAN(<field_key>), 2) ... GROUP BY time(1d)`返回使用效率指数算法处理field key对应的field value平均值后的结果，该算法中，period设为2，使用默认的hold period。

> **注意：**当使用`GROUP BY`子句将数据进行聚合时，您必须在`KAUFMANS_EFFICIENCY_RATIO()`函数中调用聚合函数。

`KAUFMANS_EFFICIENCY_RATIO(/regular_expression/, 2)`返回使用效率指数算法处理与正则表达式匹配的每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period。

`KAUFMANS_EFFICIENCY_RATIO(*, 2)`返回使用效率指数算法处理measurement中每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period。

`KAUFMANS_EFFICIENCY_RATIO()`支持数据类型为int64和float64的field value。

- ### KAUFMANS_ADAPTIVE_MOVING_AVERAGE()

  Kaufman自适应移动平均值 (Kaufman’s Adaptive Moving Average，KAMA)，是一个用于计算样本噪音或波动率的移动平均值。当数据波动相对较小并且噪音较低时，KAMA会密切关注`point`。当数据波动较大时，KAMA会进行调整，平滑噪音。该趋势跟踪指标可用于识别总体趋势、时间转折点和过滤价格变动。

  <sup style="line-height:0; font-size:.7rem; font-style:italic; font-weight:normal;"><a href="http://stockcharts.com/school/doku.php?id=chart_school:technical_indicators:kaufman_s_adaptive_moving_average" target="\_blank">Source</a>

  #### 基本语法

  ```
  KAUFMANS_ADAPTIVE_MOVING_AVERAGE([ * | <field_key> | /regular_expression/ ], <period>[, <hold_period>])
  ```

  **可用的参数：**
  [period](#period)
  [hold_period](#warmup_type) （可选项）

  `KAUFMANS_ADAPTIVE_MOVING_AVERAGE(field_key, 2)`返回使用KAMA算法处理field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period。

  `KAUFMANS_ADAPTIVE_MOVING_AVERAGE(field_key, 10, 10)`返回使用KAMA算法处理field key对应的field value后的结果，该算法中，period设为10，hold period设为10。

  `KAUFMANS_ADAPTIVE_MOVING_AVERAGE(MEAN(<field_key>), 2) ... GROUP BY time(1d)`返回使用KAMA算法处理field key对应的field value平均值后的结果，该算法中，period设为2，使用默认的hold period。

  > **注意：**当使用`GROUP BY`子句将数据进行聚合时，您必须在`KAUFMANS_ADAPTIVE_MOVING_AVERAGE()`函数中调用聚合函数。

  `KAUFMANS_ADAPTIVE_MOVING_AVERAGE(/regular_expression/, 2)`返回使用KAMA算法处理与正则表达式匹配的每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period。

  `KAUFMANS_ADAPTIVE_MOVING_AVERAGE(*, 2)`返回使用KAMA算法处理measurement中每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period。

  `KAUFMANS_ADAPTIVE_MOVING_AVERAGE()`支持数据类型为int64和float64的field value。

- ### TRIPLE_EXPONENTIAL_MOVING_AVERAGE()

  三重指数移动平均值 (Triple Exponential Moving Average，TEMA)，旨在过滤常规移动平均值的波动。该名字似乎表明这是通过三重指数平滑来实现的，然而事实并非如此，它实际上是包含指数移动平均值、双重指数移动平均值和三重指数移动平均值的复合函数。

  <sup style="line-height:0; font-size:.7rem; font-style:italic; font-weight:normal;"><a href="https://www.investopedia.com/terms/t/triple-exponential-moving-average.asp " target="\_blank">Source</a>

  #### 基本语法

  ```
  TRIPLE_EXPONENTIAL_MOVING_AVERAGE([ * | <field_key> | /regular_expression/ ], <period>[, <hold_period)[, <warmup_type]])
  ```

  **Available Arguments:**

  [period](#period)
  [hold_period](#warmup_type) （可选项）
  [warmup_type](#warmup_type) （可选项）

  `TRIPLE_EXPONENTIAL_MOVING_AVERAGE(field_key, 2)`返回使用TEMA算法处理field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

  `TRIPLE_EXPONENTIAL_MOVING_AVERAGE(field_key, 10, 9, 'exponential')`返回使用TEMA算法处理field key对应的field value后的结果，该算法中，period设为10，hold period设为9，warmup type设为`exponential`。

  `TRIPLE_EXPONENTIAL_MOVING_AVERAGE(MEAN(<field_key>), 2) ... GROUP BY time(1d)`返回使用TEMA算法处理field key对应的field value平均值后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

  > **注意：**当使用`GROUP BY`子句将数据进行聚合时，您必须在`TRIPLE_EXPONENTIAL_MOVING_AVERAGE()`函数中调用聚合函数。

  `TRIPLE_EXPONENTIAL_MOVING_AVERAGE(/regular_expression/, 2)`返回使用TEMA算法处理与正则表达式匹配的每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

  `TRIPLE_EXPONENTIAL_MOVING_AVERAGE(*, 2)`返回使用TEMA算法处理measurement中每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

  `TRIPLE_EXPONENTIAL_MOVING_AVERAGE()`支持数据类型为int64和float64的field value。

- ### TRIPLE_EXPONENTIAL_DERIVATIVE()

  三重指数导数指标 (Triple Exponential Derivative Indicator)，通常称为”TRIX”，是一种用于识别超卖和超买市场的振荡器，也可用作动量指标。TRIX计算一段时间内输入数据的对数的三重指数移动平均值。从当前的值中减去之前的值，这可以防止指标考虑比规定期间短的周期。



跟很多振荡器一样，TRIX围绕着零线震荡。当它用作振荡器时，正数表示炒买超买市场，而负数表示超卖市场。当它用作动量指标时，正数表示动量在增加，而负数表示动量在减少。很多分析师认为，当TRIX超过零线时，它会给出买入信号，当低于零线时，它会给出卖出信号。

<sup style="line-height:0; font-size:.7rem; font-style:italic; font-weight:normal;"><a href="https://www.investopedia.com/articles/technical/02/092402.asp " target="\_blank">Source</a>

#### 基本语法

  ```
  TRIPLE_EXPONENTIAL_DERIVATIVE([ * | <field_key> | /regular_expression/ ], <period>[, <hold_period)[, <warmup_type]])
  ```

**可用的参数：**

[period](#period)
[hold_period](#warmup_type) （可选项）
[warmup_type](#warmup_type) （可选项）

`TRIPLE_EXPONENTIAL_DERIVATIVE(field_key, 2)`返回使用三重指数导数算法处理field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

`TRIPLE_EXPONENTIAL_DERIVATIVE(field_key, 10, 10, 'exponential')`返回使用三重指数导数算法处理field key对应的field value后的结果，该算法中，period设为10，hold period设为10，warmup type设为`exponential`。

`TRIPLE_EXPONENTIAL_DERIVATIVE(MEAN(<field_key>), 2) ... GROUP BY time(1d)`返回使用三重指数导数算法处理field key对应的field value平均值后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

> **注意：**当使用`GROUP BY`子句将数据进行聚合时，您必须在`TRIPLE_EXPONENTIAL_DERIVATIVE()`函数中调用聚合函数。

`TRIPLE_EXPONENTIAL_DERIVATIVE(/regular_expression/, 2)`返回使用三重指数导数算法处理与正则表达式匹配的每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

`TRIPLE_EXPONENTIAL_DERIVATIVE(*, 2)`返回使用三重指数导数算法处理measurement中每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

`TRIPLE_EXPONENTIAL_DERIVATIVE()`支持数据类型为int64和float64的field value。

- ### RELATIVE_STRENGTH_INDEX()

  相对强弱指数 (Relative Strength Index，RSI)是一个动量指标，用于比较在指定时间段内最近数据增大和减小的幅度，以便measurement数据变动的速度和变化。

  <sup style="line-height:0; font-size:.7rem; font-style:italic; font-weight:normal;"><a href="https://www.investopedia.com/terms/r/rsi.asp" target="\_blank">Source</a>

  #### 基本语法

  ```
  RELATIVE_STRENGTH_INDEX([ * | <field_key> | /regular_expression/ ], <period>[, <hold_period)[, <warmup_type]])
  ```

  **Available Arguments:**

  [period](#period)
  [hold_period](#warmup_type) （可选项）
  [warmup_type](#warmup_type) （可选项）

  `RELATIVE_STRENGTH_INDEX(field_key, 2)`返回使用RSI算法处理field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

  `RELATIVE_STRENGTH_INDEX(field_key, 10, 10, 'exponential')`返回使用RSI算法处理field key对应的field value后的结果，该算法中，period设为10，hold period设为10，warmup type设为`exponential`。

  `RELATIVE_STRENGTH_INDEX(MEAN(<field_key>), 2) ... GROUP BY time(1d)`返回使用RSI算法处理field key对应的field value平均值后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

  > **注意：**当使用`GROUP BY`子句将数据进行聚合时，您必须在`RELATIVE_STRENGTH_INDEX()`函数中调用聚合函数。

  `RELATIVE_STRENGTH_INDEX(/regular_expression/, 2)`返回使用RSI算法处理与正则表达式匹配的每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

  `RELATIVE_STRENGTH_INDEX(*, 2)`返回使用RSI算法处理measurement中每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

  `RELATIVE_STRENGTH_INDEX()`支持数据类型为int64和float64的field value。

- ### 其它

  #### 示例数据

  本文档使用的数据可在[示例数据](oceanic_station.txt)中下载。

  #### 函数的通用语法

  - #### 在`SELECT`中指定多个函数

  ```
  SELECT <function>(),<function>() FROM_clause [...]
  ```

  使用逗号(`,`)将`SELECT`语句中的多个函数分开。该语法适用于除`TOP()`和`BOTTOM()`之外的所有cnosQL函数。`SELECT`子句不支持`TOP()`或`BOTTOM()`和其它函数同时使用。

  ####示例

  - #### 在一个查询中计算field value的平均值和平均数

  ```sql
  > SELECT MEAN("temperature"),MEDIAN("temperature") FROM "air"
  name: air
  time                 mean              median
  ----                 ----              ------
  1970-01-01T00:00:00Z 64.94933267424616 65
  ```

  该查询返回`temperature`的平均值和平均数。

  - #### 在一个查询中计算两个field的mode

  ```sql
  > SELECT MODE("temperature"),MODE("pressure") FROM "air"
  name: air
  time                 mode mode_1
  ----                 ---- ------
  1970-01-01T00:00:00Z 53
  ```

  该查询返回`temperature`中出现频率最高的field value和`pressure`中出现频率最高的field value。`temperature`对应的值在列`mode`中，`pressure`对应的值在列`mode_1`中。因为系统不能返回多个具有相同名字的列，所以它将第二个列`mode`重命名为`mode_1`。

  - #### 在一个查询中计算field value的最小值和最大值

  ```sql
  > SELECT MIN("temperature"), MAX("temperature") FROM "air"
  name: air
  time                 min max
  ----                 --- ---
  1970-01-01T00:00:00Z 50  80
  ```

  该查询返回`temperature`的最小值和最大值。

  请注意，该查询返回`1970-01-01T00:00:00Z`作为时间戳，这是CnosDB的空时间戳。`MIN()`和`MAX()`是selector函数；当selector函数是`SELECT`子句中的唯一函数时，它返回一个特定的时间戳。因为`MIN()`和`MAX()`返回两个不同的时间戳（见下面的例子），所以系统会用空时间戳覆盖这些时间戳。

  ```sql
  >  SELECT MIN("temperature") FROM "air"
  name: air
  time                  min
  ----                  ---
  2021-08-31T16:18:00Z  50    <--- Timestamp 1
  
  >  SELECT MAX("temperature") FROM "air"
  name: air
  time                  max
  ----                  ---
  2021-08-31T18:03:00Z  80    <--- Timestamp 2
  ```

  #### 重命名查询结果字段

  - #### 语法

  ```
  SELECT <function>() AS <field_key> [...]
  ```

  默认情况下，函数返回的结果在与函数名称匹配的field key下面。使用`AS`子句可以指定输出的field key的名字。

  ####示例

  - #### 指定输出的field key

  ```sql
  > SELECT MEAN("temperature") AS "dream_name" FROM "air"
  name: air
  time                  dream_name
  ----                  ----------
  1970-01-01T00:00:00Z 64.94933267424616
  ```

  该查询返回`temperature`的平均值，并将输出的field key重命名为`dream_name`。如果没有`AS`子句，那么查询会返回`mean`作为输出的field key：

  ```sql
  > SELECT MEAN("temperature") FROM "air"
  name: air
  time                  mean
  ----                  ----
  1970-01-01T00:00:00Z 64.94933267424616
  ```

  - #### 为多个函数指定输出的field key

  ```sql
  > SELECT MEDIAN("temperature") AS "med_wat",MODE("temperature") AS "mode_wat" FROM "air"
  name: air
  time                 med_wat mode_wat
  ----                 ------- --------
  1970-01-01T00:00:00Z 65      53
  ```

  该查询返回`temperature`的平均数和`temperature`中出现频率最高的field value，并将输出的field key分别重命名为`med_wat`和`mode_wat`。如果没有`AS`子句，那么查询会返回`median`和`mode`作为输出的field key：

  ```sql
  > SELECT MEDIAN("temperature"),MODE("temperature") FROM "air"
  name: air
  time                 median mode
  ----                 ------ ----
  1970-01-01T00:00:00Z 65     53
  ```

  #### 改变不含数据的时间间隔的返回值

  默认情况下，包含cnosQL函数和`GROUP BY time()`子句的查询对不包含数据的时间间隔返回空值。在`GROUP BY`子句后面加上`fill()`可以更改这个值。关于`fill()`的详细讨论，请查看数据探索。

  #### 函数的常见问题

  以下部分描述了所有函数、聚合函数和选择函数的常见混淆来源，有关单个功能的常见问题，请参见以下特定文档：

  * [DISTINCT()](#common-issues-with-distinct)
  * [BOTTOM()](#common-issues-with-bottom)
  * [PERCENTILE()](#common-issues-with-percentile)
  * [SAMPLE()](#common-issues-with-sample)
  * [TOP()](#common-issues-with-top)
  * [ELAPSED()](#common-issues-with-elapsed)
  * [HOLT_WINTERS()](#common-issues-with-holt-winters)

  #### 所有函数

  - #### 嵌套函数


某些cnosQL 函数支持 [`SELECT` clause](/cnosdb/v1.8/query_language/explore-data/#select-clause)中嵌套:
* [`COUNT()`](#count) with [`DISTINCT()`](#distinct)
* [`CUMULATIVE_SUM()`](#cumulative-sum)
* [`DERIVATIVE()`](#derivative)
* [`DIFFERENCE()`](#difference)
* [`ELAPSED()`](#elapsed)
* [`MOVING_AVERAGE()`](#moving-average)
* [`NON_NEGATIVE_DERIVATIVE()`](#non-negative-derivative)
* [`HOLT_WINTERS()`](#holt-winters) and [`HOLT_WINTERS_WITH_FIT()`](#holt-winters)

- #### 查询在now()之后的时间范围

大多数`SELECT`语句的默认时间范围在`1677-09-21 00:12:43.145224194` UTC和`2262-04-11T23:47:16.854775806Z` UTC之间。对于包含cnosQL函数和`GROUP BY time()`子句的`SELECT`查询，默认的时间范围在`1677-09-21 00:12:43.145224194`和`now()`之间。

如果要查询时间戳发生在`now()`之后的数据，那么包含cnosQL函数和`GROUP BY time()`子句的`SELECT`查询必须在`WHERE`子句中提供一个时间上限。请查看常见问题。

#### 聚合函数

- #### 理解返回的时间戳

子句中具有 [聚合函数](#aggregations) 且 `WHERE`没有时间范围的查询讲返回 epoch 0 (`1970-01-01T00:00:00Z`) 作为时间戳.
CnosDB 使用 epoch 0 作为等效的空时间戳.
带有聚合函数的查询，如果 `WHERE` 子句中包含时间范围，将返回时间下限作为时间戳.

####示例

- #### 使用聚合函数并且没有指定时间范围

  ```sql
  > SELECT SUM("temperature") FROM "air"
  name: air
  time                 sum
  ----                 ---
  1970-01-01T00:00:00Z 1839495
  ```

该查询将CnosDB的空时间戳(epoch 0: `1970-01-01T00:00:00Z`)作为时间戳返回。`SUM()`将多个`point`聚合，没有单个时间戳可以返回。

- #### 使用聚合函数并且指定时间范围

  ```sql
  > SELECT SUM("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z'
  name: air
  time                 sum
  ----                 ---
  2021-09-28T00:00:00Z 134766
  ```

该查询将时间范围的下界(`WHERE time >= '2021-09-18T00:00:00Z'`)作为时间戳返回。

- #### 使用聚合函数并且指定时间范围和使用GROUP BY time()子句

  ```sql
  > SELECT SUM("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-28T00:28:00Z' GROUP BY time(12m)
  name: air
  time                 sum
  ----                 ---
  2021-09-28T00:00:00Z 490
  2021-09-28T00:12:00Z 524
  2021-09-28T00:24:00Z 263
  ```

该查询将每个`GROUP BY time()`间隔的时间下界作为时间戳返回。

- #### 将聚合函数和不聚合的数据混合使用

聚合函数不支持在`SELECT`语句中指定不使用聚合函数的单独的field key或tag key。聚合函数返回一个计算结果，对于没有被聚合的field或tag，没有明显的单个值可以返回。当`SELECT`语句同时包含聚合函数和单独的field key或tag key时，会返回错误：

  ```sql
  > SELECT SUM("temperature"),"station" FROM "air"
  ERR: mixing aggregate and non-aggregate queries is not supported
  ```

- #### 得到略有不同的结果

对于某些聚合函数，在相同的`point`（数据类型为float64)上执行相同的函数，可能会产生稍微不同的结果。在应用聚合函数之间，CnosDB不会将`point`进行排序；该行为可能会导致查询结果中出现小小的差异。

#### Selector函数

- #### 理解返回的时间戳

selector函数返回的时间戳依赖查询中函数的数量和查询中的其它子句：

带有单个选择器函数，单个 field key 参数和无 `GROUP BY time()` 的查询返回原始数据中出现的point时间戳.
具有单个 selector 函数, 多个 `field key` 参数的查询, `GROUP BY time()` 返回原始数据中出现的point 时间戳，或与空时间戳 (epoch 0: `1970-01-01T00:00:00Z`)等价的CnosDB.

`WHERE`子句中有多个函数且没有时间范围的查询将返回相当于空时间戳 (epoch 0: `1970-01-01T00:00:00Z`).
在 `WHERE`子句中包含多个函数和时间范围的查询将时间下限作为时间戳返回

带有 selector 函数和  `GROUP BY time()` 子句的查询返回每个 `GROUP BY time()`间隔的时间下限.

####示例

- #### 使用单个selector函数和单个field key，并且没有指定时间范围

  ```sql
  > SELECT MAX("temperature") FROM "air"
  name: air
  time                  max
  ----                  ---
  2020-08-29T07:24:00Z  9.964
  
  > SELECT MAX("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z'
  name: air
  time                 max
  ----                 ---
  2021-09-28T01:57:00Z 80
  ```

该查询返回原始数据中具有`最大`值的`point`的时间戳。

- #### 使用单个selector函数和多个field key，并且没有指定时间范围

  ```sql
  > SELECT FIRST(*) FROM "air"
  name: air
  time                 first_pressure first_temperature first_visibility
  ----                 -------------- ----------------- ----------------
  1970-01-01T00:00:00Z 78             79                71
  
  > SELECT MAX(*) FROM "air"
  name: air
  time                 max_pressure max_temperature max_visibility
  ----                 ------------ --------------- --------------
  1970-01-01T00:00:00Z 80           80              80

  ```

第一个查询返回CnosDB的空时间戳(epoch 0: `1970-01-01T00:00:00Z`)作为查询结果中的时间戳。因为`FIRST(*)`返回两个时间戳（对应measurement `air`中的每个field key），所以系统使用空时间戳覆盖这两个时间戳。

第二个查询返回原始数据中具有最大值的`point`的时间戳。因为`MAX(*)`只返回一个时间戳(measurement `air`中只有一个数值类型的field)，所以系统不会覆盖原始时间戳。

- #### 使用多个selector函数，并且没有指定时间范围

  ```sql
  > SELECT MAX("temperature"),MIN("temperature") FROM "air"
  name: air
  time                 max min
  ----                 --- ---
  1970-01-01T00:00:00Z 80  50 
  ```

该查询返回CnosDB的空时间戳(epoch 0: `1970-01-01T00:00:00Z`)作为查询结果中的时间戳。因为`MAX()`和`MIN()`函数返回不同的时间戳，所以系统没有单个时间戳可以返回。

- #### 使用多个selector函数，并且指定时间范围

  ```sql
  > SELECT MAX("temperature"),MIN("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z'
    name: air
    time                 max min
    ----                 --- ---
    2021-09-28T00:00:00Z 80  50
  ```

该查询返回时间范围的下界(`WHERE time >= '2021-09-18T00:00:00Z'`)作为查询结果中的时间戳。

- #### 使用单个selector函数，并且指定时间范围

  ```sql
  > SELECT MAX("temperature") FROM "air" WHERE time >= '2021-09-18T00:00:00Z' AND time <= '2021-09-18T00:18:00Z' GROUP BY time(12m)
  name: air
  time                 max
  ----                 ---
  2021-09-18T00:00:00Z 80
  2021-09-18T00:12:00Z 797
  ```

该查询返回每个`GROUP BY time()`间隔的时间下限作为查询结果中的时间戳。