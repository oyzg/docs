### 数据库管理

#### 创建数据库

  **语法**

  ```sql
  CREATE DATABASE <database_name> [WITH [DURATION <duration>] [REPLICATION <n>] [SHARD DURATION <duration>] [NAME <rp-name>]]
  ```

  **语法描述**

  `CREATE DATABASE`需要一个数据库名称，其他都为可选项。如果未在`WITH`后面指定保留策略，则会创建一个默认的保留策略，名称为`autogen`。

  `DURATION`保留策略的总窗口时长。

  `REPLICATION`副本数量，默认为`1`并且只能为`1`。

  `SHARD DURATION`分片的窗口时长。

  `NAME`指定保留策略名称。

  `CREATE DATABASE`成功执行后不会返回任何结果。

  **示例**

  创建数据库

  > 创建一个名为`cnos`的数据库，CnosDB还会在其下创建一个名为`autogen`的保留策略。

  ```sql
   CREATE DATABASE "cnos"
  ```

  创建数据库并指定保留策略

  > 创建一个名为`cnos`的数据库，并指定保留策略为`1d_events`，它的生命周期为总保留时长为一天，副本数为1，每个分片的的窗口长度为一小时。

  ```sql
  > CREATE DATABASE "cnos" WITH DURATION 1d REPLICATION 1 SHARD DURATION 1h NAME "1d_events"
  ```

#### 显示数据库

  **语法**

  ```
  SHOW DATABASES
  ```

#### 删除数据库

  **语法**

  ```sql
  DROP DATABASE <database_name>
  ```

  **语法描述**

  `DROP DATABASE`会删除数据库下所有数据。

  **示例**

  ```sql
  DROP DATABASE "cnos"
  ```

### 保留策略管理

#### 创建保留策略

  **语法**

  ```sql
  CREATE RETENTION POLICY <rp_name> ON <database_name> DURATION <duration> REPLICATION <n> [SHARD DURATION <duration>] [DEFAULT]
  ```

  **描述**

  `DURATION`保留策略的总窗口时长。

  `REPLICATION`副本数量，默认为`1`并且只能为`1`。

  `SHARD DURATION`分片的窗口时长。

  `DEFAULT`可选项，指定其是否为默认保留策略

  **示例**

  创建保留策略

  > 该语句创建了一个名为`1d_events`的保留策略，并且副本数为1

  ```sql
  > CREATE RETENTION POLICY "1d_events" ON "cnos" DURATION 1d REPLICATION 1
  >
  ```

  创建默认保留策略

  ```sql
  > CREATE RETENTION POLICY "1d_events" ON "cnos" DURATION 23h60m REPLICATION 1 DEFAULT
  >
  ```

#### 显示保留策略

  **语法**

    ```sql
    SHOW RETENTION POLICIES [ON <database_name>]
    ```

  **示例**

    ```sql
    > SHOW RETENTION POLICIES ON "cnos"
    
    name      duration   shardGroupDuration   replicaN   default
    ----      --------   ------------------   --------   -------
    autogen   0s         168h0m0s             1          true
    ```

#### 修改保留策略

  **语法**

  ```sql
  ALTER RETENTION POLICY <rp_name> ON <database_name> DURATION <duration> REPLICATION <n> SHARD DURATION <duration> DEFAULT
  ```

  **示例**

  ```sql
  ALTER RETENTION POLICY "1d_events" ON "cnos" DURATION 7 SHARD DURATION 1d DEFAULT
  ```

#### 删除保留策略

  **语法**

  ```sql
  DROP RETENTION POLICY <rp_name> ON <database_name>
  ```

  **示例**

  ```sql
  > DROP RETENTION POLICY "1d_events" ON "cnos"
  >
  ```

