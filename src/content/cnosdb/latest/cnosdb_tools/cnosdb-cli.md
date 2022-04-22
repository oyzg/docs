- ### **cnosdb-cli**

  启动交互式命令行程序并连接 `cnosdb` 服务，以实现数据的写入、查询。

  ```
  cnosdb-cli [flags]
  ```

  #### 参数介绍

| Flag          | Description                                                  |
| ------------- | ------------------------------------------------------------ |
| `--host`      | 连接的 cnosdb HTTP 协议地址 (default: `http://localhost:8086`) |
| `--port`      | 连接的 cnosdb 的端口号                                       |
| `--password`  | 连接服务时使用的密码                                         |
| `--username`  | 连接服务时使用的用户名                                       |
| `--ssl`       | 连接时使用 HTTPS 协议                                        |
| `--format`    | 指定打印 cnosdb 服务的响应内容的格式: json, csv, or column   |
| `--precision` | 指定时间戳的格式: rfc3339, h, m, s, ms, u or ns              |