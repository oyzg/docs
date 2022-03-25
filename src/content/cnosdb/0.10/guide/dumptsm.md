# `cnosdb_inspect dumptsm`

## `Ways to run`

### `cnosdb_inspect dumptsm`

转储tsm1文件的底层细节，包括TSM文件和WAL文件

#### `语法`

`cnosdb_inspect dumptsm [ options ] <path>`

`<path>`

文件的路径`.tsm`，默认位于`data`目录中。

`Options`

可选参数在括号中

`[ -index ]`


用于转储原始索引数据的标志。默认值为`false`。

`[ -blocks ]`

转储原始块数据的标志。默认值为`false`。

`[ -all ]`

标志转储所有数据。注意：这可能会打印很多信息。默认值为`false`。

`[ -filter-key <key_name> ]`

仅显示与此键子字符串匹配的索引数据和块数据。默认值为`""`。



