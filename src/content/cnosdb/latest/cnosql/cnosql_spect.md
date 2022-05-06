# CnosQL参考

## 介绍
CnosQL的定义和详细信息
- [符号](#符号)
- [查询表示](#查询表示)
- [字母和数字](#字母和数字)
- [标识符](#标识符)
- [关键字](#关键字)
- [文字](#文字)
- [查询](#查询)
- [语句](#语句)
- [条款](#条款)
- [表达式](#表达式)
- [其他](#其他)
### 符号

使用Extended Backus-Naur Form(" EBNF ")指定语法。EBNF与Go编程语言规范中使用的符号相同。并非巧合的是，CnosDB是用Go编写的。
```
Production  = production_name "=" [ Expression ] "." .
Expression  = Alternative { "|" Alternative } .
Alternative = Term { Term } .
Term        = production_name | token [ "…" token ] | Group | Option | Repetition .
Group       = "(" Expression ")" .
Option      = "[" Expression "]" .
Repetition  = "{" Expression "}" .
```
按优先级递增的顺序表示操作符:
```
|   alternation
()  grouping
[]  option (0 or 1 times)
{}  repetition (0 to n times)
```

### 查询表示

  - #### 字符
CnosQL是使用UTF-8编码的Unicode文本。
```
newline             = /* the Unicode code point U+000A */ .
unicode_char        = /* an arbitrary Unicode code point except newline */ .
```

### 字母和数字

字母是ASCII字符的集合，加上下划线_ (U+005F)也被认为是字母。只支持十进制数字。
```
letter              = ascii_letter | "_" .
ascii_letter        = "A" … "Z" | "a" … "z" .
digit               = "0" … "9" .
```

### 标识符
标识符包括数据库名、保留策略名、用户名、度量名、标记键以及字段键。

标识符使用规则如下；

  - 双引号标识符可以包含除新行以外的任何unicode字符。
  - 双引号标识符可以包括转义的`"`字符。例如；`\"` 。
  - 双引号标识符中可以包括CnosQL的关键字。
  - 未加引号的标识符必须以大写或小写ASCII字符或者"_"开头。
  - 未加引号的标识符只能包括ASCII字母、十进制数字或者"_"。
```
identifier          = unquoted_identifier | quoted_identifier .
unquoted_identifier = ( letter ) { letter | digit } .
quoted_identifier   = `"` unicode_char { unicode_char } `"` .
```

例如：
```
air
_air_temperature
"1h"
"anything really"
"1_Crazy-1337.identifier>NAME👍"
```

### 关键字
```
ALL           ALTER         ANY           AS            ASC           BEGIN
BY            CREATE        CONTINUOUS    DATABASE      DATABASES     DEFAULT
DELETE        DESC          DESTINATIONS  DIAGNOSTICS   DISTINCT      DROP
DURATION      END           EVERY         EXPLAIN       FIELD         FOR
FROM          GRANT         GRANTS        GROUP         GROUPS        IN
INF           INSERT        INTO          KEY           KEYS          KILL
LIMIT         SHOW          MEASUREMENT   MEASUREMENTS  NAME          OFFSET
ON            ORDER         PASSWORD      POLICY        POLICIES      PRIVILEGES
QUERIES       QUERY         READ          REPLICATION   RESAMPLE      RETENTION
REVOKE        SELECT        SERIES        SET           SHARD         SHARDS
SLIMIT        SOFFSET       STATS         SUBSCRIPTION  SUBSCRIPTIONS TAG
TO            USER          USERS         VALUES        WHERE         WITH
WRITE
```
如果使用了CnosQL的关键字作为标识符，则需要在每次查询中对该标识符加双引号。

关键字`time`是一种特殊情况。`time`可以是连续查询名称、数据库名称、测量名称、保留策略名称、订阅名称和用户名称。在这些情况下，查询中的`time`不需要双引号。`time`不能是字段键或标签键；CnosQL拒绝将`time`作为字段键或标记键的写入，并返回错误。

### 文字

  - #### 整数
CnosQL目前只支持十进制数字，并不支持其他进制数字。
```
int_lit             = ( "1" … "9" ) { digit } .
```
  - #### 浮点数
CnosQL目前只支持浮点数，并不支持指数。
```
float_lit           = int_lit "." int_lit .
```
  - #### 字符串
字符串必须和单引号搭配使用。如果加上转义字符，那么字符串中可以包含单引号。
```
string_lit          = `'` { unicode_char } `'` .
```
  - #### 持续时间
持续时间的字面值指定时间长度。整数字面值紧跟着(没有空格)下面列出的持续时间单位被称为持续时间字面值。可以使用混合单元指定持续时间。
```
duration_lit        = int_lit duration_unit .
duration_unit       = "ns" | "u" | "µ" | "ms" | "s" | "m" | "h" | "d" | "w" .
```

  - #### 日期和时间
与本文档的其余部分一样，EBNF中没有指定日期和时间文本格式。它是使用Go的日期/时间解析格式指定的，它是按照CnosQL要求的格式编写的引用日期。

参考日期时间为:January 2nd, 2006 at 3:04:05 PM
```
time_lit            = "2006-01-02 15:04:05.999999" | "2006-01-02" .
```
  - #### 布尔值
```
bool_lit            = TRUE | FALSE .
```
  - #### 正则表达式
```
regex_lit           = "/" { unicode_char } "/" .
```
### 查询

查询由一个或多个以分号分隔的语句组成。
```
query               = statement { ";" statement } .

statement           = alter_retention_policy_stmt |
                      create_continuous_query_stmt |
                      create_database_stmt |
                      create_retention_policy_stmt |
                      create_subscription_stmt |
                      create_user_stmt |
                      delete_stmt |
                      drop_continuous_query_stmt |
                      drop_database_stmt |
                      drop_measurement_stmt |
                      drop_retention_policy_stmt |
                      drop_series_stmt |
                      drop_shard_stmt |
                      drop_subscription_stmt |
                      drop_user_stmt |
                      explain_stmt |
                      explain_analyze_stmt |
                      grant_stmt |
                      kill_query_statement |
                      revoke_stmt |
                      select_stmt |
                      show_continuous_queries_stmt |
                      show_databases_stmt |
                      show_diagnostics_stmt |
                      show_field_key_cardinality_stmt |
                      show_field_keys_stmt |
                      show_grants_stmt |
                      show_measurement_cardinality_stmt |
                      show_measurement_exact_cardinality_stmt |
                      show_measurements_stmt |
                      show_queries_stmt |
                      show_retention_policies_stmt |
                      show_series_cardinality_stmt |
                      show_series_exact_cardinality_stmt |
                      show_series_stmt |
                      show_shard_groups_stmt |
                      show_shards_stmt |
                      show_stats_stmt |
                      show_subscriptions_stmt |
                      show_tag_key_cardinality_stmt |
                      show_tag_key_exact_cardinality_stmt |
                      show_tag_keys_stmt |
                      show_tag_values_stmt |
                      show_tag_values_cardinality_stmt |
                      show_users_stmt .
```
### 语句
  - #### 改变保留策略
 ```
 alter_retention_policy_stmt  = "ALTER RETENTION POLICY" policy_name on_clause
                                retention_policy_option
                                [ retention_policy_option ]
                                [ retention_policy_option ]
                                [ retention_policy_option ] .
 ```
  - #### 创建连续查询
 ```
 create_continuous_query_stmt = "CREATE CONTINUOUS QUERY" query_name on_clause
 [ "RESAMPLE" resample_opts ]
 "BEGIN" select_stmt "END" .

 query_name                   = identifier .

 resample_opts                = (every_stmt for_stmt | every_stmt | for_stmt) .
 every_stmt                   = "EVERY" duration_lit
 for_stmt                     = "FOR" duration_lit
 ```
  - #### 创建数据库
 ```
 create_database_stmt = "CREATE DATABASE" db_name
                        [ WITH
                            [ retention_policy_duration ]
                            [ retention_policy_replication ]
                            [ retention_policy_shard_group_duration ]
                            [ retention_policy_name ]
                         ] .
 ```
  - #### 创建保留策略
 ```
 create_retention_policy_stmt = "CREATE RETENTION POLICY" policy_name on_clause
                                retention_policy_duration
                                retention_policy_replication
                                [ retention_policy_shard_group_duration ]
                                [ "DEFAULT" ] .
 ```
  - #### 创建用户
 ```
 create_user_stmt = "CREATE USER" user_name "WITH PASSWORD" password
                    [ "WITH ALL PRIVILEGES" ] .
 ```
  - #### 删除
 ```
 e_stmt = "DELETE" ( from_clause | where_clause | from_clause where_clause ) .
 ```
  - #### 抛弃连续查询
 ```
 drop_continuous_query_stmt = "DROP CONTINUOUS QUERY" query_name on_clause .
 ```
  - #### 抛弃数据库
 ```
 drop_database_stmt = "DROP DATABASE" db_name .
 ```
  - #### 抛弃度量
 ```
 drop_measurement_stmt = "DROP MEASUREMENT" measurement .
 ```
  - #### 抛弃保留策略
 ```
 drop_retention_policy_stmt = "DROP RETENTION POLICY" policy_name on_clause .
 ```
  - #### 抛弃序列
 ```
 drop_series_stmt = "DROP SERIES" ( from_clause | where_clause | from_clause where_clause ) .
 ```
  - #### 抛弃分片
 ```
 drop_shard_stmt = "DROP SHARD" ( shard_id ) .
 ```
  - #### 抛弃用户
 ```
 drop_user_stmt = "DROP USER" user_name .
 ```
  - #### EXPLAIN
 ```
 explain_stmt = "EXPLAIN" select_stmt .
 ```
  - #### EXPLAIN ANALYZE
例如
 ```
 > explain analyze select mean(temperature) from air where time >= '2018-02-22T00:00:00Z' and time < '2018-02-22T12:00:00Z'
 EXPLAIN ANALYZE
 ----    -----------
  .
  └── select
    ├── execution_time: 279.292µs
    ├── planning_time: 952.75µs
    ├── total_time: 1.232042ms
    └── build_cursor
     ├── labels
      │   └── statement: SELECT mean(temperature) FROM data.autogen.air
      └── iterator_scanner
       └── labels
        └── expr: mean(temperature)
 ```
execution_time: 执行查询所花费的时间，包括读取时间序列数据、在数据流经迭代器时执行操作，以及从迭代器中提取已处理的数据。执行时间不包括将输出序列化为JSON或其他格式所花费的时间。
planning_time: 显示计划查询所花费的时间量。在CnosDB中规划查询需要许多步骤。根据查询的复杂性，与执行查询相比，计划可能需要更多的工作并消耗更多的CPU和内存资源。例如，执行查询所需的系列键的数量会影响计划查询的速度和所需的内存。
create_iterator: 表示本地CnosDB实例所做的工作──一组复杂的嵌套迭代器组合在一起，以产生最终的查询输出。
cursor type：EXPLAIN ANALYZE区分3种游标类型。虽然游标类型具有相同的数据结构和相同的CPU和I/O成本，但每种游标类型的构造原因不同，并在最终输出中分开。
block types：EXPLAIN ANALYZE分离存储块类型，并报告被解码的块的总数和它们在磁盘上的大小(以字节为单位)。

  - #### 授权
 ```
 grant_stmt = "GRANT" privilege [ on_clause ] to_clause .
 ```
  - #### 关闭查询
 ```
 kill_query_statement = "KILL QUERY" query_id .
 ```
  - #### 撤销
 ```
 revoke_stmt = "REVOKE" privilege [ on_clause ] "FROM" user_name .
 ```
  - #### 选择
 ```
 select_stmt = "SELECT" fields [ into_clause ] from_clause [ where_clause ]
          [ group_by_clause ] [ order_by_clause ] [ limit_clause ]
          [ offset_clause ] [ slimit_clause ] [ soffset_clause ] [ timezone_clause ] .
 ```
  - #### 展示基数
指用于精确估计或计数测量值、序列、标记键、标记键值和字段键的基数的一组命令。SHOW CARDINALITY命令有两种变体:估计的和精确的。估计值使用草图计算，是所有基数大小的安全默认值。准确的值是直接从TSM(时间结构合并树)数据中计算的，但是对于高基数的数据来说，运行这些值是非常昂贵的。除非必要，使用估计的品种。仅当在数据库上启用了时间序列索引(TSI)时，才支持按时间过滤。

  - #### SHOW CONTINUOUS QUERIES
 ```
 show_continuous_queries_stmt = "SHOW CONTINUOUS QUERIES" .
 ```
  - #### SHOW DATABASES
 ```
 show_databases_stmt = "SHOW DATABASES" .
 ```
  - #### SHOW DIAGNOSTICS
示节点信息，如构建信息、正常运行时间、主机名、服务器配置、内存使用和运行时诊断。
 ```
 show_diagnostics_stmt = "SHOW DIAGNOSTICS"
 ```
  - #### SHOW FIELD KEY CARDINALITY
 ```
 show_field_key_cardinality_stmt = "SHOW FIELD KEY CARDINALITY" [ on_clause ] [ from_clause ] [ where_clause ] [ group_by_clause ] [ limit_clause ] [ offset_clause ]

 show_field_key_exact_cardinality_stmt = "SHOW FIELD KEY EXACT CARDINALITY" [ on_clause ] [ from_clause ] [ where_clause ] [ group_by_clause ] [ limit_clause ] [ offset_clause ]
 ```
  - ####  SHOW FIELD KEYS
 ```
 show_field_keys_stmt = "SHOW FIELD KEYS" [on_clause] [ from_clause ] .
 ```
  - #### SHOW GRANTS
 ```
 show_grants_stmt = "SHOW GRANTS FOR" user_name .
 ```
  - #### SHOW MEASUREMENTS
 ```
 show_measurements_stmt = "SHOW MEASUREMENTS" [on_clause] [ with_measurement_clause ] [ where_clause ] [ limit_clause ] [ offset_clause ] .
 ```
  - #### SHOW QUERIES
 ```
 show_queries_stmt = "SHOW QUERIES" .
 ```
  - #### SHOW RETENTION POLICIES
 ```
 show_retention_policies_stmt = "SHOW RETENTION POLICIES" [on_clause] .
 ```
  - #### SHOW SERIES
 ```
 show_series_stmt = "SHOW SERIES" [on_clause] [ from_clause ] [ where_clause ] [ limit_clause ] [ offset_clause ] .
 ```
  - #### SHOW SERIES CARDINALITY
 ```
 show_series_cardinality_stmt = "SHOW SERIES CARDINALITY" [ on_clause ] [ from_clause ] [ where_clause ] [ group_by_clause ] [ limit_clause ] [ offset_clause ]

 show_series_exact_cardinality_stmt = "SHOW SERIES EXACT CARDINALITY" [ on_clause ] [ from_clause ] [ where_clause ] [ group_by_clause ] [ limit_clause ] [ offset_clause ]

 ```
  - #### SHOW SHARD GROUPS
 ```
 show_shard_groups_stmt = "SHOW SHARD GROUPS" .
 ```
  - #### SHOW SHARDS
 ```
 show_shards_stmt = "SHOW SHARDS" .
 ```
  - #### SHOW STATS
 ```
 show_stats_stmt = "SHOW STATS [ FOR '<component>' | 'indexes' ]"
 ```
  - #### SHOW TAG KEYS
 ```
 show_tag_keys_stmt = "SHOW TAG KEYS" [on_clause] [ from_clause ] [ where_clause ]
                 [ limit_clause ] [ offset_clause ] .
 ```
  - #### SHOW TAG VALUES
 ```
 show_tag_values_stmt = "SHOW TAG VALUES" [on_clause] [ from_clause ] with_tag_clause [ where_clause ]
                   [ limit_clause ] [ offset_clause ] .
 ```
  - #### SHOW TAG VALUES CARDINALITY
 ```
 show_tag_values_cardinality_stmt = "SHOW TAG VALUES CARDINALITY" [ on_clause ] [ from_clause ] [ where_clause ] [ group_by_clause ] [ limit_clause ] [ offset_clause ] with_key_clause

 show_tag_values_exact_cardinality_stmt = "SHOW TAG VALUES EXACT CARDINALITY" [ on_clause ] [ from_clause ] [ where_clause ] [ group_by_clause ] [ limit_clause ] [ offset_clause ] with_key_clause
 ```
  - #### SHOW USERS
 ```
 show_users_stmt = "SHOW USERS" .
 ```
### 条款
 ```
from_clause     = "FROM" measurements .

group_by_clause = "GROUP BY" dimensions fill(fill_option).

into_clause     = "INTO" ( measurement | back_ref ).

limit_clause    = "LIMIT" int_lit .

offset_clause   = "OFFSET" int_lit .

slimit_clause   = "SLIMIT" int_lit .

soffset_clause  = "SOFFSET" int_lit .

timezone_clause = tz(string_lit) .

on_clause       = "ON" db_name .

order_by_clause = "ORDER BY" sort_fields .

to_clause       = "TO" user_name .

where_clause    = "WHERE" expr .

with_measurement_clause = "WITH MEASUREMENT" ( "=" measurement | "=~" regex_lit ) .

with_tag_clause = "WITH KEY" ( "=" tag_key | "!=" tag_key | "=~" regex_lit | "IN (" tag_keys ")"  ) .
 ```
### 表达式
 ```SQL
binary_op        = "+" | "-" | "*" | "/" | "%" | "&" | "|" | "^" | "AND" |
                 "OR" | "=" | "!=" | "<>" | "<" | "<=" | ">" | ">=" .

expr             = unary_expr { binary_op unary_expr } .

unary_expr       = "(" expr ")" | var_ref | time_lit | string_lit | int_lit |
float_lit | bool_lit | duration_lit | regex_lit .
 ```
### 其他
 ```
alias            = "AS" identifier .

back_ref         = ( policy_name ".:MEASUREMENT" ) |
( db_name "." [ policy_name ] ".:MEASUREMENT" ) .

db_name          = identifier .

dimension        = expr .

dimensions       = dimension { "," dimension } .

field_key        = identifier .

field            = expr [ alias ] .

fields           = field { "," field } .

fill_option      = "null" | "none" | "previous" | int_lit | float_lit | "linear" .

host             = string_lit .

measurement      = measurement_name |
( policy_name "." measurement_name ) |
( db_name "." [ policy_name ] "." measurement_name ) .

measurements     = measurement { "," measurement } .

measurement_name = identifier | regex_lit .

password         = string_lit .

policy_name      = identifier .

privilege        = "ALL" [ "PRIVILEGES" ] | "READ" | "WRITE" .

query_id         = int_lit .

query_name       = identifier .

retention_policy = identifier .

retention_policy_option      = retention_policy_duration |
retention_policy_replication |
retention_policy_shard_group_duration |
"DEFAULT" .

retention_policy_duration    = "DURATION" duration_lit .

retention_policy_replication = "REPLICATION" int_lit .

retention_policy_shard_group_duration = "SHARD DURATION" duration_lit .

retention_policy_name = "NAME" identifier .

series_id        = int_lit .

shard_id         = int_lit .

sort_field       = field_key [ ASC | DESC ] .

sort_fields      = sort_field { "," sort_field } .

subscription_name = identifier .

tag_key          = identifier .

tag_keys         = tag_key { "," tag_key } .

user_name        = identifier .

var_ref          = measurement .
 ```