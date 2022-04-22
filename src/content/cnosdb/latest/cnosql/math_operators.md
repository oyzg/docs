## CnosQL 数学运算符

- ### [数学运算符](#数学运算符)
    - #### [加法](#加法)
    - #### [减法](#减法)
    - #### [乘法](#乘法)
    - #### [除法](#除法)
    - #### [模运算](#模运算)
    - #### [位与运算](#位与运算)
    - #### [位或运算](#位或运算)
    - #### [位异运算](#位异运算)
    - #### [常见问题](#常见问题)

- ### [不支持的运算符](#不支持的运算符)

- ### 数学运算符

    - #### 加法

  常量的加法

  ```
  SELECT "temperature" + 5 FROM "air"
  SELECT * FROM "air" WHERE "temperature" + 5 > 10
  ```

  两字段的加法

  ```
  SELECT "temperature" + "visibility" FROM "air"
  SELECT * FROM "air" WHERE "temperature" + "visibility" > 10
  ```

    - #### 减法

  常量的减法

  ```
  SELECT "temperature" - 2 FROM "air"
  SELECT * FROM "air" WHERE "temperature" - 2 > 12
  ```

  两字段的减法

  ```
  SELECT "temperature" - "visibility" FROM "air"
  SELECT * FROM "air" WHERE "temperature" - "visibility" > 10
  ```  

    - #### 乘法

  常量的乘法

  ```
  SELECT "temperature" * 2 FROM "air"
  SELECT * FROM "air" WHERE "temperature" - 2 > 12
  ```

  两字段的减法

  ```
  SELECT "temperature" * "visibility" FROM "air"
  SELECT * FROM "air" WHERE "temperature" * "visibility" > 10
  ```  

  乘法和其他操作符并用

  ```
  SELECT 10 * ("temperature" + "visibility" + "pressure") FROM "air"
  SELECT 10 * ("temperature" + "visibility" - "pressure") FROM "air"
  SELECT 10 * ("temperature" - "visibility" - "pressure") FROM "air"
  ```

    - #### 除法

  常量的除法

  ```
  SELECT 10 / "temperature" FROM "air"
  SELECT * FROM "air" WHERE 10 / "temperature" > 12
  ```

  两字段的减法

  ```
  SELECT "temperature" / "visibility" FROM "air"
  SELECT * FROM "air" WHERE "temperature" / "visibility" > 10
  ```  

  乘法和其他操作符并用

  ```
  SELECT 10 / ("temperature" + "visibility" + "pressure") FROM "air"
  SELECT 10 / ("temperature" + "visibility" - "pressure") FROM "air"
  SELECT 10 / ("temperature" - "visibility" - "pressure") FROM "air"
  ```

    - #### 模运算

  常量的模运算

  ```
  SELECT 10 % "temperature" FROM "air"
  SELECT * FROM "air" WHERE 10 % "temperature" = 0
  ```

  两字段的模运算

  ```
  SELECT "temperature" % "visibility" FROM "air"
  SELECT * FROM "air" WHERE "temperature" % "visibility" = 0
  ```  

    - #### 按位与运算

  您可以对任何整数或布尔值使用此操作符，无论它们是字段还是常量。它不适用于浮点或字符串数据类型，并且不能混合整数和布尔值使用。

  ```
  SELECT "temperature" & 255 FROM "air"
  SELECT "temperature" & "pressure" FROM "air"
  SELECT * FROM "air" WHERE "temperature" & 15 > 0
  SELECT "temperature" & "pressure" FROM "air"
  SELECT ("temperature" ^ true) & "pressure" FROM "air"
  ```

    - #### 按位或运算

  您可以对任何整数或布尔值使用此操作符，无论它们是字段还是常量。它不适用于浮点或字符串数据类型，并且不能混合整数和布尔值使用。

  ```
  SELECT "temperature" | 255 FROM "air"
  SELECT "temperature" | "pressure" FROM "air"
  SELECT * FROM "air" WHERE "temperature" | 12 = 12
  ```
    - #### 按位异运算

  您可以对任何整数或布尔值使用此操作符，无论它们是字段还是常量。它不适用于浮点或字符串数据类型，并且不能混合整数和布尔值使用。

  ```
  SELECT "temperature" ^ 255 FROM "air"
  SELECT "temperature" ^ "pressure" FROM "air"
  SELECT * FROM "air" WHERE "temperature" ^ 12 = 12
  ``` 

    - #### 常见问题

        - #### 带有通配符和正则表达式的数学操作符

      CnosDB不支持在SELECT子句中组合数学操作与通配符(*)或正则表达式。以下查询无效，系统返回错误:
      对通配符执行数学运算。
      ```
      > SELECT * + 2 FROM "air"
      ERR: unsupported expression with wildcard: * + 2
      ```
      对函数中的通配符执行数学运算。
      ```
      > SELECT COUNT(*) / 2 FROM "nope"
      ERR: unsupported expression with wildcard: count(*) / 2
      ```   
      对正则表达式执行数学运算。
      ```
      > SELECT /A/ + 2 FROM "air"
      ERR: error parsing query: found +, expected FROM at line 1, char 12
      ```
      对函数中的正则表达式执行数学运算。
      ```
      > SELECT COUNT(/A/) + 2 FROM "nope"
      ERR: unsupported expression with regex field: count(/A/) + 2
      ```     

        - #### 函数的数学运算符

      目前不支持在函数调用中使用数学运算符。注意，CnosDB只允许SELECT子句中的函数。
      可行操作：
      ```
      SELECT 10 * mean("value") FROM "cpu"
      ```
      不可行操作：
      ```
      SELECT mean(10 * "value") FROM "cpu"
      ```
- ### 不支持的运算符

    - #### 比较运算

  所有的比较运算符都不支持。例如：`=`,`!=`,`<`,`>`,`<=`,`>=`,`<>`。在SELECT语句中均不可以使用。

    - #### 逻辑运算符

  使用逻辑运算符，如：`!|`, `NAND`,`XOR`,`NOR`；都会导致解析错误。

  此外，在查询的`SELECT`子句中使用`AND`和`OR`不会表现为数学运算符，只会产生空结果，因为它们在CnosQL中已经被定义。但是，您可以对布尔数据应用位操作符`&`、`|`和`^`。

    - #### 位非运算

  没有位非运算符，因为您期望的结果取决于您的位域的宽度。CnosQL不知道您的位域有多宽，因此无法实现合适的位非运算。

  您可以通过使用`^`(位异或)操作符和代表字宽的全1的二进制数字来实现位非操作:

  ```
  8-bit 数据：
  
  SELECT "temperature" ^ 255 FROM "air"
  
  16-bit 数据:
  
  SELECT "temperature" ^ 65535 FROM "air"
  
  32-bit 数据:
  
  SELECT "temperature" ^ 4294967295 FROM "air"
  ```