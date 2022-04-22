# CnosDB配置

## 概述

### 配置概述

  通过配置文件(`cnosdb.conf`)和环境变量配置CnosDB。如果不取消注释配置选项，系统将使用其默认设置。本文档中的配置均为系统默认配置。

### 环境变量

  配置文件中的所有配置设置可以在配置文件中指定，也可以在环境变量中指定。环境变量覆盖配置文件中的等效选项。如果配置文件或环境变量中没有指定配置选项，则CnosDB使用其内部默认配置。

### 使用配置文件

  CnosDB系统对配置文件中的所有设置都有内部默认值。如果需要查看默认配置，使用命令cnosdb config。

  本地CnosDB配置文件位于这里:
    - Linux: /etc/cnosdb/cnosdb.conf
    - macOS: /usr/local/etc/cnosdb.conf

  注释掉的设置设置为系统内部默认值。未加注释的设置覆盖内部默认值。注意，本地配置文件不需要包含每个配置设置。

  使用`--config`指令将配置文件导入CnosDB

  `cnosdb --config /etc/cnosdb/cnosdb.conf`

  将环境变量CNOSDB_CONFIG_PATH设置为配置文件的路径，并启动进程。例如:
   ```
  echo $CNOSDB_CONFIG_PATH
  /etc/cnosdb/cnosdb.conf

  cnosdb
   ```
### 全局设置

#### reporting-disabled = false

  CnosDB主要使用来自运行CnosDB节点的自愿报告的数据来跟踪不同的CnosDB版本的采用率。此数据帮助CnosDB支持对CnosDB的持续开发。

  `reporting-disabled`选项将每24小时将数据报告切换到`usage.cnosdb.com`。每个报告包括随机生成的标识符、操作系统、体系结构、CnosDB版本以及数据库数量、度量值和唯一序列。将此选项设置为`true`将禁用报告。

#### bind-address = "127.0.0.1:8088"

  用于备份和恢复的RPC服务的绑定地址。环境变量为：`CNOSDB_BIND_ADDRESS`

### 端口

#### 可用端口：

  `8086`：提供cnosdb http服务的默认端口

  `8088`：提供cnosdb 内部RPC服务以及备份恢复的默认端口

### 元节点

#### dir = "/var/lib/cnosdb/meta"

  元数据/raft数据库所在的目录。meta目录中的文件包括meta.db、CnosDB metastore文件。环境变量为:`CNOSDB_META_DIR`

#### retention-autocreate = true

  启用在创建数据库时自动创建DEFAULT保留策略autogen。保留策略autogen具有无限的持续时间，也被设置为数据库的DEFAULT保留策略，当写入或查询没有指定保留策略时使用该保留策略。禁用此设置，以防止在创建数据库时创建此保留策略。环境变量:`CNOSDB_META_RETENTION_AUTOCREATE`

#### logging-enabled = true

  启用记录来自元服务的消息。 环境变量:`CNOSDB_META_LOGGING_ENABLED`

### 数据节点

#### dir = "/var/lib/cnosdb/data"

  TSM引擎存储TSM文件的CnosDB目录。该目录可以被修改。环境变量:CNOSDB_DATA_DIR

#### wal-dir = "/var/lib/cnosdb/wal"

  存放预写日志(WAL)文件的目录位置。 环境变量:CNOSDB_DATA_WAL_DIR

#### wal-fsync-delay = "0s"

  同步之前写操作等待的时间。使用大于0的持续时间批量处理多个fsync调用。这对于较慢的磁盘或遇到WAL写争用时非常有用。0的默认值为每次写入WAL时同步。环境变量:`CNOSDB_DATA_WAL_FSYNC_DELAY`

#### index-version = "inmem"

  `tsi1. `用于新分片的分片索引类型。默认的(`inmem`)索引是在启动时重新创建的内存索引。如果需要启用基于磁盘的TSI (Time Series Index)索引，请将该值设置为`tsi1`。环境变量:`CNOSDB_DATA_INDEX_VERSION`

