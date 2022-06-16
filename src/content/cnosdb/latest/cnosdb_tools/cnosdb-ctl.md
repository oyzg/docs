# cnosdb_ctl

CnosDB ctl 是一个集群管理工具，可用于：
- 复制备份数据。
- 维护集群的平衡状态。
- 管理集群中的节点。

**语法**

```
cnosdb_ctl [ [ command ] [ options ] ]
```

**全局参数**

`[ --bind string]`

指定要连接的元节点地址，默认为`127.0.0.1:8091`

**命令**

- [add-data](#add-data)
- [add-meta](#add-meta)
- [copy-shard](#copy-shard)
- [kill-copy-shard](#kill-copy-shard)
- [print-meta](#print-meta)
- [remove-data](#remove-data)
- [remove-meta](#remove-meta)
- [show](#show)
- [truncate-shards](#truncate-shards)
- [update-data](#update-data)
- [replace-data](#replace-data)
- [version](#version)

## `add-data`

### `cnosdb_ctl add-data`

添加一个数据节点到集群中

### 语法

```
cnosdb_ctl --bind <meta-node> add-data <data-node>
```

### 例子

添加一个数据节点`localhost:8088`到集群中

```
./cnosdb_ctl --bind localhost:8091 add-data localhost:8088
```

## `add-meta`

### `cnosdb_ctl add-meta`

添加一个元节点到集群中

### 语法

`cnosdb_ctl --bind <meta-node> add-meta <meta-node>`

### 例子

添加一个元节点`localhost:8091`到集群中

```
./cnosdb_ctl --bind localhost:8091 add-meta localhost:8091
```

## `copy-shard`

### `cnosdb_ctl copy-shard`

从源数据节点拷贝指定shard到目标数据节点

### 语法

`cnosdb_ctl --bind <meta-node> copy-shard <source-data-node> <dest-data-node> <shard-id>`

### 例子

从`127.0.0.1:8088`拷贝id为`1234`的shard到`127.0.0.2:8088`

```
./cnosdb_ctl --bind localhost:8091 copy-shard 127.0.0.1:8088 127.0.0.2:8088 1234
```

## `kill-copy-shard`

### `cnosdb_ctl kill-copy-shard`

中止正在进行的`copy-shard`命令

### 语法

```
cnosdb-ctl --bind <meta-node> kill-copy-shard <source-data-node> <dest-data-node> <shard-id>
```

### 例子

中止正在进行的从`127.0.0.1:8088`拷贝id为`1234`的shard到`127.0.0.2:8088`的命令

```
./cnosdb_ctl --bind localhost:8091 kill-copy-shard 127.0.0.1:8088 127.0.0.2:8088 1234
```

## `print-meta`

### `cnosdb_ctl print-meta`

使用`print-meta`命令查看cnosdb集群的元数据信息

### 语法

```
cnosdb_ctl --bind <meta-node> print-meta
```

## `remove-data`

### `cnosdb_ctl remove-data`

从集群中删除一个数据节点

### 语法

`cnosdb_ctl --bind <meta-node> remove-data <data-node>`

### 例子

从集群中删除一个数据节点`localhost:8088`

```
./cnosdb_ctl --bind localhost:8091 remove-data localhost:8088
```

## `remove-meta`

### `cnosdb_ctl remove-meta`

从集群中删除一个元节点

### 语法

`cnosdb_ctl --bind <meta-node> remove-meta <meta-node>`

### 例子

从集群中删除一个元节点`localhost:8091`

```
./cnosdb_ctl --bind localhost:8091 remove-meta localhost:8091
```

## `remove-shard`

### `cnosdb_ctl remove-shard`

从一个数据节点删除指定的shard

### 语法

`cnosdb_ctl --bind <meta-node> remove-shard <data-node> <shard-id>`

### 例子

删除数据节点`127.0.0.1:8088`中id为`1234`的shard

```
./cnosdb_ctl --bind localhost:8091 remove-shard 127.0.0.1:8088 1234
```

## `show`

### `cnosdb_ctl show`

查看集群中的所有数据节点和元节点

### 语法

`cnosdb_ctl --bind <meta-node> show`

## `truncate-shards`

### `cnosdb_ctl truncate-shards`

截断hot shard，并创建一个新的shard，所有新数据都将写入这个shard

### 语法

`cnosdb_ctl --bind <meta-node> truncate-shards <data-node> [<delay-minutes>]`

### 选项

可选参数在括号中

`[<delay-minutes>]`

指定`now()`后多久开始截断shard，默认为1，单位为分钟。

### 例子

5分钟后截断分片

```
./cnosdb_ctl --bind localhost:8091 truncate-shards 127.0.0.1:8088 5
```


## `update-data`

### `cnosdb_ctl update-data`

用于节点故障情况下的节点地址更新，命令会将新节点加入集群并更新节点ID对于的地址。

注意：发生节点故障时，需先使用copy-shard命令完成数据拷贝，再使用update-date命令完成节点信息更新。

### 语法

`cnosdb_ctl --bind <meta-node> update-data <old-data-node> <new-data-node>`

### 例子

使用新的数据节点`127.0.0.2:8088`代替旧的数据节点`127.0.0.1:8088`

```
./cnosdb_ctl --bind localhost:8091 update-data 127.0.0.1:8088 127.0.0.2:8088
```

## `replace-data`

### `cnosdb_ctl replace-data`

用于存活节点之间的替换，用一个新的数据节点代替旧的数据节点，会自动将原节点数据拷贝至新节点，将新节点加入集群并更新节点ID对应的地址。

### 语法

`cnosdb_ctl --bind <meta-node> replace-data <old-data-node> <new-data-node>`

### 例子

使用新的数据节点`127.0.0.2:8088`代替旧的数据节点`127.0.0.1:8088`

```
./cnosdb_ctl --bind localhost:8091 replace-data 127.0.0.1:8088 127.0.0.2:8088
```


## `version`

### `cnosdb_ctl version`

查看当前cnosdb meta的版本

### 语法

`cnosdb_ctl --bind <meta-node> version`
