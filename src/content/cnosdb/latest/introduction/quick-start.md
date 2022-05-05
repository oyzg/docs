# 快速入门

## 创建数据库

```sql
> CREATE DATABASE oceanic_station
```
创一个名字为oceanic_station的数据库

## 使用数据库

```sql
> use oceanic_station
Using database oceanic_station
Using rp autogen
```
USE db-name后，后面所有操作都是在这个DB中进行

## 写入数据

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
Cnosdb通过insert语句写入数据

## 读取数据
```sql
> select * from test_air
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