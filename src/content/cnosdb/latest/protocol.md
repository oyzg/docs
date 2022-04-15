# 数据协议

## CnosDB line Protocol

CnosDB行协议是一种基于文本格式将点写入CnosDB的行协议。

- ### CnosDB行协议参考
    #### 语法
    ```
    <measurement>[,<tag_key>=<tag_value>[,<tag_key>=<tag_value>]] <field_key>=<field_value>[,<field_key>=<field_value>] [<timestamp>]
    ```
    
    行协议接受换行符`\n`，对空格敏感。
    
    >注意：行协议不支持在标签值或字段值中使用换行符`\n`。
    #### 语法描述
    - `measurement`- 必须。是measurement项的名字。CnosDB接受每一个点的measurement值。为string类型。

    - `tag set` - 可选。为该点所有的标记键值对。tag keys和tag values都是string类型。

    - `field set` - 必须。每一个点必须要有一个field。是该点所有的字段键值对。可以是任何类型。

    - `timestamp` - 可选。如果时间戳没有包含在点中，则CnosDB将在UTC中使用服务器的本地纳秒时间戳。
    
    #### 性能小提示
    
    - 将数据发送到CnosDB之前，请使用[Go bytes.Compare function](https://pkg.go.dev/bytes#Compare)对数据根据tag key排序。
    - 要显著改善压缩，请对时间戳使用尽可能粗糙的精度。
    - 使用NTP (Network Time Protocol)同步主机时间。CnosDB使用UTC格式的主机本地时间为数据分配时间戳。如果主机的时钟没有与NTP同步，则主机写入到CnosDB的数据可能有不准确的时间戳。
    
    #### 例子
   
   - 将field值`-1.234456e+78`作为浮点数写入CnosDB

     `INSERT mydb value=-1.234456e+78`

     CnosDB支持用科学符号指定的字段值。

   - 将field值`1.0`作为浮点数写入CnosDB

     `INSERT mydb value=1.0`
  
   - 将field值`1`作为浮点数写入CnosDB

     `INSERT mydb value=1`
  
   - 将field值`1.0`作为整数写入CnosDB，在字段值后附加i，告诉CnosDB将数字存储为整数。

     `INSERT mydb value=1i`
  
   - 将field值`string exapmple`作为字符串写入CnosDB

     `INSERT mydb value="stringing along"`
  
   - 将field值`true`作为布尔值写入CnosDB

     `INSERT mydb value=true` 
   - 尝试将字符串写入先前接收浮点数的字段
   - 
     如果float和string的时间戳存储在同一个分片中:
      ```  
     INSERT mydb value=3 1465934559000000000
     INSERT mydb value="stringing example" 1465934559000000001
     ERR: {"error":"field type conflict: input field \"value\" on measurement \"mymeas\" is type string, already exists as type float"}
      ``` 
     如果float和string的时间戳没有存储在同一个分片中:
      ``` 
     INSERT mymeas value=3 1465934559000000000
     INSERT mymeas value="stringing example" 1466625759000000000
     ``` 

   - ### CnosDB行协议教程

     CnosDB行协议是一种将点写入数据库的基于文本的格式。点必须是行协议格式，以便CnosDB成功解析和写入点。
    
     #### 语法

     行协议格式中的一行文本表示CnosDB中的一个数据点。它将点的measurement value、tag set、field set和timestamp告知CnosDB。下面的代码块显示了一个行协议的示例，并将其分解为独立的组件:

     ```
     air,station=LianYunGang temperature=74 1642176540000000000
     |    -------------------- -----------------  |
     |              |              |              |
     |              |              |              |
     +-----------+--------+-+---------+-+---------+
     |measurement|,tag_set| |field_set| |timestamp|
     +-----------+--------+-+---------+-+---------+
     ```
     **`measurement`**
      - `measurement` - 要将数据写入的measurement的名字。measurement需符合线路协议。在本例子中，measurement为weather。
      - `tag set` - 标记集。包含在数据点中的标记。tag在行协议中是可选的。需要注意的是，tag set和measurement之间由逗号分隔，没有空格。用等号`=`分隔标签的键值对时，不需要插入空格，如:`<tag_key>=<tag_value>`。多个标记值对之间用逗号分隔，不能有空格。在本例子中，标记集由标记`station=LianYunGang`组成。
        当在标记集中使用引号时，行协议支持单引号和双引号，如下表所示:
      - `空格 I` - 将度量和字段集分开，或者，如果您在数据点中包含一个标记集，则使用空格将标记集和字段集分开。在行协议中需要空格。例如，没有tag set的有效行协议`air temperature=75 1642176360000000000`。
      - `field set` - 您的数据点的字段。每个行协议中的数据点至少需要一个字段。用等号=分隔字段的键值对，并且没有空格，比如：`<field_key>=<field_value>`。多个字段值对用逗号分隔，不能用空格，如：`<field_key>=<field_value>,<field_key>=<field_value>`。
      - `空格 II` - 用空格分隔field set和时间戳。如果包含时间戳，则行协议中需要空格。
      - `timestamp` - 数据点的时间戳，以纳秒级Unix时间为单位。时间戳在行协议中是可选的。如果没有为数据点指定时间戳，则CnosDB将在UTC中使用服务器的本地纳秒时间戳。

      #### 数据类型
   
      - measurements, tag keys, tag values和field keys总是字符串。
      - 时间戳为UNIX时间戳。最小时间戳为`-9223372036854775806`或`1677-09-21T00:12:43.145224194Z`。最大时间戳为`9223372036854775806`或`2262-04-11T23:47:16.854775806Z`。如上所述，根据默认配置，CnosDB假设时间戳具有纳秒精度。
      - field value可以是浮点数、整数、字符串或布尔值。在默认情况下，CnosDB假设所有的field value都是浮点数。
      - 在一个measurement中，一个分片中的字段类型不能不同。但多个分片中的字段类型可以不同。例如，如果InfluxDB试图将整数存储在与浮点数相同的分片中，则将整数写入之前接受的浮点数字段将失败:
        ```
        > INSERT air,station=LianYunGang temperature=72 1642176180000000000
        > INSERT air,station=LianYunGang temperature=79i 1642176540000000000
        ERR: {"error":"field type conflict: input field \"temperature\" on measurement \"air\" is type int64, already exists as type float"}
        ``
     #### 引号

       - 不要对时间戳使用双引号或单引号。这不是有效的线路协议。例如：
         ```
         > INSERT air,station=LianYunGang temperature=72 "1642176180000000000"
         ERR: {"error":"unable to parse 'air,station=LianYunGang temperature=72 \"1642176180000000000\"': bad timestamp"}
         ```
       - 永远不要给字段值(即使它们是字符串)加单引号，这也不是有效的线路协议。例如：
         ```
         > INSERT air,station=LianYunGang temperature='72' 1642176180000000000
         ERR: {"error":"unable to parse 'air,station=LianYunGang temperature='72'': invalid boolean"} 
         ```
       - 不要用双引号或单引号引用measurement名称、tag key、tag value和field key。这是有效的行协议，但CnosDB假定引用是名称的一部分。例如：
         ```
         > INSERT air,station=LianYunGang temperature=72 1642176180000000000
         > INSERT "air",station=LianYunGang temperature=79 1642176540000000000
         > SHOW MEASUREMENTS
           name: measurements
           ------------------
           name
           "air"
           air
         ``` 
         要查询"air"中的数据，需要使用双引号，并使用正确的转义字符。
         ```
         > SELECT * FROM "\"air\""
         name: "air"
         time                 station     temperature
         ----                 -------     -----------
         2022-01-14T16:09:00Z LianYunGang 79

         ```
       - 不要对浮点型、整型或布尔型字段值使用双引号。CnosDB将假定这些值是字符串。例如：
         ```
         > INSERT air,station=LianYunGang temperature="72"
         > SELECT * FROM air WHERE temperature >= 70
         >
         ```   
       - 对类型为字符串的字段值使用双引号。
         ```
         > INSERT air,station=LianYunGang temperature="too warm"
         > SELECT * FROM air
         name: air
         -------------
         time				            station	 temperature
         2022-01-14T16:09:00Z	LianYunGang	 too warm
         ```        
     #### 特殊字符和关键字
       对于tag keys,tag values,measurement,字符串类型的field values以及field keys总是使用反斜杠字符`\`进行转义。
       - 逗号`,`：
         ```
         wind,station=Lian\,YunGang visibility=59,temperature=59,pressure=56 1649664217071649000
         ```         
       - 等号`=`：
         ```
         wind,station=LianYunGang vis\=ibility=59,temperature=59,pressure=56 1649664217071649000
         ```   
       - 空格` `：
         ```
         wind,stat\ ion=LianYunGang visibility=59,temperature=59,pressure=56 1649664217071649000
         ```  
       - emojis 🥰： CnosDB的行协议支持emojis表情的输入，并且无需使用转义字符转义。例如：
         ```
         > INSERT 🌤,⛪️=LianYunGang 🌡=23
         > SELECT * FROM "🌤"
         name: 🌤
         time                        ⛪️          🌡
         ----                        ------      ----
         2022-04-14T03:50:01.705037Z LianYunGang 23

         ```  
       - 关键字:行协议接受CnosQL关键字作为标识符名称。通常，我们建议避免在模式中使用CnosQL关键字，因为它可能会在查询数据时造成混乱。 关键字`time`是一种特殊情况。`time`可以是连续查询名称、数据库名称、measurement名称、保留策略名称和用户名称。在这些情况下，`time`不需要在查询中使用双引号。`time`不能是字段键或标记键;CnosDB拒绝以`time`作为字段键或标记键的写操作，并返回错误。
   
## CnosDB Write API

- ### 使用CnosDB API创建数据库
   
    要创建数据库，先向`/query`端点发送`POST`请求，并将URL参数中的`q`设置为`CREATE DATABASE <new_database_name>`。例如,在CnosDB中创建一个名为"weather_data"的数据库。
    ``` 
    curl -i -XPOST http://localhost:8086/query --data-urlencode "q=CREATE DATABASE weather_data"
    ``` 
  
- ### 使用CnosDB API写入数据

  > `measurement`与`tag`之间使用`,`分隔
  >
  > `tag`组合可以有多个，`tag`之间使用`,`分隔
  >
  > `tag`与`field`之间使用空格分隔
  >
  > `field`组合可以有多个，`field`之间使用`,`分隔
  >
  > `field`与时间戳使用空格分隔
   
    使用CnosDB API写入数据，向/write端点发送POST请求。例如，向"weather_data"写入一个点。此数据的组成为：measurement为`wind`，field key为`speed`和`direction`，field values分别为`75`和`65`，timestamp为`1649664217085031000`。
    ```
    curl -i -XPOST 'http://localhost:8086/write?db=weather_data' --data-binary 'wind,station=LianYunGang speed=75,direction=65 1649664217085031000'
    ```
    写入点时，必须在`db`查询参数中指定一个已存在的数据库。如果你不通过`rp`查询参数提供保留策略，点将被写入数据库的默认保留策略。
    
  
- ### 写入多点

    将多个点同时Post到多个序列，每个点用一个新行分开。以这种方式对点进行批处理可以获得更高的性能。
    
    通过用换行分隔每个`Points`，将多个`Points`同时写入到多个`series`中，以这种方式批处理`Points`可以提高性能。

    下面的示例将三个`Points`写入数据库`mydb`:

    ```bash
    curl -i -XPOST 'http://localhost:8086/write?db=weather_data' --data-binary 'wind,station=LianYunGang speed=75,direction=65 1649664217085027000
    wind,station=LianYunGang speed=75,direction=65 1649664217085031000
    wind,station=XiaoMaiDao speed=70,direction=63 1649664217085036000'

- ### 配置gzip压缩

    cnosdb支持gzip压缩，要减少网络流量，需优先考虑一下选项

    * 要接受来自cnosdb的压缩数据，请将`Accept-Encoding：gzip`heade信息添加到cnosdb API请求中

    * 要在将数据发送到cnosdb之前压缩数据，将`Content-Encoding:gzip`heade信息添加到cnosdb API请求中

- ### 从文件写入Points

    通过传递`@filename`到文件来写入文件中的数据

    格式正确的文件（`data.txt`）的示例：

    写入数据data.txt到weather_data数据库

    ```bash
    curl -i -XPOST 'http://localhost:8086/write?weather_data' --data-binary @data.txt
    ```
    注意：如果您的数据文件具有超过5000个Points，则可能有必要将该文件拆分为多个文件，以便将数据批量写入cnosdb，默认情况下，HTTP请求在五秒后超时，超时后，cnosdb仍然将尝试写入这些点，但是不会确认它们已经成功写入

## CnosDB Query API

- ### 单条查询语句
    CnosDB API 是在 CnosDB中查询数据的主要方式。

    如果需要执行查询请求，需要将GET请求发送到/query端点，将URL参数db设置为目标数据库，并将参数q设置为查询语句。还可以通过发送相同的参数作为URL参数或作为带有`application/x-www-form-urlencoded`的正文的一部分来使用POST请求。

    示例：
    ```
    curl -G 'http://localhost:8086/query?pretty=true' --data-urlencode "db=weather_data" --data-urlencode "q=SELECT \"speed\" FROM \"wind\" WHERE \"station\"='LianYunGang'"
    ```
    其结果为：
    ```
   {
    "results": [
        {
            "statement_id": 0,
            "series": [
                {
                    "name": "wind",
                    "columns": [
                        "time",
                        "speed"
                    ],
                    "values": [
                        [
                            "2022-04-11T08:03:37.085027Z",
                            75
                        ],
                        [
                            "2022-04-11T08:03:37.085031Z",
                            75
                        ]
                      ]  
                    }
                ]
            }
        ]
    }

    ```
- ### 返回错误
   CnosDB返回JSON，查询的结果会在`rusults`数组中，如果发生错误，CnosDB会设置一个带有`error`的key

- ### 多条查询语句
   多条查询语句需要用`;`分隔
   ```shell
   curl -G 'http://localhost:8086/query?pretty=true' --data-urlencode "db=weather_data" --data-urlencode "q=SELECT speed FROM wind WHERE station = 'XiaoMaiDao';SELECT temperature FROM air WHERE station = 'XiaoMaiDao'"
   ```

- ### 时间精度
    CnosDB中的所有内容都以UTC存储和输出。默认情况下，时间戳以RFC3339格式返回，例如 2015-08-04T19:05:00Z，如果想要Unix纪元格式的时间戳，则需要在请求中包含字符串参数：epoch=[h, m, s, ms, u, ns]
    ```shell
    curl -G 'http://localhost:8086/query?pretty=true' --data-urlencode "db=oceanic_station" --data-urlencode "epoch=s" --data-urlencode "q=SELECT temperature FROM air WHERE station = 'XiaoMaiDao'"
    ```

- ### 最大行限制
    `max-row-limit`配置选项允许用于限制返回结果最大数量，以防止CnosDB在聚合结果时耗尽内存，`max-row-limit`配置选项默认设置为0，该默认设置允许每个请求返回无限数量的行。
    最大行限制适用于非块查询，分块查询可以返回无限数量的points。

- ### Chunking
    通过设置查询字符串参数chunked=true，可以使用分块以流式批处理而不是作为单个响应返回结果。响应将按series或每10000point分块，以先发生者为准。要将最大块大小更改为不同的值，需要将查询字符串chunk_size设置为不同的值

## Prometheus

CnosDB对Prometheus远程读写的支持是将以下HTTP端点添加到CnosDB。

- /api/v1/prom/read
- /api/v1/prom/write 

此外，还有一个`/metrics`端点被配置为以Prometheus度量格式生成默认的Go度量。

- ### 创建目标数据库

  在您的CnosDB中创建一个数据库来存放从Prometheus发送的数据。在下面的示例中，我们使用prometheus作为数据库名。

  `CREATE DATABASE "prometheus"`

- ### 配置

  若要在CnosDB中使用Prometheus远程读写API，请在Prometheus配置文件中的以下设置中添加URL值:
  
  - `remote_write`
  - `remote_read`

  这些URL必须可以从运行的Prometheus服务器解析，并使用运行CnosDB的端口(默认情况下为8086)。还要使用包含数据库名称的`db= `查询参数。
   
  例如：

  ```
  remote_write:
  - url: "http://localhost:8086/api/v1/prom/write?db=prometheus"

  remote_read:
  - url: "http://localhost:8086/api/v1/prom/read?db=prometheus"
  ```  
- ### 如何在CnosDB中解析Prometheus度量
  
  - Prometheus度量名称成为CnosDB的measurement名称。
  - Prometheus的样本值成为CnosDB的字段键及字段值。通常是浮点数形式。
  - Prometheus的标签成为CnosDB的tags。
  - 所有的`# HELP `和`# TYPE `行被忽略。
  ```
    # Prometheus 
    example_metric{queue="0:http://example:8086/api/v1/prom/write?db=prometheus",le="0.005"} 308
    
    # CnosDB
    measurement
    example_metric
    tags
    queue = "0:http://example:8086/api/v1/prom/write?db=prometheus"
    le = "0.005"
    job = "prometheus"
    instance = "localhost:9090"
    __name__ = "example_metric"
    fields
    value = 308
  ```

## Telegraf

 Telegraf是CnosDB的数据收集代理，用于收集和报告指标。它庞大的输入插件库和“即插即用”的架构可以让您快速、轻松地从许多不同的来源收集指标。

- ### 配置 Telegraf

  Telegraf的输入和输出插件在Telegraf的配置文件(`Telegraf .conf`)中启用和配置。您有以下配置Telegraf的选项:
  
  - #### 自动配置 Telegraf
