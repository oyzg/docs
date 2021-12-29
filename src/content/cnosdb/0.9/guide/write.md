# HTTP写入

### 使用CnosDB API创建数据库

要创建数据库，请向`/query`端点发送POST请求，并将URL参数`q`设置为`CREATE DATABASE <new_database_name>`下面的示例向本地主机上运行的cnosdb发送一个请求，并创建mydb数据库；

```bash
curl -i -XPOST http://localhost:8086/query --data-urlencode "q=CREATE DATABASE mydb"
```

### 使用CnosDB API写入数据

cnosdb API是将数据写入cnosdb的主要方法

- 如果使用cnosdb 0.9 API写入数据，需要发送`POST`送到`/write`接口，将数据写入到`mydb`数据库，那么数据应该包含以下部分：

  > `measurement`与`tag`之间使用`,`分隔
  >
  > `tag`组合可以有多个，`tag`之间使用`,`分隔
  >
  > `tag`与`field`之间使用空格分隔
  >
  > `field`组合可以有多个，`field`之间使用`,`分隔
  >
  > `field`与时间戳使用空格分隔
  
  - `measurement` : `cpu_load_short`
  - `tag key`=`tag value` : `host=server01,region=us-west`
  - `field key=field value`: `value=0.64` 
  - `timestamp` : `1434055562000000000`
  
  ```
  curl -i -XPOST 'http://localhost:8086/write?db=mydb'
  --data-binary 'cpu_load_short,host=server01,region=us-west value=0.64 1434055562000000000'
  ```

### 配置gzip压缩

cnosdb支持gzip压缩，要减少网络流量，需优先考虑一下选项

* 要接受来自cnosdb的压缩数据，请将`Accept-Encoding：gzip`heade信息添加到cnosdb API请求中

* 要在将数据发送到cnosdb之前压缩数据，将`Content-Encoding:gzip`heade信息添加到cnosdb API请求中

### 批量写入数据

通过用换行分隔每个`Points`，将多个`Points`同时写入到多个`series`中，以这种方式批处理`Points`可以提高性能。

下面的示例将三个`Points`写入数据库`mydb`:

```bash
curl -i -XPOST 'http://localhost:8086/write?db=mydb' --data-binary 'cpu_load_short,host=server02 value=0.67
cpu_load_short,host=server02,region=us-west value=0.55 1422568543702900257
cpu_load_short,direction=in,host=server01,region=us-west value=2.0 1422568543702900257'
```

### 从文件写入Points

通过传递`@filename`到文件来写入文件中的数据

格式正确的文件（`cpu_data.txt`）的示例：

```txt
cpu_load_short,host=server02 value=0.67
cpu_load_short,host=server02,region=us-west value=0.55 1422568543702900257
cpu_load_short,direction=in,host=server01,region=us-west value=2.0 1422568543702900257
```

写入数据cpu_data.txt到mydb与数据库

```bash
curl -i -XPOST 'http://localhost:8086/write?db=mydb' --data-binary @cpu_data.txt`
```

> 注意：如果您的数据文件具有超过5000个Points，则可能有必要将该文件拆分为多个文件，以便将数据批量写入cnosdb，默认情况下，HTTP请求在五秒后超时，超时后，cnosdb仍然将尝试写入这些点，但是不会确认它们已经成功写入

### No Schame设计

CnosDB是`schemaless` 数据库.
可以随时添加新的`measurement`, `tag`, 和`field`

### HTTP 响应摘要

* 2xx: 如果收到写请求`HTTP 204 No Content`,
* 4xx: CnosDB 无法处理该请求
* 5xx: 系统过载或严重损坏

#### 例子

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

##### 将`Point`写入不存在的数据库

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
