# 入门指南

## cnosdb-cli

**[CnosQL 入门](./cnosql.md)**


## Go SDK example

- ###  摘要

  学习使用CnosDB Golang SDK 操作CnosDB


- ### 使用`/ping`查看cnosdb状态

  ```
  func ExampleClient_Ping() {
  
      c, err := client.NewHTTPClient(client.HTTPConfig{
          Addr: "http://localhost:8086",
      })
      if err != nil {
          fmt.Println("Error creating CnosDB Client: ", err.Error())
      }
      defer c.Close()
  
      _, rs, err := c.Ping(0)
      fmt.Println("version:", rs)
      if err != nil {
          fmt.Println("Error pinging CnosDB: ", err.Error())
      }
  }
  ```

- ### 使用http client写入一个point

  ```
  func ExampleClient_write() {
      // Make client
      c, err := client.NewHTTPClient(client.HTTPConfig{
          Addr: "http://localhost:8086",
      })
      if err != nil {
          fmt.Println("Error creating CnosDB Client: ", err.Error())
      }
      defer c.Close()
  
      // Create a new point batch
      bp, _ := client.NewBatchPoints(client.BatchPointsConfig{
          Database:  "oceanic_station",
          Precision: "s",
      })
  
      // Create a point and add to batch
      tags := map[string]string{"station": "XiaoMaiDao"}
      fields := map[string]interface{}{
          "temperature": 67,
          "visibility":  58,
      }
      pt, err := client.NewPoint("air", tags, fields, time.Now())
      if err != nil {
          fmt.Println("Error: ", err.Error())
      }
      bp.AddPoint(pt)
  
      // Write the batch
      c.Write(bp)
  }
  ```

- ### 创建一个BatchPoint，并添加一个Point

  ```
  func ExampleBatchPoints() {
      // Create a new point batch
      bp, _ := client.NewBatchPoints(client.BatchPointsConfig{
          Database:  "oceanic_station",
          Precision: "s",
      })
  
      // Create a point and add to batch
      tags := map[string]string{"station": "XiaoMaiDao"}
      fields := map[string]interface{}{
          "temperature": 67,
          "visibility":  58,
      }
      pt, err := client.NewPoint("air", tags, fields, time.Now())
      if err != nil {
          fmt.Println("Error: ", err.Error())
      }
      bp.AddPoint(pt)
  }
  ```

- ### 使用BatchPoint的setter方法

  ```
  func ExampleBatchPoints_setters() {
      // Create a new point batch
      bp, _ := client.NewBatchPoints(client.BatchPointsConfig{})
      bp.SetDatabase("oceanic_station")
      bp.SetPrecision("ms")
  
      // Create a point and add to batch
      tags := map[string]string{"station": "XiaoMaiDao"}
      fields := map[string]interface{}{
          "temperature": 67,
          "visibility":  58,
      }
      pt, err := client.NewPoint("air", tags, fields, time.Now())
      if err != nil {
          fmt.Println("Error: ", err.Error())
      }
      bp.AddPoint(pt)
  }
  ```

- ### 创建一个point并设置时间戳

  ```
  func ExamplePoint() {
      tags := map[string]string{"station": "XiaoMaiDao"}
      fields := map[string]interface{}{
          "temperature": 67,
          "visibility":  58,
      }
      pt, err := client.NewPoint("air", tags, fields, time.Now())
      if err == nil {
          fmt.Println("We created a point: ", pt.String())
      }
  }
  ```

- ### 创建一个没有时间戳的point

  ```
  func ExamplePoint_withoutTime() {
      tags := map[string]string{"station": "XiaoMaiDao"}
      fields := map[string]interface{}{
          "temperature": 67,
          "visibility":  58,
      }
      pt, err := client.NewPoint("air", tags, fields)
      if err == nil {
          fmt.Println("We created a point w/o time: ", pt.String())
      }
  }
  ```

- ### 创建一个查询请求

  ```
  func ExampleClient_query() {
      // Make client
      c, err := client.NewHTTPClient(client.HTTPConfig{
          Addr: "http://localhost:8086",
      })
      if err != nil {
          fmt.Println("Error creating CnosDB Client: ", err.Error())
      }
      defer c.Close()
  
      q := client.NewQuery("SELECT temperature FROM air limit 10", "oceanic_station", "ns")
      if response, err := c.Query(q); err == nil && response.Error() == nil {
          fmt.Println(response.Results)
      }
  }
  ```

- ### 创建一个查询请求并指定数据库

  ```
  func ExampleClient_createDatabase() {
      // Make client
      c, err := client.NewHTTPClient(client.HTTPConfig{
          Addr: "http://localhost:8086",
      })
      if err != nil {
          fmt.Println("Error creating CnosDB Client: ", err.Error())
      }
      defer c.Close()
  
      q := client.NewQuery("CREATE DATABASE mydb", "", "")
      if response, err := c.Query(q); err == nil && response.Error() == nil {
          fmt.Println(response.Results)
      }
  }
  
  ```

## Curl 查询和写入数据

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
  注意：如果您的数据文件具有超过5000个Points，则可能有必要将该文件拆分为多个文件，以便将数据批量写入cnosdb，默认情况下，HTTP请求在五秒后超时，超时后，cnosdb仍然将尝试写入这些点，但是不会确认它们已经成功写入。

- ### 将`Point`写入不存在的数据库

  ```bash
  curl -i -XPOST 'http://localhost:8086/write?db=atlantis' --data-binary 'liters value=10'
  ```
  
  返回内容:
  
  ```bash
  HTTP/1.1 404 Not Found
  Content-Type: application/json
  Request-Id: [...]
  X-cnosdb-Version: 1.4.x
  Date: Wed, 01 Mar 2017 19:38:35 GMT
  Content-Length: 45
  
  {"error":"database not found: \"atlantis\""}
  ```

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

- ### No Schame设计

  CnosDB是`schemaless` 数据库.
  可以随时添加新的`measurement`, `tag`, 和`field`

- ### HTTP 响应摘要

  * 2xx: 如果收到写请求`HTTP 204 No Content`,
  * 4xx: CnosDB 无法处理该请求
  * 5xx: 系统过载或严重损坏

- ### 例子

  ```bash
  curl -i -XPOST 'http://localhost:8086/write?db=hamlet' --data-binary 'tobeornottobe booleanonly=true'
  
  curl -i -XPOST 'http://localhost:8086/write?db=hamlet' --data-binary 'tobeornottobe booleanonly=5'
  ```
  
  返回内容：
  
  ```bash
  HTTP/1.1 400 Bad Request
  Content-Type: application/json
  Request-Id: [...]
  X-cnosdb-Version: 1.4.x
  Date: Wed, 01 Mar 2017 19:38:01 GMT
  Content-Length: 150
  
  {"error":"field type conflict: input field \"booleanonly\" on measurement \"tobeornottobe\" is type float, already exists as type boolean dropped=1"}
  ```
