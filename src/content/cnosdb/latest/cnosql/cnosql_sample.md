- ### 查询入门

  #### 查看所有 `measurements`

      SHOW MEASUREMENTS

  #### 计算`air`中`temperature`的数量

  `  SELECT COUNT("temperature") FROM air`

  #### 查看`air`中的前五个值

  `SELECT * FROM air LIMIT 5`

  #### 指定字段的标识符号
   ```
    SELECT "temperature"::field,"station"::tag,"visibility"::field FROM "air" limit 10
   ```
  #### 查看`measurement`的tag key

  ` SHOW TAG KEYS FROM air`

  #### 查看tag value

  ` SHOW TAG VALUES FROM air WITH KEY = "station"`

  #### 查看field key

  ` SHOW FIELD KEYS FROM air`

  #### 查看series

  `SHOW SERIES`

  #### 函数使用

  > [更多](https://www.cnosdb.com/content/cnosdb/0.10/cnosql/function.html)

  ` SELECT MEAN("temperature") FROM "air"`