#### trace-logging-enabled = false

  在TSM引擎和WAL中启用附加调试信息的详细日志记录。跟踪日志为调试TSM引擎问题提供了更有用的输出。 环境变量:`CNOSDB_DATA_TRACE_LOGGING_ENABLED`

#### query-log-enabled = true

  在执行之前启用解析查询的日志记录。查询日志对于故障排除很有用，但会记录查询中包含的任何敏感数据。 环境变量:`CNOSDB_DATA_QUERY_LOG_ENABLED`
#### query-log-enabled = true

  在执行之前启用解析查询的日志记录。查询日志对于故障排除很有用，但会记录查询中包含的任何敏感数据。 环境变量:`CNOSDB_DATA_QUERY_LOG_ENABLED`

#### validate-keys = false

  验证传入的写入以确保键只有有效的Unicode字符。这个设置将产生一个小开销，因为必须检查每个键。

#### cache-max-memory-size = "1g"

  分片缓存在开始拒绝写操作之前所能达到的最大大小。有效的内存大小后缀是:k、m或g。没有大小后缀的值以字节为单位。环境变量:`CNOSDB_DATA_CACHE_MAX_MEMORY_SIZE`

#### cache-snapshot-memory-size = "25m"

  引擎快照缓存并将其写入TSM文件的大小，以释放内存。有效的内存大小后缀是:k、m或g。没有大小后缀的值以字节为单位。环境变量:`CNOSDB_DATA_CACHE_SNAPSHOT_MEMORY_SIZE`

#### cache-snapshot-write-cold-duration = "10m"

  如果分片还没有收到写或删除，引擎将快照缓存并将其写入新的TSM文件的时间间隔。环境变量:`CNOSDB_DATA_CACHE_SNAPSHOT_WRITE_COLD_DURATION`

#### compact-full-write-cold-duration = "4h"

  如果没有收到写或删除，TSM引擎将在一个分片中压缩所有TSM文件的时间间隔。环境变量:`CNOSDB_DATA_COMPACT_FULL_WRITE_COLD_DURATION`

#### max-concurrent-compactions = 0

  一次可以运行的并发全量和级别压缩的最大数目。默认值0会导致运行时将50%的CPU内核用于压缩。如果显式设置，则用于压缩的内核数量将被限制为指定的值。该设置不适用于缓存快照。环境变量:`CNOSDB_DATA_MAX_CONCURRENT_COMPACTIONS`

#### compact-throughput = "48m"

  允许TSM压缩写入磁盘的速率限制(以每秒字节为单位)。请注意，允许短突发以一个可能更大的值发生，该值由`compact-throughput-burst`设置。环境变量:`CNOSDB_DATA_COMPACT_THROUGHPUT`

#### compact-throughput-burst = "48m"

  允许TSM压缩写入磁盘的速率限制(以每秒字节为单位)。环境变量:`CNOSDB_DATA_COMPACT_THROUGHPUT_BURST`

#### tsm-use-madv-willneed = false

如果为`true`，那么MMap Advise值`MADV_WILLNEED`就输入/输出分页方面向内核建议如何处理映射内存区域，以及如何期望在不久的将来访问映射内存区域(与TSM文件有关)。因为这个设置在一些内核(包括CentOS和RHEL)上有问题，所以默认值是`false`。在某些情况下，将该值更改为`true`可能对磁盘速度较慢的用户有所帮助。环境变量:`CNOSDB_DATA_TSM_USE_MADV_WILLNEED`

### 索引

#### max-series-per-database = 1000000

  在删除写操作之前，每个数据库允许的最大序列数。默认设置为1000000(100万)。将该设置更改为0，以允许每个数据库无限数量的序列。如果某个点导致数据库中序列的数量超过max-series-per-database，则CnosDB将不会写入该点，并返回500，并出现以下错误:

  `{"error":"max series per database exceeded: <series>"}`

  环境变量:`CNOSDB_DATA_MAX_SERIES_PER_DATABASE`

