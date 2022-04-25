# CnosDB Write API

## 使用CnosDB API创建数据库

要创建数据库，先向`/query`端点发送`POST`请求，并将URL参数中的`q`设置为`CREATE DATABASE <new_database_name>`。例如,在CnosDB中创建一个名为"weather_data"的数据库。
  ``` 
  curl -i -XPOST http://localhost:8086/query --data-urlencode "q=CREATE DATABASE weather_data"
  ``` 

## 使用CnosDB API写入数据

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


## 写入多点

将多个点同时Post到多个序列，每个点用一个新行分开。以这种方式对点进行批处理可以获得更高的性能。

通过用换行分隔每个`Points`，将多个`Points`同时写入到多个`series`中，以这种方式批处理`Points`可以提高性能。

下面的示例将三个`Points`写入数据库`mydb`:

```bash
curl -i -XPOST 'http://localhost:8086/write?db=weather_data' --data-binary 'wind,station=LianYunGang speed=75,direction=65 1649664217085027000
wind,station=LianYunGang speed=75,direction=65 1649664217085031000
wind,station=XiaoMaiDao speed=70,direction=63 1649664217085036000'
```

## 配置gzip压缩

cnosdb支持gzip压缩，要减少网络流量，需优先考虑一下选项

  - 要接受来自cnosdb的压缩数据，请将`Accept-Encoding：gzip`heade信息添加到cnosdb API请求中

  - 要在将数据发送到cnosdb之前压缩数据，将`Content-Encoding:gzip`heade信息添加到cnosdb API请求中

## 从文件写入Points

通过传递`@filename`到文件来写入文件中的数据

格式正确的文件（`data.txt`）的示例：

写入数据data.txt到weather_data数据库

```bash
curl -i -XPOST 'http://localhost:8086/write?weather_data' --data-binary @data.txt
```
  注意：如果您的数据文件具有超过5000个Points，则可能有必要将该文件拆分为多个文件，以便将数据批量写入cnosdb，默认情况下，HTTP请求在五秒后超时，超时后，cnosdb仍然将尝试写入这些点，但是不会确认它们已经成功写入