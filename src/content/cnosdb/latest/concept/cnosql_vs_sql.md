# CnosDB VS SQL

## 概念

  CnosDB类似于SQL数据库，但在许多方面有所不同。CnosDB是专门为时间序列数据构建的。关系数据库可以处理时间序列数据，但对常见的时间序列工作负载没有进行优化。CnosDB旨在存储大量时间序列数据，并快速对这些数据执行实时分析。

  在CnosDB中，时间戳标识任何给定数据系列中的单个点。这就像一个SQL数据库表，其中的主键是由系统预先设置的，并且总是时间。

  同时我们还认识到，您的Schema可能会随着时间而改变。在CnosDB中，您不必预先定义Schema。Point可以具有measurements上的一个字段、measurements上的所有字段或中间的任何数字。只需为新字段编写一个点，就可以向measurements添加新字段。如果您需要了解相关术语，如measurement、tag和field等，请阅读本节内容，了解SQL数据库到CnosDB术语交叉。 
  同时我们还认识到，您的Schema可能会随着时间而改变。在CnosDB中，您不必预先定义Schema。Point可以具有measurement上的所有字段或其中的任何数值。只需在写入新的Point中添加一个字段，就可以向measurements添加新字段。如果您需要了解相关术语，如measurement、tag和field等，请阅读本节内容，了解SQL数据库到CnosDB术语交叉。


## 术语

  下面的表是一个(非常)简单的例子，它是一个SQL数据库中名为`wind_speed`的表，其中没有索引的列是`wind_speed`，索引的列是`station_id`、`station`和`time`。

  ```
  +------------+---------------+---------------------+--------------+
  | station_id |   station     |       time          |  wind_speed |
  +------------+---------------+---------------------+--------------+
  |       1    | LianYunGang   | 1429185600000000000 |       63     |
  |       1    | LianYunGang   | 1429185601000000000 |       74     |
  |       1    | LianYunGang   | 1429185602000000000 |       51     |
  |       1    | LianYunGang   | 1429185603000000000 |       15     |
  |       2    | XiaoMaiDao    | 1429185600000000000 |       104    |
  |       2    | XiaoMaiDao    | 1429185601000000000 |       20     |
  |       2    | XiaoMaiDao    | 1429185602000000000 |       21     |
  |       2    | XiaoMaiDao    | 1429185603000000000 |       34     |
  +------------+---------------+---------------------+--------------+
  ```

  同样的数据在 CnosDB 中看起来是这样的：

    ```
    name: wind_speed
    tags: station_id=1, station=LianYunGang
    time			               wind_speed
    ----			               ------------
    2015-04-16T12:00:00Z	 63
    2015-04-16T12:00:01Z	 74
    2015-04-16T12:00:02Z	 51
    2015-04-16T12:00:03Z	 15
    
    name: wind_speed
    tags: station_id=2, station=XiaoMaiDao
    time			               wind_speed
    ----			               ------------
    2015-04-16T12:00:00Z	 104
    2015-04-16T12:00:01Z	 20
    2015-04-16T12:00:02Z	 21
    2015-04-16T12:00:03Z	 34
    ```

    - 时间序列数据在聚合场景中最有用
    - CnosDB 中的`measurement`类似于SQL数据库`table`。
    - CnosDB 中的`tags`类似于SQL数据库中的有索引的列。
    - CnosDB 中的`fields`类似SQL数据库中没有索引的列。
    - CnosDB 中的`points`类似于SQL行。
    - CnosDB 中不需要预定义`schema`

  基于对数据库术语的这种比较，CnosDB连续查询和保留策略类似于SQL数据库中的存储过程。它们只指定一次，然后定期自动执行。

  当然，SQL数据库和CnosDB之间存在一些主要差异。SQL join不能用于CnosDB的`measurements`; 您的模式设计应该反映这种差异。而且，正如我们上面提到的，`measurements`就像一个SQL表，其中的主索引总是预先设置为time。CnosDB时间戳必须在U`NIX epoch (GMT)`或格式化为`RFC3339`下有效的日期-时间字符串。

## CnosQL

  CnosDB支持的查询语言主要是CnosQL。

  CnosQL是一种类似sql的查询语言，用于与CnosDB交互。它经过精心设计，使之与其他SQL或类似SQL的环境中的SQL相似，同时还提供了特定于存储和分析时间序列数据的特性。然而，CnosQL不是SQL，缺乏对SQL高级用户习惯的更高级操作，如UNION、JOIN和HAVING的支持。

  CnosQL的SELECT语句遵循SQL SELECT语句的形式:

  `SELECT <stuff> FROM <measurement_name> WHERE <some_conditions>`

  `WHERE`是可选的

  要获得上面部分的CnosDB输出，您需要输入:

  `SELECT * FROM "wind_speed"`

  如果你只想看到LianYunGang的数据，你可以输入:

  `SELECT * FROM "wind_speed" WHERE "station" = 'LianYunGang'`

  如果你想查看2022年2月16日12:00:01 UTC之后LianYunGang的数据，你可以输入:

  `SELECT * FROM "wind_speed" WHERE "station" = 'LianYunGang' AND time > '2015-04-16 12:00:01'`

  如上例所示，CnosQL允许您在`WHERE`语句中指定查询的时间范围。可以使用单引号括起来的日期-时间字符串，格式为Y`YYY-MM-DD HH:MM:SS.MMM `(`MMM`是可选的毫秒数，您还可以指定微秒或纳秒)。你也可以在`now()`中使用相对时间，它指的是服务器的当前时间戳:

  `SELECT * FROM "wind_speed" WHERE time > now() - 1h`

  该查询输出wind_speed的measurements中的数据，其中时间戳比服务器当前时间早1小时。使用now()指定持续时间的选项有:ns(纳秒)、u或µ(微秒)、ms(毫秒)、s(秒)、m(分钟)、h(小时)、d(天)和w(周)。


## CnosDB 并非 CRUD

  CnosDB是一个针对时间序列数据进行了优化的数据库。这些数据通常来自分布式传感器组、大型网站的点击数据或金融交易列表。

  这些数据的一个共同之处是，它们在总体上更有用。有一篇文章说，你的电脑在UTC时间周二12:38:35的时候CPU利用率为12%，这很难从中得出结论。当与本序列的其他部分结合使用时，它将变得更加有用。这是随着时间的推移趋势开始显现的地方，可以从数据中得出可操作的见解。此外，时间序列数据通常只写入一次，很少更新。

  其结果是，CnosDB不是一个完整的CRUD数据库，而是更像一个CR-ud，优先考虑创建和读取数据的性能，而不是更新和销毁，并防止一些更新和销毁行为，以使创建和读取性能更高:

  - 要更新一个点，请插入一个具有相同measurements、tag set和timestamp的点。
  - 您可以`DROP`或`DELETE`series，但不能基于字段值删除单个Point。作为一种解决方案，您可以搜索字段值，检索时间，然后基于时间字段进行DELETE操作。
  - 您还不能更新或重命名tags。要修改一系列点的tags，请找到有问题标记值的点，将值更改为所需的值，将这些点写回，然后删除带有旧tag values的序列。
  - 你不能通过tag keys来删除tags。
