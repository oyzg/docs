# CnosDB line Protocol

CnosDB行协议是一种基于文本格式将点写入CnosDB的行协议。

## CnosDB行协议参考
### 语法
```sql
<measurement>[,<tag_key>=<tag_value>[,<tag_key>=<tag_value>]] <field_key>=<field_value>[,<field_key>=<field_value>] [<timestamp>]
```

行协议接受换行符`\n`，对空格敏感。

> 注意：行协议不支持在标签值或字段值中使用换行符`\n`。
### 语法描述
- `measurement`- 必须。是measurement项的名字。CnosDB接受每一个点的measurement值。为string类型。

- `tag set` - 可选。为该点所有的标记键值对。tag keys和tag values都是string类型。

- `field set` - 必须。每一个点必须要有一个field。是该点所有的字段键值对。可以是任何类型。

- `timestamp` - 可选。如果时间戳没有包含在点中，则CnosDB将在UTC中使用服务器的本地纳秒时间戳。

### 性能优化小提示

- 将数据发送到CnosDB之前，请使用[Go bytes.Compare function](https://pkg.go.dev/bytes#Compare)对数据根据tag key排序。
- 要显著改善压缩，请对时间戳使用尽可能粗糙的精度。
- 使用NTP (Network Time Protocol)同步主机时间。CnosDB使用UTC格式的主机本地时间为数据分配时间戳。如果主机的时钟没有与NTP同步，则主机写入到CnosDB的数据可能有不准确的时间戳。

### 例子

- 将field值`-1.234456e+78`作为浮点数写入CnosDB

    ```
    INSERT mydb value=-1.234456e+78
    ```

CnosDB支持用类型符号指定的字段值。

- 将field值`1.0`作为浮点数写入CnosDB

   ```INSERT mydb value=1.0```

- 将field值`1`作为浮点数写入CnosDB

    `INSERT mydb value=1`

- 将field值`1.0`作为整数写入CnosDB，在字段值后附加i，告诉CnosDB将数字存储为整数。

  `INSERT mydb value=1i`

- 将field值`string exapmple`作为字符串写入CnosDB

  `INSERT mydb value="stringing along"`

- 将field值`true`作为布尔值写入CnosDB

  `INSERT mydb value=true`
- 尝试将字符串写入先前接收浮点数的字段

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

## CnosDB行协议教程

    CnosDB行协议是一种将点写入数据库的基于文本的格式。点必须是行协议格式，以便CnosDB成功解析和写入点。

### 语法

> 行协议格式中的一行文本表示CnosDB中的一个数据点。它将点的measurement value、tag set、field set和timestamp告知CnosDB。下面的代码块显示了一个行协议的示例，并将其分解为独立的组件:

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

### 数据类型

- measurements, tag keys, tag values和field keys总是字符串。
- 时间戳为UNIX时间戳。最小时间戳为`-9223372036854775806`或`1677-09-21T00:12:43.145224194Z`。最大时间戳为`9223372036854775806`或`2262-04-11T23:47:16.854775806Z`。如上所述，根据默认配置，CnosDB假设时间戳具有纳秒精度。
- field value可以是浮点数、整数、字符串或布尔值。在默认情况下，CnosDB假设所有的field value都是浮点数。
- 在一个measurement中，一个分片中的字段类型不能不同。但多个分片中的字段类型可以不同。例如，如果InfluxDB试图将整数存储在与浮点数相同的分片中，则将整数写入之前接受的浮点数字段将失败:
  ```
  > INSERT air,station=LianYunGang temperature=72 1642176180000000000
  > INSERT air,station=LianYunGang temperature=79i 1642176540000000000
  ERR: {"error":"field type conflict: input field \"temperature\" on measurement \"air\" is type int64, already exists as type float"}
  ```
### 引号

- 不要对时间戳使用双引号或单引号，这不是有效的线路协议。例如：
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
- 要查询"air"中的数据，需要使用双引号，并使用正确的转义字符。
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
  对类型为字符串的字段值使用双引号。
  ```
  > INSERT air,station=LianYunGang temperature="too warm"
  > SELECT * FROM air
  name: air
  -------------
  time				            station	 temperature
  2022-01-14T16:09:00Z	LianYunGang	 too warm
  ```        
### 特殊字符和关键字
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
  - 关键字:行协议接受CnosQL关键字作为标识符名称。我们一般建议避免在模式中使用CnosQL关键字，因为它可能会在查询数据时造成混乱。 但关键字`time`是一种特殊情况。`time`可以是连续查询名称、数据库名称、measurement名称、保留策略名称和用户名称。在这些情况下，`time`不需要在查询中使用双引号。`time`不能是字段键或标记键;CnosDB拒绝以`time`作为字段键或标记键的写操作，并返回错误。