#### max-values-per-tag = 100000

  每个标记键允许的标记值的最大数目。缺省值为100000(100,000)。将设置更改为0，以允许每个标记键的标记值数量不限。如果标记值导致标记键的标记值数量超过`max-values-per-tag`，则CnosDB将不写入该点，并返回部分写入错误。

  任何标签值超过`max-values-per-tag`的现有标签键将继续接受写操作，但创建新标签值的写操作将失败。

  环境变量:`CNOSDB_DATA_MAX_VALUES_PER_TAG`

#### max-index-log-file-size = "1m"

  当索引提前写日志(WAL)文件压缩为索引文件时，以字节为单位的阈值。较小的大小将导致日志文件被更快地压缩，并以写吞吐量为代价减少堆的使用。更高的大小将更少地被压缩，在内存中存储更多的系列，并提供更高的写吞吐量。有效的大小后缀是k、m或g(不区分大小写，1024 = 1k)。没有大小后缀的值以字节为单位。环境变量:`CNOSDB_DATA_MAX_INDEX_LOG_FILE_SIZE`

#### series-id-set-cache-size = 100

  指定要为TSI索引缓存的系列ID集的数量(默认为100)。集合中的系列id指的是在同一个索引谓词(标记过滤器)上匹配的序列。序列ID集是一个LRU缓存，所以一旦缓存满了，最近最少使用的集就会被驱逐。缓存的结果可以快速返回，因为当执行带有匹配标记过滤器的后续查询时，它们不需要重新计算。

  我们建议使用默认设置。将此值更改为0将禁用缓存，这可能会导致查询性能问题。只有当您知道数据库的所有度量的标记键值大于100时，才会增加这个值。增加缓存大小可能会导致堆使用的增加。

  环境变量:`CNOSDB_DATA_SERIES_ID_SET_CACHE_SIZE`

### 查询管理

#### write-timeout = "10s"

  写请求等待的时间，直到一个“超时”错误返回给调用者。默认值是10秒。环境变量:`CNOSDB_COORDINATOR_WRITE_TIMEOUT`

#### max-concurrent-queries = 0

  在您的实例上允许运行查询的最大数量。默认设置(0)允许无限次查询。环境变量:`CNOSDB_COORDINATOR_MAX_CONCURRENT_QUERIES`

#### query-timeout = "0s"

  在CnosDB终止查询之前，允许执行查询的最大持续时间。默认设置(0)允许查询在没有时间限制的情况下运行。此设置是一个持续时间。环境变量:`CNOSDB_COORDINATOR_QUERY_TIMEOUT`

#### log-queries-after = "0s"

  在CnosDB用检测到的慢速查询消息记录查询之前，查询所能持续的最长时间。默认设置(“0”)将永远不会告诉CnosDB记录查询。此设置是一个持续时间。环境变量:`CNOSDB_COORDINATOR_LOG_QUERIES_AFTER`

#### max-select-point = 0

  一个SELECT语句可以处理的最大点数。默认设置(0)允许SELECT语句处理无限数量的点。环境变量:`CNOSDB_COORDINATOR_MAX_SELECT_POINT`

### max-select-series = 0

  一个SELECT语句可以处理的最大序列数。默认设置(0)允许SELECT语句处理无限数量的序列。环境变量:`CNOSDB_COORDINATOR_MAX_SELECT_SERIES`

#### max-select-buckets = 0

  一个查询可以处理的GROUP BY time()桶的最大数量。默认设置(0)允许查询处理无限数量的桶。 环境变量:`CNOSDB_COORDINATOR_MAX_SELECT_BUCKETS`

### 保留策略

#### enabled = true

  设置为`false`可防止CnosDB强制执行保留策略。环境变量：`CNOSDB_RETENTION_ENABLED`

#### check-interval = "30m0s"

  CnosDB检查以强制执行保留策略的时间间隔。环境变量:`CNOSDB_RETENTION_CHECK_INTERVAL`

