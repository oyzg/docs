# CnosQL 数据查询

CnosDB查询语法类似于SQL，使用SELECT语句从特定的measurement中查询数据，但又不完全一样；当前所有支持查询结构如下。

## 语法结构

```sql

SELECT <field_key>[,
         <field_key>,
         <tag_key>,
         <function>(<field_key>)
FROM <measurement_name>[,<measurement_name>]
WHERE <conditional_expression> [(AND|OR) <conditional_expression> [<time_range>...]]
GROUP BY  [* | <tag_key>[,<tag_key],time(<time_interval>,<offset_interval>)]
ORDER BY  time DESC LIMIT N1 OFFSET N2 SLIMIT N3 SOFFSET N4
```

## 元素说明

| 元素 | 说明 | 
| -------------- | ------------ | 
|SELECT |SELECT查询语句|
|field_key         | field key| 
|tag_key            |tag key|  
|FROM   |查询数据来源，指明来自哪个measurement |
|conditional_expression |查询条件，查询结果中只会包含满足条件数据|
|function     |内置函数，详细用法可以参考函数一节|
|WHERE |WHERE条件查询字句，查询结果只包含满足条件数据|
|time_range |时间范围|
|time_interval|时间间隔粒度|
|GROUP_BY |GROUP BY子句，用于分组查询|
|ORDER_BY |ORDER BY 子句，用于对返回结果数据进行排序|
|LIMIT N|从指定的measurement中返回前N个数据点|
|SLIMIT N|返回指定measurement的前个series中的每一个点|
|OFFSET N|从查询结果中返回分页的N个数据点|
|SOFFSET N|从查询结果中返回分页的N个series|


### 例1：基本的SELECT查询用法

select查询的基本用法

```sql
> select * from air
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
......

```

该查询从air这个measurement中查询所有tag、 field并返回

#### 其他用法及其注意事项

* *::field用于标识所有field字段：select *::field from air limit 10
* 可以显示指定字段名称：select temperature,station from air limit 10
* 可以进行基本运算：select visibility*100 from air limit 10
* 查询字段名不可以只含tag，否则无数据返回

### 例2：WHERE条件查询

WHERE条件用于对返回数据进行过滤，只返回满足条件的数据

```sql

> select * from air where visibility > 70
name: air
time                 pressure station     temperature visibility
----                 -------- -------     ----------- ----------
2021-08-31T16:00:00Z 78       LianYunGang 63          71
2021-08-31T16:06:00Z 58       XiaoMaiDao  77          79
2021-08-31T16:06:00Z 60       LianYunGang 52          75
2021-08-31T16:15:00Z 72       LianYunGang 71          80
2021-08-31T16:18:00Z 60       LianYunGang 52          76
2021-08-31T16:21:00Z 72       XiaoMaiDao  79          72
2021-08-31T16:24:00Z 59       LianYunGang 55          76
2021-08-31T16:27:00Z 78       LianYunGang 59          78
2021-08-31T16:30:00Z 53       XiaoMaiDao  57          74
2021-08-31T16:33:00Z 60       XiaoMaiDao  52          79
......

```

查询返回数据要求： visibility > 70

#### 其他用法及其注意事项

* 条件可以有多个用AND、OR拼接
* 运算符支持 =、>、 <、 >=、 <= 、!= 

### 例3: GROUP BY分组用法

GROUP BY用于数据分组查询

```sql

> select mean(temperature) from air  group by station
name: air
tags: station=LianYunGang
time                 mean
----                 ----
1970-01-01T00:00:00Z 64.97175340724525

name: air
tags: station=XiaoMaiDao
time                 mean
----                 ----
1970-01-01T00:00:00Z 64.92691194124708

```

上面查询根据station进行分组，求取temperature的平均值，用到了mean平均值函数。

#### 其他用法及其注意事项

* 分组字段可以根据多个字断进行，用逗号隔开
* 根据时间分组time(30m)：30分钟一个分组， time(1d)：1天一个分组

### 例4: INTO子句用法

INTO子句用于将查询的结果写入到一个measurement中

```sql

> select mean(temperature) into temp_result from air  group by station
name: result
time                 written
----                 -------
1970-01-01T00:00:00Z 2
> 
> select * from temp_result
name: temp_result
time                 mean              station
----                 ----              -------
1970-01-01T00:00:00Z 64.97175340724525 LianYunGang
1970-01-01T00:00:00Z 64.92691194124708 XiaoMaiDao

```

上面例子将分组以后查询结果写入一个名字为temp_result的新measurement中。

#### 其他用法及其注意事项

* 可以使用select into语法重命名measurement，移动数据到其他databases等。
* INTO子句也可以写入一个已经存在的measurement

### 例5: ORDER BY子句用法

ORDER BY用于对返回结果进行排序

```sql

> select * from air  order by time desc
name: air
time                 pressure station     temperature visibility
----                 -------- -------     ----------- ----------
2021-09-30T04:00:00Z 52       XiaoMaiDao  59          78
2021-09-30T04:00:00Z 65       LianYunGang 50          76
2021-09-30T03:57:00Z 65       XiaoMaiDao  76          75
2021-09-30T03:57:00Z 57       LianYunGang 70          58
2021-09-30T03:54:00Z 51       XiaoMaiDao  69          69
2021-09-30T03:54:00Z 53       LianYunGang 79          60
2021-09-30T03:51:00Z 59       XiaoMaiDao  55          69
2021-09-30T03:51:00Z 69       LianYunGang 73          69
2021-09-30T03:48:00Z 79       XiaoMaiDao  77          69
2021-09-30T03:48:00Z 50       LianYunGang 57          52
......

```

