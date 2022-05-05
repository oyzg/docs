# 快速入门

```sql
> CREATE DATABASE oceanic_station
>
> use oceanic_station
Using database oceanic_station
Using rp autogen
> 
> insert test_air,station=XiaoMaiDao visibility=68,temperature=79,pressure=75 
> insert test_air,station=LianYunGang visibility=71,temperature=63,pressure=78
> insert test_air,station=LianYunGang visibility=71,temperature=63,pressure=79
> insert test_air,station=LianYunGang visibility=71,temperature=53,pressure=79
> insert test_air,station=LianYunGang visibility=71,temperature=63,pressure=90
> insert test_air,station=XiaoMaiDao visibility=78,temperature=79,pressure=75 
> insert test_air,station=XiaoMaiDao visibility=78,temperature=77,pressure=75 
> 
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
- 创建数据库： CREATE DATABASE oceanic_station
- 使用数据库： use oceanic_station
- 写入数据： INSERT
- 查询数据：SELECT