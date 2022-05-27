# Prometheus

CnosDB对Prometheus远程读写的支持是将以下HTTP端点添加到CnosDB。

- /api/v1/prom/read
- /api/v1/prom/write

此外，还有一个`/metrics`端点被配置为以Prometheus度量格式生成默认的Go度量。

## 创建目标数据库

在您的CnosDB中创建一个数据库来存放从Prometheus发送的数据。在下面的示例中，我们使用prometheus作为数据库名。

```sql
CREATE DATABASE "prometheus"
```

## 配置

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
## 如何在CnosDB中解析Prometheus度量

  - 将Prometheus度量名称作为CnosDB的measurement名称。
  - 将Prometheus的样本值作为CnosDB的字段键及字段值。通常是浮点数形式。
  - 将Prometheus的标签作为CnosDB的tags。
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