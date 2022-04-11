# cnosdb_inspect

## cnosdb_inspect 工具
> CnosDB Inspect 是一个 CnosDB 磁盘实用程序，可用于：
>
> 1.查看有关磁盘分片的详细信息。
>
> 2.将数据从分片导出到可以插入回数据库的CnosDB 线路协议。
>
> 3.将 TSM 索引分片转换为 TSI 索引分片。

**语法**
```
cnosdb_inspect [ [ command ] [ options ] ]
```

- [deletetsm](#deletetsm)
- [dumptsm](#dumptsm)
- [dumptsi](#dumptsi)
- [buildtsi](#buildtsi)
- [dumptsmwal](#dumptsmwal)
- [report-disk](#report-disk)
- [report](#report)
- [reporttsi](#reporttsi)
- [verify](#verify)
- [verify-seriesfile](#verify-seriesfile)
- [verify-tombstone](#verify-tombstone)
- [export](#export)

# `deletetsm`

## `cnosdb_inspect deletetsm`

批量从原始 `TSM` 文件中删除`measurement`数据

#### 注意：仅当您的`CnosDB`离线（`CnosDB`服务未运行） 时才使用`deletetsm`。

### `语法`

```
cnosdb_inspect deletetsm --measurement <measurement_name> [ arguments ] <path>
```


`<path>`

文件的路径`.tsm`，默认位于`data`目录中。

指定路径时，通配符 (`*`) 可以替换一个或多个字符。

### `选项`

可选参数在括号中

`--measurement`

要从 TSM 文件中删除的`measurement`的名称。

`[ --sanitize]`

标记以删除包含不可打印的 `Unicode `字符的所有键。

`[--v]`

标记以启用详细日志记录。

### `例子`

从单个`shard`中删除一个`measurement`

```
./cnosdb_inspect deletetsm --sanitize /cnosdb/data/location/autogen/1384/*.tsm
```

从数据库中的所有`shard`中删除`measurement`

```
./cnosdb_inspect deletetsm --sanitize /cnosdb/data/location/autogen/*/*.tsm
```

# `dumptsm`

## `cnosdb_inspect dumptsm`

转储`tsm1`文件的底层细节，包括`TSM`文件和`WAL`文件

### `语法`

`cnosdb_inspect dumptsm [ options ] <path>`

`<path>`

文件的路径`.tsm`，默认位于`data`目录中。

### `选项`

可选参数在括号中

`[ --index ]`

用于转储原始索引数据的标志。默认值为`false`。

`[ --blocks ]`

转储原始块数据的标志。默认值为`false`。

`[ --all ]`

标志转储所有数据。注意：这可能会打印很多信息。默认值为`false`。

`[ --filter-key <key_name> ]`

仅显示与此键子字符串匹配的索引数据和块数据。默认值为`""`。

# `dumptsi`

## `cnosdb_inspect dumptsi`

转储有关`TSI`文件的底层信息，包括`.tsl`日志文件和`.tsi`文件

### `语法`

`cnosdb_inspect dumptsi [ options ] <index_path>`

若未指定任何选项，则会为每个文件提供汇总信息。

### `选项`

可选参数在括号中

`--series-file <series_path>`

`_series`数据库目录下的目录路径`data`。必须要有。

`[ --series]`

转储原始系列数据。

`[ --measurements]`

转储原始测量数据。
`
[ --tag-keys]`

转储原始标签键。

`[ --tag-values]`

转储原始标签值。

`[ --tag-value-series]`

为每个标签值转储原始系列。

`[ --measurement-filter <regular_expression>]`

通过测量正则表达式过滤数据。

`[ --tag-key-filter <regular_expression>]`

按标签键正则表达式过滤数据。

`[ --tag-value-filter <regular_expresssion>]`

按标签值正则表达式过滤数据。

### `例子`

指定_series和index目录的路径

`cnsodb_inspect dumptsi --series-file /path/to/db/_series /path/to/index`

指定_series目录和index文件的路径

`cnosdb_inspect dumptsi --series-file /path/to/db/_series /path/to/index/file0`

指定_series目录和多个index文件的路径

```
cnosdb_inspect dumptsi --series-file /path/to/db/_series /path/to/index/file0 /path/to/index/file1 ...
```

# `buildtsi`

## `cnosdb_inspect buildtsi`

构建基于 TSI（时间序列索引）磁盘的分片索引文件和关联的序列文件。索引被写入一个临时位置直到完成，然后移动到一个永久位置。如果发生错误，则此操作将回退到原始内存索引。

#### 注意： 仅适用于离线转换。 启用 TSI 后，新分片使用 TSI 索引。现有分片继续作为基于 TSM 的分片，直到离线转换。

### `语法`
```
cnosdb_inspect buildtsi [ options ] -datadir <data_dir> -waldir <wal_dir> [ options ]
```

####注意：将buildtsi命令与您要运行数据库的用户帐户一起使用，或者在运行命令后确保权限匹配。

### `选项`

可选参数在括号中

`[ --batch-size ]`

写入索引的批次大小。默认值为`10000`。设置此值会对性能和堆大小产生不利影响。

`[ --compact-series-file]`

压缩现有`series`文件，包括离线`series`。迭代每个`segment`中的`series`并将`Index`中的`non-tombstoned series`重写到旁边的新 `.tmp `文件。转换所有`segment`后，临时文件将覆盖原始段。

`[ --concurrency ]`

专用于分片索引的工作人员数量。默认值为`GOMAXPROCS`。

`[ --database <db_name> ]`

数据库的名称。

`--datadir <data_dir>`

`data`的文件路径。

`[ --max-cache-size ]`

开始拒绝写入之前缓存的最大大小。此值覆盖的配置设置 `[data] cache-max-memory-size`。默认值为`1073741824`。

`[ --max-log-file-size ]`

日志文件的最大大小。默认值为`1048576`。

`[ --retention <rp_name> ]`

保留策略的名称。

`[ --shard <shard_ID> ]`

分片的标识符。

`[ --v ]`

以详细模式启用输出的标志。
`
--waldir <wal_dir>`

`WAL`（预写日志）文件的目录。

### `例子`

转换节点上的所有`shard`

`cnosdb_inspect buildtsi --datadir ~/.cnosdb/data --waldir ~/.cnosdb/wal`

转换数据库的所有`shard`

`cnosdb_inspect buildtsi --database mydb --datadir ~/.cnosdb/data --waldir ~/.cnosdb/wal`

转换特定`shard`

```
cnodb_inspect buildtsi --database stress -shard 1 --datadir ~/.cnosdb/data --waldir ~/.cnosdb/wal
```

# `dumptsmwal`

## `cnosdb_inspect dumptsmwal`

仅转储一个或多个 WAL ( `.wal`) 文件中的所有条目，并排除 TSM ( `.tsm`) 文件

### `语法`

```
cnosdb_inspect dumptsmwal [ options ] <wal_dir>
```
### `选项`

可选参数在括号中

`[ --show-duplicates]`

标记以显示具有重复或无序`timestamp`的`key`。如果用户使用客户端设置的`timestamp`写入点，则可以写入具有相同`timestamp`（或具有时间降序`timestamp`）的多个点。

# `report-disk`

## `cnosdb_inspect report`

使用`report-disk`命令查看指定目录下的`TSM`文件的`shards`和`measurements`的磁盘使用情况。

### `语法`

`cnosdb_inspect report-disk [ options ]`

### `选项`

可选参数在括号中

`[ --detailed]`

包括`flag`来报告`measurements`的磁盘使用情况。

# `report`

## `cnosdb_inspect report`

显示所有`shard`的系列元数据。默认位置是`$HOME/.cnosdb`。

### `语法`

`cnosdb_inspect report [ options ]`

### `选项`

可选参数在括号中

`[ --pattern "<regular expression/wildcard>"]`

匹配包含文件的正则表达式或通配符模式。默认值为`""`。

`[ --detailed]`

报告详细基数估计的标志。默认值为`false`。

`[ --exact]`

报告确切基数而不是估计值的标志。默认值为`false`。注意：这会占用大量内存。

# `reporttsi`

## `cnosdb_inspect reporttsi`

>计算数据库中的总精确`series`基数。
> 
>通过`measurements`分割`series`，并发出这些`series`值。
> 
>为数据库中的每个`shard`发出总的精确基数。
> 
>每个`shard`的`segment`是`shard`中每个`measurement`的确切基数。
> 
>可以选择将每个`shard`中的结果限制为“前 n 个”。

### `语法`

`cnosdb_inspect reporttsi --db-path <path-to-db> [ options ]`

### `选项`

可选参数在括号中

`-db-path <path-to-db>`

数据库的路径。

`[ -top <n>]`

将结果限制为每个`shard`中指定的数字。

# `verify`

## `cnosdb_inspect verify`

验证 `TSM`文件的完整性。

### `语法`

`cnosdb_inspect verify [ options ]`

### `选项`

可选参数在括号中

`--dir <storage_root>`
存储根目录的路径。默认值为"`/root/.cnosdb`".

# `verify-seriesfile`

## `cnosdb_inspect verify-seriesfile`

验证 `series`文件的完整性。

### `语法`

`cnosdb_inspect verify-series [ options ]`

### `选项`

可选参数在括号中

`[ --c <number>]`

指定要为此命令运行的并发工作人员的数量。默认值等于 GOMAXPROCS 的值。如果性能受到不利影响，您可以设置一个较低的值。

`[ --dir <path>]`

指定根数据路径。默认为`~/.cnosdb/data`.

`[ --db <db_name>]`

将验证系列文件限制为数据目录中的指定数据库。

`[ --series-file <path>]`

特定系列文件的路径；覆盖-`db`和`-dir`.

`[ --v]`

启用详细日志记录。

# `verify-tombstone`

## `cnosdb_inspect verify-tombstone`

验证 `tombstone`文件的完整性。

### `语法`

`cnosdb_inspect verify-tombstone [ options ]`

### `选项`

可选参数在括号中

`[ -dir <path>]`

指定根数据路径。默认为`~/.cnosdb/data`. 该路径可以是任意的，例如，它不需要是` CnosDB `数据目录。

`[ --v]`

启用详细日志记录。确认正在验证文件并每500万条`tombstone`条目显示进度。

`[ --vv]`

启用非常详细的日志记录。显示`tombstone`文件中每个`series key`和时间范围。自(1970-01-01T00:00:00Z)以来的时间戳以纳秒为单位显示。

`[ --vvv]`

启用非常非常详细的日志记录。显示`tombstone`文件中每个`series key`和时间范围。时间戳以`RFC3339`格式显示，精度为纳秒。

# `export`

## `cnosdb_inspect export`

以 `CnosDB` 线路协议数据格式导出所有 `TSM` 文件。为所有 `WAL` 文件写入数据`_internal/monitor`。可以使用`cnosdb`命令导入此输出文件。

### `语法`

`cnosdb_inspect export [ options ]`

### `选项`

可选参数在括号中

`[ --compress]`

使用 gzip 压缩来压缩输出的标志。默认值为`false`。

`[ --database <db_name>]`

要导出的数据库的名称。默认值为`""`.

`--datadir <data_dir>`

目录的路径`data`。默认值为"`$HOME/.cnosdb/data`"。

`[ --end <timestamp>]`

时间范围结束的时间戳。必须是`RFC3339 `格式。

RFC3339 需要非常具体的格式。例如，要指示没有时区偏移 (UTC+0)，您必须在秒后包含 Z 或 +00:00。有效 RFC3339 格式的示例包括：

#### `无偏移`

> YYYY-MM-DDTHH:MM:SS+00:00
>
>YYYY-MM-DDTHH:MM:SSZ
>
>YYYY-MM-DDTHH:MM:SS.nnnnnnZ (fractional seconds (.nnnnnn) are optional)

#### `带偏移`

> YYYY-MM-DDTHH:MM:SS-08:00
>
>YYYY-MM-DDTHH:MM:SS+07:00

`[ --out <export_dir>]`
导出文件的位置。默认值为"`$HOME/.cnosdb/export`"。

`[ --retention <rp_name> ]`
要导出的保留策略的名称。默认值为`""`。

`[ --start <timestamp>]`
时间范围开始的时间戳。时间戳字符串必须采用`RFC3339 `格式。

`[ --waldir <wal_dir>]`
`WAL`目录的路径。默认值为"`$HOME/.cnosdb/wal`"。

### `例子`

导出所有数据库并压缩输出

`cnosdb_inspect export --compress`

从特定数据库和保留策略中导出数据

`cnosdb_inspect export --database mydb -retention autogen`

输出文件

```#DDL
CREATE DATABASE MY_DB_NAME

CREATE RETENTION POLICY autogen ON MY_DB_NAME DURATION inf REPLICATION 1

# DML

# CONTEXT-DATABASE:MY_DB_NAME

# CONTEXT-RETENTION-POLICY:autogen

randset value=97.9296104805 1439856000000000000

randset value=25.3849066842 1439856100000000000
