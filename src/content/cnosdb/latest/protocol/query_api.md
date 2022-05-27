# CnosDB Query API

## 单条查询语句
CnosDB API 是在 CnosDB中查询数据的主要方式。

如果需要执行查询请求，需要将GET请求发送到/query端点，将URL参数db设置为目标数据库，并将参数q设置为查询语句。还可以通过发送相同的参数作为URL参数或作为带有`application/x-www-form-urlencoded`的正文的一部分来使用POST请求。

示例：
  ```
  curl -G 'http://localhost:8086/query?pretty=true' --data-urlencode "db=oceanic_station" --data-urlencode "q=SELECT \"speed\" FROM \"wind\" WHERE \"station\"='LianYunGang'"
  ```
其结果为：
  ```
 {
  "results": [
      {_
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
## 返回错误
CnosDB返回JSON，查询的结果会在`results`数组中，如果发生错误，CnosDB会设置一个带有`error`的key

## 多条查询语句
多条查询语句需要用`;`分隔
 ```shell
 curl -G 'http://localhost:8086/query?pretty=true' --data-urlencode "db=oceanic_station" --data-urlencode "q=SELECT speed FROM wind WHERE station = 'XiaoMaiDao';SELECT temperature FROM air WHERE station = 'XiaoMaiDao'"
 ```

## 时间精度
CnosDB中的所有内容都以UTC存储和输出。默认情况下，时间戳以RFC3339格式返回，例如 2015-08-04T19:05:00Z；如果想要Unix纪元格式的时间戳，则需要在请求中添加字符串参数：epoch=[h, m, s, ms, u, ns]
  ```shell
  curl -G 'http://localhost:8086/query?pretty=true' --data-urlencode "db=oceanic_station" --data-urlencode "epoch=s" --data-urlencode "q=SELECT temperature FROM air WHERE station = 'XiaoMaiDao'"
  ```

## 最大行限制
`max-row-limit`配置选项允许用于限制返回结果最大数量，以防止CnosDB在聚合结果时耗尽内存，`max-row-limit`配置选项默认设置为0，该默认设置允许每个请求返回无限数量的行。
最大行限制适用于非块查询，分块查询可以返回无限数量的points。

## Chunking
通过设置查询字符串参数chunked=true，可以使用分块以流式批处理而不是作为单个响应返回结果。响应将按series或每10000point分块，以先发生者为准。要将最大块大小更改为不同的值，需要将查询字符串chunk_size设置为不同的值