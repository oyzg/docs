# 快速入门

如果您已经拥有了一个CnosDB实例（如果您还没有，请查看[下载和安装](./install.md)）。下面来学习一下CnosDB的查询语言CnosQL，CnosDB并不是传统意义上的SQL数据库，使用的是类SQL的CnosQL语言对数据库进行操作 ，同时CnosQL查询语言的简洁程度完全可以媲美标准SQL，以下是一些简单的描述，可以让您迅速学会CnosQL查询语言

## 启动实例

请查看[下载和安装](./install.md)

CnosDB包含两个重要的程序：`cnosdb`和`cnosdb-cli`
cnosdb是CnosDB的服务端程序，`cnosdb-cli`是CnosDB的命令行客户端。
使用`cnosdb-cli`连接CnosDB的服务端，可以执行以下命令：
```shell
$ cnosdb-cli
```
连接成功后会提示客户端的版本：
```shell
CnosDB shell version: vunknown
>
```


## 创建数据库

创建一个名称为`oceanic_station`的数据库
```sql
> CREATE DATABASE oceanic_station
```
创建一个数据库oceanic_station
创建成功后，并不会返回任何结果，不过不必担心，没有结果才是最好的结果，您已经成功创建了数据库

可以使用`SHOW DATABASES`来进行查看：
```shell
SHOW DATABASES
```
返回的结果如下：
```
name: databases
name
----
oceanic_station
```
`oceanic_station`就是刚刚创建的数据库

## 使用数据库

`USE <db-name>`后，后面所有操作都是在这个DB中进行
```sql
> use oceanic_station
```
成功会返回如下提示：
```
Using database oceanic_station
Using rp autogen
```

## 写入数据

CnosDB通过insert语句写入数据，现在向数据库中写入一条语句，数据的格式必须符合`line protocol`格式

```sql
> insert test_air,station=XiaoMaiDao visibility=68,temperature=79,pressure=75 
> insert test_air,station=LianYunGang visibility=71,temperature=63,pressure=78
> insert test_air,station=LianYunGang visibility=71,temperature=63,pressure=79
> insert test_air,station=LianYunGang visibility=71,temperature=53,pressure=79
> insert test_air,station=LianYunGang visibility=71,temperature=63,pressure=90
> insert test_air,station=XiaoMaiDao visibility=78,temperature=79,pressure=75 
> insert test_air,station=XiaoMaiDao visibility=78,temperature=77,pressure=75 
> 
```
CnosDB中的数据预先是不需要建立Schema的，`test_air`会自动变成`measurement`，具体的定义请查看[CnosDB Line Protocol](../protocol/line_protocol.md)
我们新建了test_air这个measurement，并插入了7条数据，每条数据包含1个tag，3个field

## 查询数据

查询表中的所有数据，和SQL的语法是一样的
``` sql
> select * from test_air
```
返回结果如下：
```
name: test_air
time                        pressure station     temperature visibility
----                        -------- -------     ----------- ----------
2022-05-05T06:55:24.596027Z 75       XiaoMaiDao  79          68
2022-05-05T06:55:24.698504Z 78       LianYunGang 63          71
2022-05-05T06:55:24.735811Z 79       LianYunGang 63          71
2022-05-05T06:55:24.757501Z 79       LianYunGang 53          71
2022-05-05T06:55:24.777992Z 90       LianYunGang 63          71
2022-05-05T06:55:24.798981Z 75       XiaoMaiDao  79          78
2022-05-05T06:55:24.818872Z 75       XiaoMaiDao  77          78
```
此处可以查询到7条数据，其中time为时间戳，station为tag，其他3列为field

查询某一个字段，并对其进行聚合计算

```
> select count(temperature) from test_air
```
返回结果如下：
```
name: test_air
time                 count
----                 -----
1970-01-01T00:00:00Z 7
>
```

如果您完成了以上内容，恭喜您已经初步掌握了CnosDB和CnosQL的使用

但是CnosQL和标准SQL还是有一些不同的

比如我们通常把SQL语言分为DQL，DML，DDL，DCL，但是这在CnosQL中是不一样的
1. DQL，这在CnosQL中对应的模块是[数据查询](../cnosql/cnosql_queries.md)，但CnosQL中还有一些其他的查询如[数据库管理和模式查询](../cnosql/cnosql_management.md)中`SHOW`关键词的使用
2. DML，首先CnosQL是不支持UPDATE的，`time`和`tag set`相同的数据将覆盖，INSERT我们在[写入数据](#写入数据)的时候已经演示过了，对于删除，我们只支持大片数据的删除，您可以查看[数据库管理和模式查询](../cnosql/cnosql_management.md)中的`DROP`和`DELETE`语句
3. DDL，因为CnosDB是无模式的数据库，数据不需要提前定义，所以不支持数据定义语言
4. DCL，CnosDB支持`GRANT`关键字，可以对用户授于数据的访问权限，但这是测试性功能，计划在未来对用户开放