### 分片

#### enabled = true

  判断是否开启分片预创建服务。环境变量:`CNOSDB_SHARD_PRECREATION_ENABLED`

#### check-interval = "10m"

  运行预创建新分片检查的时间间隔。环境变量:`CNOSDB_SHARD_PRECREATION_CHECK_INTERVAL`

#### advance-period = "30m"

  未来CnosDB预先创建分片的最长时间。30m的默认值应该适用于大多数系统。在未来将此设置增加得太久可能会导致效率低下。环境变量:`CNOSDB_SHARD_PRECREATION_ADVANCE_PERIOD`

### 监控

  默认情况下，CnosDB将数据写入_internal数据库。如果该数据库不存在，则CnosDB自动创建它。_internal数据库的默认保留策略是7天。如果需要使用7天保留策略以外的其他策略，必须先创建该策略。

#### store-enabled = true

  设置为`false`在内部禁用记录统计。如果设置为`false`，它将大大增加诊断安装问题的难度。环境变量:`CNOSDB_MONITOR_STORE_ENABLED`

#### store-database = "_internal"

  用于记录统计信息的目标数据库。环境变量:`CNOSDB_MONITOR_STORE_DATABASE`

#### store-interval = "10s"

  CnosDB记录统计信息的时间间隔。默认值是每10秒一次。环境变量:`CNOSDB_MONITOR_STORE_INTERVAL`

### HTTP端点

  [http]部分设置控制CnosDB如何配置http端点。这些是进出CnosDB的主要机制。编辑此部分中的设置以启用HTTPS和身份验证。

#### enabled = true

  确定是否启用HTTP端点。如果要禁用对HTTP端点的访问，请将该值设置为false。请注意，CnosDB命令行接口(CLI)使用CnosDB API连接到数据库。环境变量:`CNOSDB_HTTP_ENABLED`

#### bind-address = ":8086"

  HTTP服务使用的绑定地址(端口)。环境变量:`CNOSDB_HTTP_BIND_ADDRESS`

#### auth-enabled = false

  确定是否通过HTTP和HTTPS启用用户认证。如果需要身份验证，请将该值设置为`true`。环境变量:`CNOSDB_HTTP_AUTH_ENABLED`

#### log-enabled = true

  确定是否启用HTTP请求日志记录。若要禁用日志记录，请将该值设置为`false`。环境变量:`CNOSDB_HTTP_LOG_ENABLED`

#### suppress-write-log = false

  确定启用日志时是否应该抑制HTTP写请求日志。

#### access-log-path = ""

  访问日志的路径，它决定是否使用`log-enabled = true`启用详细的写日志记录。指定启用时是否将HTTP请求日志写入指定的路径。如果cnosdb无法访问指定的路径，它将记录错误并退回到stderr。当启用HTTP请求日志记录时，此选项指定应该写入日志条目的路径。如果未指定，默认值是写入stderr，这会将HTTP日志与内部的CnosDB日志混合在一起。如果cnosdb无法访问指定的路径，它将记录一个错误，并退回到将请求日志写入stderr。环境变量:`CNOSDB_HTTP_ACCESS_LOG_PATH`

#### access-log-status-filters = []

  筛选应该记录的请求。每个过滤器的模式为nnn、nnx或nxx，其中n是一个数字，x是任何数字的通配符。要过滤所有5xx响应，请使用字符串5xx。如果使用多个过滤器，则只需要匹配一个。默认值是没有过滤器，每个请求都会被打印出来。环境变量:`CNOSDB_HTTP_ACCESS_LOG_STATUS_FILTERS_x`

#### write-tracing = false

  确定是否启用详细的写日志记录。设置为`true`为写负载启用日志记录。如果设置为`true`，这将复制日志中的每个写语句，因此不建议在一般情况下使用。环境变量:`CNOSDB_HTTP_WRITE_TRACING`

