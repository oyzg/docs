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

## PgSQL、MySQL数据导入
PostgreSQL、MySQL存量数据导入CnosDB。首先分别通过mysqldump、pg_dumpall工具导出存量数据，然后使用cnosdb-cli import命令导入CnosDB， path参数指定为导出的dump数据文件。 跟上面的数据导入相比多两个参数：--sqldump --config，其他用法同上面。

```
cnosdb-cli import --path <path> --sqldump --config <config.toml> [arguments]
```

### 参数用法
cnosdb-cli import命令支持的参数在此都支持，除此之外还需要两个必备参数。

|          Flag |             Description                          |
|-----------| :----------------------------------------------------------: |
| --sqldump |标识此import文件为mysqldump、pg_dumpall导出的数据文件   |
| --config   | 数据导入配置文件 |

### 数据导入配置文件
```
[Tables]
[Tables.1]
TableName = "db*/*ex_tbl*" # 支持前缀后缀通配符，Ex: *abc, abc*, *abc*, *
Measurement = "cndb/*" # 含有*时会使用sql中原生数据库、表名值
SqlFields = [
                ["ex_id","ex_title","ex_author","submission_date","ts"], # sql字段名字，顺序要与dump后字段值一致
                ["id","title","author","","ts"], # cnosdb字段名字,如果不需要存储用空字符串替代
                [3,3,2,0,1],      # 1: 时间戳, 2: tag; 3: field; 其他都是无效值
            ]
```
配置文件说明：
1. 配置文件格式为toml。
2. TableName：是SQL数据库中需要导入的数据库、表名字，支持前后缀通配符。比如db/*: 数据库名字为db的所有表导入CnosDB。
3. Measurement：对应CnosDB中数据库、Measurement名字，比如cndb/dev：将符合TableName过滤规则的数据导入cndb数据库下的dev这个Measurement；又比如 */dev：将符合TableName过滤规则的数据分别导入对应数据库下的dev这个Measurement
4. SqlFields是一个数组，对应sql字段相关配置。第一行对应sql中字段名字，顺序要求与dump出的数据顺序一致；第二行分别对应导入到CnosDB后名字，如果某些字段不需要导入Cnosdb可以配置“”，第三行是用于标识字段用途，1、2、3分别标识时间戳、tag、field，对应字段不需要导入CnosDB可以配置为0

### 示例
将mysqldump导出的数据文件mysqldump.sql导入到cnosdb中，导入配置采用config.toml
```
cnosdb-cli import --sqldump --config ./config.toml --path ./mysqldump.sql 
```