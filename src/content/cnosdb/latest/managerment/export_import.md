# 导入和导出

## 导入

```
cnosdb-cli import --path <path> [arguments]
```

### 参数用法

|          Flag |                         Description                          |
|--------------| :----------------------------------------------------------: |
|  --compressed |             假如导入文件是被压缩的，需设置此值。             |
| --consistency | 写入并发等级："any"，"one"，"quorum"，或者"all"（默认"all"）。 |
|        --host |                 主机地址（默认localhost）。                  |
|    --password |             登录服务器的密码（默认为空字符串）。             |
|        --path |                       导入文件的路径。                       |
|        --port |                    主机端口，默认为8086。                    |
|         --pps |     允许每秒钟导入多少points，默认为0，不限制导入速度。      |
|         --ssl |                     使用https连接集群。                      |
|    --username |                     登录服务器的用户名。                     |

### 示例
将`./import/in.txt`导入到cnosdb中
```
>cnosdb-cli import --path ./import/in.txt
2022/05/18 18:42:15 Processed 100000 lines.  Time elapsed: 586.1847ms.  Points per second (PPS): 170594
2022/05/18 18:42:16 Processed 200000 lines.  Time elapsed: 1.1997508s.  Points per second (PPS): 166701
2022/05/18 18:42:16 Processed 2 commands
2022/05/18 18:42:16 Processed 200000 inserts
2022/05/18 18:42:16 Failed 0 inserts
```

## 导出

```
cnosdb-inspect export [arguments]
```

### 参数用法

|      Flags |                       Description                        |
|-----------| :------------------------------------------------------: |
| --compress |                      压缩导出文件。                      |
| --database |               可选：指定需要导出的数据库。               |
|  --datadir |                    指定数据存储路径。                    |
|      --end |       可选：导出数据的最小时间戳(RFC3339 format)。       |
|      --out |       指定导出文件的路径(默认"/.cnosdb/export")。        |
|       --rp | 可选：指定导出的retention policy（需要--database参数）。 |
|    --start |     可选：导出数据数据的最大时间戳(RFC3339 format)。     |
|   --waldir |                    指定WAL存储路径。                     |

### 示例
导出数据到`./.cnosdb/export/out.txt`
```
>cnosdb-inspect export --out ./.cnosdb/export/out.txt
writing out tsm file data for db\rp...complete.
writing out tsm file data for mydb\rp...complete.
```