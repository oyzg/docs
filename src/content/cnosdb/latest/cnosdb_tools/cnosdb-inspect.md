- ### cnosdb_inspect

  CnosDB Inspect 是一个 CnosDB 磁盘实用程序，可用于：
    - 查看有关磁盘分片的详细信息。
    - 将数据从分片导出到可以插入回数据库的CnosDB 线路协议。
    - 将 TSM 索引分片转换为 TSI 索引分片。

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

- ### `deletetsm`

  #### `cnosdb_inspect deletetsm`

  批量从原始 `TSM` 文件中删除`measurement`数据

  #### 注意：仅当您的`CnosDB`离线（`CnosDB`服务未运行） 时才使用`deletetsm`。

  #### 语法

  ```
  cnosdb_inspect deletetsm --measurement <measurement_name> [ arguments ] <path>
  ```
  `<path>`

  文件的路径`.tsm`，默认位于`data`目录中。

  指定路径时，通配符 (`*`) 可以替换一个或多个字符。

  #### 选项

  可选参数在括号中

  `--measurement`

  要从 TSM 文件中删除的`measurement`的名称。

  `[ --sanitize]`

  标记以删除包含不可打印的 `Unicode `字符的所有键。

  `[--v]`

  标记以启用详细日志记录。

  #### 例子

  从单个`shard`中删除一个`measurement`

  ```
  ./cnosdb_inspect deletetsm --sanitize /cnosdb/data/location/autogen/1384/*.tsm
  ```

  从数据库中的所有`shard`中删除`measurement`

  ```
  ./cnosdb_inspect deletetsm --sanitize /cnosdb/data/location/autogen/*/*.tsm
  ```

- ### `dumptsm`

  #### `cnosdb_inspect dumptsm`

  转储`tsm1`文件的底层细节，包括`TSM`文件和`WAL`文件

  #### 语法

  `cnosdb_inspect dumptsm [ options ] <path>`

  `<path>`

  文件的路径`.tsm`，默认位于`data`目录中。

  #### 选项

  可选参数在括号中

  `[ --index ]`

  用于转储原始索引数据的标志。默认值为`false`。

  `[ --blocks ]`

  转储原始块数据的标志。默认值为`false`。

  `[ --all ]`

  标志转储所有数据。注意：这可能会打印很多信息。默认值为`false`。

  `[ --filter-key <key_name> ]`

  仅显示与此键子字符串匹配的索引数据和块数据。默认值为`""`。

- ### `dumptsi`

  #### `cnosdb_inspect dumptsi`

  转储有关`TSI`文件的底层信息，包括`.tsl`日志文件和`.tsi`文件

  #### 语法

  `cnosdb_inspect dumptsi [ options ] <index_path>`

  若未指定任何选项，则会为每个文件提供汇总信息。

  #### 选项

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

  #### 例子

  指定_series和index目录的路径

  `cnsodb_inspect dumptsi --series-file /path/to/db/_series /path/to/index`

  指定_series目录和index文件的路径

  `cnosdb_inspect dumptsi --series-file /path/to/db/_series /path/to/index/file0`

  指定_series目录和多个index文件的路径

  ```
  cnosdb_inspect dumptsi --series-file /path/to/db/_series /path/to/index/file0 /path/to/index/file1 ...