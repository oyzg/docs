# 运维管理

## 备份 `cnosdb backup`

从指定数据节点创建数据库快照，并保存到 PATH 对应目录。

```
cnosdb backup [flags] PATH
```

### 参数介绍

| Flag            | Description                                                  |
| --------------- | ------------------------------------------------------------ |
| `--host`        | 地址；可选；默认值为 127.0.0.1:8088 。                       |
| `--db`          | 数据库名称；可选；如果未指定则备份所有数据库。               |
| `--rp`          | 数据保留策略；可选；如果未指定则备份所有数据保留策略。       |
| `--shard`       | 分片编号；可选；如果需要使用该参数，则需要同时使用 `-rp` 参数。 |
| `--start`       | 备份中包含的数据的最小时间戳 (RFC3339 format) 。             |
| `--end`         | 备份中包含的数据的最大时间戳 (RFC3339 format) 。             |
| `--skip-errors` | 创建某分片的备份时，若发生错误，继续创建剩余分片的备份。     |

## 还原 `cnosdb restore`

从指定的备份目录中恢复数据和元数据。恢复开始时，服务将被关闭。

```
cnosdb restore [flags]
```

### 参数介绍

| Flag      | Description                                                  |
| --------- | ------------------------------------------------------------ |
| `--host`  | 地址；可选；默认值为 127.0.0.1:8088 。                       |
| `--db`    | 从备份数据中恢复的数据库名称。                               |
| `--newdb` | 创建新数据库以导入备份数据；可选；如果未指定，则使用 `--db <db_name>` 中指定的数据库名称。该参数指定的数据库名称在目标系统中不能重复。 |
| `--rp`    | 从备份数据中恢复的数据库保留策略名称；可选；如果需要使用该参数，则需要同时使用 `--db` 参数。 |
| `--newrp` | 将备份数据导入其他的数据保留策略；可选；如果未指定，则使用 `--rp` 中指定的数据保留策略名称。 |
| `--shard` | 从备份数据中恢复的分片编号；可选；如果需要使用该参数，则需要同时使用 `--db` 和 `--rp` 参数。 |



## 导出

```
cnosdb_inspect export [ options ]
```

此操作会产生一个`.TSM`文件

## 导入

```

'cnosdb-cli' import --path <path> (-compressed) [options]
```