上面例子按照时间先新后旧排序返回数据

#### 其他用法及其注意事项

* 系统默认返回数据按照先旧后新，如若需要先新后旧可以使用：order by time desc
* 只支持按照时间字断排序，不支持按照其他字断排序

### 例6: LIMIT SLIMIT子句用法

限制返回的数据量

```sql

> select * from air group by * LIMIT 5 SLIMIT 1
name: air
tags: station=LianYunGang
time                 pressure temperature visibility
----                 -------- ----------- ----------
2021-08-31T16:00:00Z 78       63          71
2021-08-31T16:03:00Z 50       52          53
2021-08-31T16:06:00Z 60       52          75
2021-08-31T16:09:00Z 58       73          65
2021-08-31T16:12:00Z 50       73          69
> 
> select * from air group by * LIMIT 5 SLIMIT 2
name: air
tags: station=LianYunGang
time                 pressure temperature visibility
----                 -------- ----------- ----------
2021-08-31T16:00:00Z 78       63          71
2021-08-31T16:03:00Z 50       52          53
2021-08-31T16:06:00Z 60       52          75
2021-08-31T16:09:00Z 58       73          65
2021-08-31T16:12:00Z 50       73          69

name: air
tags: station=XiaoMaiDao
time                 pressure temperature visibility
----                 -------- ----------- ----------
2021-08-31T16:00:00Z 75       79          68
2021-08-31T16:03:00Z 73       70          55
2021-08-31T16:06:00Z 58       77          79
2021-08-31T16:09:00Z 63       54          70
2021-08-31T16:12:00Z 73       77          63

```

LIMIT、SLIMIT都是限制返回的数据数量，LIMIT用于控制返回的points的数量，SLIMIT用于控制返回的series数量

#### 其他用法及其注意事项

* LIMIT 与SLIMIT 既可以单独使用，也可以一起使用
* 一起使用时，表示的意思是查询指定measurement前N个series的前N个point
* LIMIT 与SLIMIT 一起使用时，sql中必须包含group by *

### 例7: OFFSET SOFFSET子句用法

OFFSET SOFFSET用于分页查询

```sql

> select * from air LIMIT 10
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
>
> select * from air LIMIT 3 offset 5
name: air
time                 pressure station     temperature visibility
----                 -------- -------     ----------- ----------
2021-08-31T16:06:00Z 58       XiaoMaiDao  77          79
2021-08-31T16:09:00Z 58       LianYunGang 73          65
2021-08-31T16:09:00Z 63       XiaoMaiDao  54          70
```

上面例子中LIMIT 3控制返回数据量位3条，OFFSET 5进行分页过滤掉前面5条

#### 其他用法及其注意事项

* SOFFSET N从查询结果中返回分页的N个series
* OFFSET用于对point分页，SOFFSET是对series分页
* 通常OFFSET与LIMIT配合使用，SOFFSET与SLIMIT配合使用
* 两者可以一起使用如：select * from air group by * LIMIT 3 OFFSET 5 SLIMIT 1 SOFFSET 1

### 例8: 正则表达式

正则表达式前后用斜杠/引起来，并且使用Golang正则表达式语法

```sql

> select /p/ from /ai/ where station =~ /Lian/
name: air
time                 pressure temperature
----                 -------- -----------
2021-08-31T16:00:00Z 78       63
2021-08-31T16:03:00Z 50       52
2021-08-31T16:06:00Z 60       52
2021-08-31T16:09:00Z 58       73
2021-08-31T16:12:00Z 50       73
2021-08-31T16:15:00Z 72       71
2021-08-31T16:18:00Z 60       52
2021-08-31T16:21:00Z 74       79
2021-08-31T16:24:00Z 59       55
2021-08-31T16:27:00Z 78       59
......

```

上面例子筛选出含有p字符的字段名字，measurement中含有ai字符串，station字段包含字段Lian

#### 其他用法及其注意事项

* 支持如下场景的正则表达式：SELECT中的field key和tag key、FROM中的measurement、WHERE中的tag value和字符串类型的field value、GROUP BY中的tag key
* =~ ：匹配、!~ ：不匹配

### 例9: 子查询

子查询是一种嵌套查询，使用子查询将查询结果作为条件应用于其他查询中

```sql

> select sum(mean) from ( select mean(temperature) from air group by station )
name: air
time                 sum
----                 ---
1970-01-01T00:00:00Z 129.89866534849233

#############################################################
> select mean(temperature) from air group by station
name: air
tags: station=LianYunGang
time                 mean
----                 ----
1970-01-01T00:00:00Z 64.97175340724525

name: air
tags: station=XiaoMaiDao
time                 mean
----                 ----
1970-01-01T00:00:00Z 64.92691194124708
> 

```

上面例子根据station分组求取temperature平均值，然后再求和。执行过程是先执行内层子语句，再执行外层语句。

#### 其他用法及其注意事项

* Cnosdb支持多层嵌套查询
* 每个子查询要用小括号()包裹起来