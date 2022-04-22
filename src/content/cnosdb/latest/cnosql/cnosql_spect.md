## CnosQL参考

- ### 介绍
  CnosQL的定义和详细信息
    - #### [符号](#符号)
    - #### [查询表示](#查询表示)
    - #### [字母和数字](#字母和数字)
    - #### [标识符](#标识符)
    - #### [关键字](#关键字)
    - #### [文字](#文字)
    - #### [查询](#查询)
    - #### [语句](#语句)
    - #### [条款](#条款)
    - #### [表达式](#表达式)
    - #### [其他](#其他)
    - #### [查询引擎内部](#查询引擎内部)
  要了解更多关于CnosQL的信息，请浏览以下内容：
    - #### [使用CnosQL探索数据](#使用cnosql探索数据)
    - #### [使用CnosQL探索您的模式](#)
    - #### [数据库管理](#)

- ### 符号

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

- ### 查询表示

    - #### 字符
  CnosQL是使用UTF-8编码的Unicode文本。
  ```
  newline             = /* the Unicode code point U+000A */ .
  unicode_char        = /* an arbitrary Unicode code point except newline */ .
  ```

- ### 字母和数字

  字母是ASCII字符的集合，加上下划线_ (U+005F)也被认为是字母。只支持十进制数字。
  ```
  letter              = ascii_letter | "_" .
  ascii_letter        = "A" … "Z" | "a" … "z" .
  digit               = "0" … "9" .
  ```

- ### 标识符
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

- ### 关键字
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

- ### 文字

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
- ### 查询

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
- ### 语句
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
- ### 条款
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
- ### 表达式
   ```
  binary_op        = "+" | "-" | "*" | "/" | "%" | "&" | "|" | "^" | "AND" |
                   "OR" | "=" | "!=" | "<>" | "<" | "<=" | ">" | ">=" .

  expr             = unary_expr { binary_op unary_expr } .

  unary_expr       = "(" expr ")" | var_ref | time_lit | string_lit | int_lit |
  float_lit | bool_lit | duration_lit | regex_lit .
   ```   
- ### 其他
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
- ### 查询引擎内部

  查询的生命周期是这样的；
    - 对CnosQL查询字符串进行标记，然后将其解析为抽象语法树(AST)。这是查询本身的代码表示。
    - AST被传递给`QueryExecutor`, `QueryExecutor`将查询定向到适当的处理程序。例如，与元数据相关的查询由元服务执行，`SELECT`语句由分片自己执行。
    - 然后，查询引擎确定与`SELECT`语句的时间范围匹配的分片。从这些分片中，为语句中的每个字段创建迭代器。
    - 迭代器被传递给发射器，发射器耗尽迭代器并连接结果点。发射器的工作是将简单的时间/值点转换为返回给客户端的更复杂的结果对象。

    - #### 理解迭代器
      迭代器是查询引擎的核心。它们为在一组点上循环提供了一个简单的接口。例如，这是一个浮点数的迭代器:
      ```
      type FloatIterator interface {
          Next() *FloatPoint
      }
      ```  
      这些迭代器是通过`IteratorCreator`接口创建的:
      ```
      type IteratorCreator interface {
          CreateIterator(opt *IteratorOptions) (Iterator, error)
      }
      ```  
      `IteratorOptions`提供了关于字段选择、时间范围和维度的参数，迭代器创建者在规划迭代器时可以使用这些参数。`IteratorCreator`接口用于许多级别，如`Shards`、`Shard`和`Engine`。这允许在适当的时候执行优化，例如返回预先计算的`COUNT()`。
      迭代器不仅仅是从存储器中读取原始数据。迭代器可以进行组合，以便围绕输入迭代器提供额外的功能。例如，`DistinctIterator`可以为输入迭代器计算每个时间窗口的不同值。或者，`FillIterator`可以生成输入迭代器所缺少的额外点。
      这种组合也很适合聚合。例如，像这样的语句:
      ```
      SELECT MEAN(temperature) FROM cpu GROUP BY time(10m)
      ```  
      本例中，MEAN(temperature)是一个从底层分片包装迭代器的`MeanIterator`。但是，如果我们可以添加一个额外的迭代器来确定平均值的导数:
      ```
      SELECT DERIVATIVE(MEAN(temperature), 20m) FROM cpu GROUP BY time(10m)
      ```    
    - #### 理解游标
      游标通过元组(时间、值)中的分片标识单个序列(测量值、标签集和字段)的数据。游标遍历以日志结构的合并树形式存储的数据，并跨级别处理重复数据删除、删除数据的tombstone和合并缓存(Write Ahead Log)。游标按时间升序或降序对(时间，值)元组进行排序。
    - #### 理解辅助字段
      因为CnosQL允许用户使用FIRST()、LAST()、MIN()和MAX()等选择器函数，所以引擎必须提供一种方法，在选择点的同时返回相关数据。
    - #### 内置的迭代器
      有许多内置迭代器可以让我们构建查询:
        - 排序合并迭代器——该迭代器将一个或多个迭代器合并成一个相同类型的新迭代器。该迭代器保证在开始下一个窗口之前输出窗口内的所有点，但不提供窗口内的排序保证。这允许快速访问聚合查询，而聚合查询不需要更强的排序保证。
        - 限制迭代器——该迭代器限制每个名称/标签组的点数。这是`LIMIT & OFFSET`语法的实现。
        - 填充迭代器——如果输入迭代器缺少额外的点，这个迭代器会注入额外的点。它可以提供空点、带有前一个值的点或带有特定值的点。
        - 缓冲迭代器——该迭代器提供了将一个点“未读”回缓冲区的能力，以便下次可以再次读取它。这被广泛用于为窗口提供前瞻。
        - Reduce迭代器——该迭代器为窗口中的每个点调用一个Reduce函数。当窗口完成时，输出该窗口的所有点。这用于简单的聚合函数，如COUNT()。
        - Reduce Slice迭代器——该迭代器首先收集窗口的所有点，然后将它们一次性全部传递给Reduce函数。迭代器返回结果。这用于聚合函数，如DERIVATIVE()。
        - Transform迭代器——该迭代器为输入迭代器中的每个点调用Transform函数。它用于执行二进制表达式。
        - 重复数据删除迭代器——此迭代器只输出唯一的点。它是资源密集型的，所以它只用于像元查询语句这样的小查询。
    - #### 调用迭代器
      CnosQL中的函数调用在两个级别上实现。为了提高效率，可以将一些调用封装在多个层上。例如，一个`COUNT()`可以在分片层执行，然后多个`counterator`可以与另一个`counterator`包装，以计算所有分片的计数。这些迭代器可以使用`NewCallIterator()`创建。有些迭代器更复杂，或者需要在更高的级别上实现。例如，在执行计算之前，`DERIVATIVE()`需要首先检索窗口的所有点。这个迭代器是由引擎本身创建的，较低级别的迭代器不会被要求创建。
    
