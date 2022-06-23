# 用户权限管理

## 身份认证

Cnosdb包含基于用户凭据的简单内置身份认证，在Cnosdb中默认不开启身份认证。

### 开启身份认证

1. 创建一个或多个管理员用户，具体创建方法请参考[用户管理命令](#用户管理命令)

2. 在配置文件中设置开启身份认证
    ```
    [HTTPD]
      enabled = true
      bind-address = ":8086"
      auth-enabled = true # 将此处设置为true
      log-enabled = true
      suppress-write-log = false
      write-tracing = false
      pprof-enabled = true
      debug-pprof-enabled = true
      https-enabled = false
      https-certificate = "/etc/ssl/cnosdb.pem"
    ```

3. 重新启动Cnosdb

### 请求验证

#### 在Cnosbd API中进行身份认证

- 使用基本身份认证进行身份认证
  ```
  curl -G http://localhost:8086/query \
  -u admin:admin \
  --data-urlencode "q=SHOW DATABASES"
  ```

- 使用URL的查询参数进行身份认证
  ```
  curl -G "http://localhost:8086/query?u=admin&p=admin" \
  --data-urlencode "q=SHOW DATABASES"
  ```

- 使用请求体中的查询参数进行身份认证
  ```
  curl -G http://localhost:8086/query \
  --data-urlencode "u=admin" \
  --data-urlencode "p=admin" \
  --data-urlencode "q=SHOW DATABASES"
  ```

#### 在Cnosdb CLI中进行身份认证

- 在Cnosdb shell中使用auth命令进行身份认证
  ```
  % cnosdb-cli
  CnosDB shell version: vunknown
  > auth
  username: admin
  password:
  >
  ```

- 使用-u和-p为Cnosdb CLI提供身份认证凭据
  ```
  % cnosdb-cli -u admin -p admin
  CnosDB shell version: vunknown
  >
  ```

- 使用环境变量为Cnosdb CLI提供身份认证凭据
  ```
  # 配置环境变量
  export INFLUX_USERNAME=admin
  export INFLUX_PASSWORD=admin
  # 验证环境变量是否配置成功
  echo $INFLUX_USERNAME $INFLUX_PASSWORD
  admin admin

  % cnosdb-cli
  CnosDB shell version: vunknown
  >
  ```

- 使用JWT令牌进行身份认证
  
  使用JWT令牌是比密码更安全的认证方法，需要与Cnosdb API配合使用
  
  1. 添加一个共享密钥到Cnosdb的配置文件中
     ```
     [HTTPD]
       shared-secret = "my shard secret"
     ```
    
  2. 生成你的JWT令牌
  
     使用你的Cnosdb的用户名、密码、过期时间生成一个JWT令牌，一些在线工具可以帮助你，比如[https://jwt.io/](https://jwt.io/)。
  
     令牌的payload必须是下面这种格式的：
     ```
     {
       "username": "myUserName", #你的用户名
       "exp": 1516239022 #Unix格式的过期时间
     } 
     ```
     为了密码的安全性，请不要将过期时间设置得过长
     
     生成的令牌格式：`<header>.<payload>.<signature>`

  3. 在HTTP请求中将生成的令牌作为Authorization的一部分，使用Bearer方案：
      ```
      Authorization: Bearer <myToken>
      ```
     
     示例：
     ```
     curl -G "http://localhost:8086/query?db=cnosdb" \
     --data-urlencode "q=SHOW DATABASES" \
     --header "Authorization: Bearer <header>.<payload>.<signature>"
     ```
  
- 对Telegraf到Cnosdb的qing请求进行身份认证
    
  对Telegraf到Cnosdb的请求需要一些额外的步骤：在Telegraf的配置文件（/etc/telegraf/telegraf.conf），取消注释并编辑username和password。
  ```
  [[outputs.influxdb]]
    # ...
    username = "myUsername"
    password = "myPassword"
  ```

## 授权

### 用户类型和权限

#### 管理员用户
    
管理员用户拥有对所有数据库的读写权限，其管理权限包括：

- 数据库管理
    - CREATE DATABASE
    - DROP DATABASE
    - DROP SERIES
    - DROP MEASUREMENT
    - CREATE RETENTION POLICY
    - ALTER RETENTION POLICY
    - DROP RETENTION POLICY
    - CREATE CONTINUOUS QUERY
    - DROP CONTINUOUS QUERY

- 用户管理 
  - 管理用户管理 
    - CREATE USER
    - GRANT ALL PRIVILEGES
    - REVOKE ALL PRIVILEGES
    - SHOW USERS
  - 非管理员用户管理：
    - CREATE USER
    - GRANT [READ,WRITE,ALL]
    - REVOKE [READ,WRITE,ALL]
  - 一般用户管理：
    - SET PASSWORD
    - DROP USER

#### 普通用户

管理员用户可以赋予普通用户一下三种权限：

- READ
- WRITE
- ALL（READ和WRITE访问）

在管理员用户为普通用户赋予权限之前，普通用户无权访问任何数据库

### 用户管理命令

当开启身份认证后，必须至少拥有一名管理员用户才能与系统进行交互

- 创建管理员
  ```
  CREATE USER <username> WITH PASSWORD '<password>' WITH ALL PRIVILEGES
  ```
  
- 赋予现有用户管理员权限
  ```
  GRANT ALL PRIVILEGES TO <username>
  ```

- 移除某个管理员用户的管理权限
  ```
  REVOKE ALL PRIVILEGES FROM <username>
  ```

- 查看现有用户及管理员状态
  ```
  SHOW USERS
  ```

- 创建一个非管理员用户
  ```
  CREATE USER <username> WITH PASSWORD '<password>'
  ```
  
- 赋予用户对某个数据库的权限
  ```
  GRANT [READ,WRITE,ALL] ON <database_name> TO <username>
  ```
  
- 移除用户对某个数据库的权限
  ```
  REVOKE [READ,WRITE,ALL] ON <database_name> FROM <username>
  ```

- 查看某个用户的数据库权限
  ```
  SHOW GRANTS FOR <user_name>
  ```

- 设置某个用户的密码
  ```
  SET PASSWORD FOR <username> = '<password>'
  ```

- 删除一个用户
  ```
  DROP USER <username>
  ```

## 提示
- 用户名如果包含特殊字符，如!@#$%^&*()-等，或以数字开头，请用双引号包裹。
- 密码请用单引号包裹，且避免在密码中包含单引号或者反斜杠`\`，如果包含，请用反斜杠`\`进行转义
- `CREATE USER`命令是幂等的，可以多次执行相同的语句，如果不同则会报错
- 认证失败的响应码为`HTTP 401 Unauthorized`
- 没有进行身份认证的响应码为`HTTP 403 Forbidden`