#### pprof-enabled = true

  确定是否启用/net/http/pprof HTTP端点。用于故障排除和监视。环境变量:`CNOSDB_HTTP_PPROF_ENABLED`

#### pprof-auth-enabled = false

    - /debug/pprof
    - /debug/requests
    - /debug/vars

  如果`auth-enabled`或`pprofessor -enabled`设置为`false`，则此设置无效。环境变量:`CNOSDB_HTTP_PPROF_AUTH_ENABLED`

#### debug-pprof-enabled = false

  启用默认`/pprof`端点并绑定到`localhost:6060`。用于调试启动性能问题。环境变量:`CNOSDB_HTTP_DEBUG_PPROF_ENABLED`

#### ping-auth-enabled = false

  启用`/ping`、`/metrics`和`/status`端点的身份验证。如果`auth-enabled`设置为`false`，则此设置无效。环境变量:`CNOSDB_HTTP_PING_AUTH_ENABLED`

#### https-enabled = false

  HTTPS是否启用。如果启用HTTPS协议，请将该值设置为`true`。环境变量:`CNOSDB_HTTP_HTTPS_ENABLED`

#### https-certificate = "/etc/ssl/cnosdb.pem"

  启用HTTPS时使用的SSL证书文件的路径。环境变量:`CNOSDB_HTTP_HTTPS_CERTIFICATE`

#### https-private-key = ""

  使用单独的私钥位置。如果只指定了`https-certificate`, httpd服务将尝试从`https-certificate`文件中加载私钥。如果指定了一个单独的`https-private-key`文件，httpd服务将从`https-private-key`文件加载私钥。环境变量:`CNOSDB_HTTP_HTTPS_PRIVATE_KEY`

#### shared-secret = ""

  用于使用JWT令牌验证公共API请求的共享秘密。环境变量:`CNOSDB_HTTP_SHARED_SECRET`

#### max-row-limit = 0

  系统在非分块查询中可以返回的最大行数。默认设置(0)允许无限的行数。如果查询结果超过指定值，则CnosDB在响应体中包含一个“partial”:true标记。环境变量:`CNOSDB_HTTP_MAX_ROW_LIMIT`

#### max-connection-limit = 0

  可以同时打开的最大连接数。超过限制的新连接将被删除。默认值`0`禁用限制。环境变量:`CNOSDB_HTTP_MAX_CONNECTION_LIMIT`

#### unix-socket-enabled = false

  通过UNIX域套接字启用HTTP服务。如果需要通过UNIX域套接字开启HTTP服务，请将该值设置为true。环境变量:`CNOSDB_HTTP_UNIX_SOCKET_ENABLED`

#### bind-socket = "/var/run/cnosdb.sock"

  UNIX域套接字的路径。环境变量:`CNOSDB_HTTP_UNIX_BIND_SOCKET`

#### max-body-size = 25000000

  客户端请求体的最大大小(以字节为单位)。当HTTP客户端发送的数据超过配置的最大大小时，会返回`413 Request Entity Too Large HTTP`响应。若要禁用该限制，请将该值设置为0。环境变量:`CNOSDB_HTTP_MAX_BODY_SIZE`

#### max-concurrent-write-limit = 0

  并发处理的最大写操作数。若要禁用该限制，请将该值设置为0。环境变量:`CNOSDB_HTTP_MAX_CONCURRENT_WRITE_LIMIT`

#### max-enqueued-write-limit = 0

  排队等待处理的最大写操作数。若要禁用该限制，请将该值设置为0。环境变量:`CNOSDB_HTTP_MAX_ENQUEUED_WRITE_LIMIT`

#### enqueued-write-timeout = 0

  在等待处理的队列中等待写操作的最大持续时间。如果要禁用该限制，请将该值设置为0或将`max-concurrent-write-limit`值设置为0。环境变量:`CNOSDB_HTTP_ENQUEUED_WRITE_TIMEOUT`

### 日志

