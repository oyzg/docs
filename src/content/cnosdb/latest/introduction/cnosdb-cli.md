# cnosdb-cli

> 使用cnosdb-cli交互式命令行工具操作CnosDB。

- [开始使用cnosdb-cli](#开始cnosdb-cli)
- [cnosdb-cli参数](#cnosdb-cli参数)
- [cnosdb-cli命令](#cnosdb-cli命令)

## 开始使用cnosdb-cli

如果使用cnosdb-cli，则需要先启动cnosdb进程，然后在终端启动cnosdb-cli，如果成功连接，您将看到以下输出：

```
$ cnosdb-cli
CnosDB shell version: v1.0.1
>
```

您可以在终端输入`help`命令，查询有效的命令。CnosQL的语法请查看[语法参考手册](../cnosql/index.md)

## cnosdb-cli参数
|Flag	|Description|
|-------|-----------|
|--host	|连接的 cnosdb HTTP 协议地址 (default: http://localhost:8086)|
|--port	|连接的 cnosdb 的端口号|
|--password	|连接服务时使用的密码|
|--username	|连接服务时使用的用户名|
|--ssl	|连接时使用 HTTPS 协议|
|--format	|指定打印 cnosdb 服务的响应内容的格式: json, csv, or column|
|--precision	|指定时间戳的格式: rfc3339, h, m, s, ms, u or ns|