#### format = "auto"

  确定要为日志使用哪个日志编码器。有效值为`auto`(默认值)、`logfmt`和`json`。使用默认的自动选项，如果输出到TTY设备(例如，终端)，则使用更友好的控制台编码。如果输出是`files`，则`auto`选项使用`logfmt`编码。`logfmt`和`json`选项对于与外部工具集成非常有用。环境变量:`CNOSDB_LOGGING_FORMAT`

#### level = "info"

  要发出的日志级别。有效值为`error`、`warn`、`info`(默认值)和`debug`。等于或高于指定级别的日志将被触发。环境变量:`CNOSDB_LOGGING_LEVEL`

#### suppress-logo = false

  抑制程序启动时打印的标志输出。如果STDOUT不是TTY，则标识总是被抑制的。环境变量:`CNOSDB_LOGGING_SUPPRESS_LOGO`

### 订阅

#### enabled = true

  确定是否启用用户服务。如果需要关闭用户服务，请将该值设置为`false`。环境变量:`CNOSDB_SUBSCRIBER_ENABLED`

#### http-timeout = "30s"

  HTTP写入到订阅服务器直至超时的持续时间。环境变量:`CNOSDB_SUBSCRIBER_HTTP_TIMEOUT`

#### insecure-skip-verify = false

  确定是否允许到订阅者的不安全的HTTPS连接。这在测试自签名证书时非常有用。环境变量:`CNOSDB_SUBSCRIBER_INSECURE_SKIP_VERIFY`

#### ca-certs = ""

  pem编码的CA certs文件的路径。如果为空字符串`“”`，则使用系统默认证书。环境变量:`CNOSDB_SUBSCRIBER_CA_CERTS`

#### write-concurrency = 40

  处理写通道的写入程序的数量。环境变量:`CNOSDB_SUBSCRIBER_WRITE_CONCURRENCY`

#### write-buffer-size = 1000

  写通道中缓冲的正在写的次数。环境变量:`CNOSDB_SUBSCRIBER_WRITE_BUFFER_SIZE`

### 连续查询

#### enabled = true

  设置为`false`，禁用CQs。环境变量:`CNOSDB_CONTINUOUS_QUERIES_ENABLED`

#### log-enabled = true

  设置为`false`，禁用CQ事件的日志记录。环境变量:`CNOSDB_CONTINUOUS_QUERIES_LOG_ENABLED`

#### query-stats-enabled = false

  当设置为`true`时，连续查询执行统计信息将被写入默认监视存储区。环境变量:`CNOSDB_CONTINUOUS_QUERIES_QUERY_STATS_ENABLED`

#### run-interval = "1s"

  CnosDB检查CQ是否需要运行的时间间隔。将此选项设置为CQs运行的最低时间间隔。例如，如果你最频繁的CQ每分钟运行，设置运行间隔为1米。环境变量:`CNOSDB_CONTINUOUS_QUERIES_RUN_INTERVAL`

### 传输层安全

  如果没有指定TLS配置设置，则根据用于构建CnosDB的Go`crypto/tls`包文档中的常量部分，CnosDB支持列出的所有加密套件id和实现的所有TLS版本。使用`SHOW DIAGNOSTICS`命令查看用于构建CnosDB的Go版本。

#### min-version = "tls1.0"

  即将协商的TLS协议的最小版本。有效值包括:`tls1.0`、`tls1.1`、`tls1.2`。如果不指定，则`min-version`为Go`crypto/TLS`包中指定的TLS最小版本。在本例中，`tls1.0`将最小版本指定为`tls1.0`。环境变量:`CNOSDB_TLS_MIN_VERSION`

#### max-version = "tls1.2"

  即将协商的TLS协议的最大版本。有效值包括:`tls1.0`、`tls1.1`、`tls1.2`。`max-version`为Go`crypto/TLS`包中指定的最大TLS版本号。在本例中，tls1.2将最大版本指定为TLS 1.2。环境变量:`CNOSDB_TLS_MAX_VERSION`