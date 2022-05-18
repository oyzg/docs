# 快速入门

## 创建数据库

```sql
> CREATE DATABASE oceanic_station
```
创一个名字为oceanic_station的数据库

## 使用数据库

```sql
> use oceanic_station
```
```
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
``` sql
> select * from test_air
```
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

## HTTP接口操作数据

### 创建数据库
``` http
> curl -i -XPOST http://localhost:8086/query --data-urlencode "q=CREATE DATABASE mydb"
```
```
HTTP/1.1 200 OK
Content-Type: application/json
X-Cnosdb-Version: 0.0.0
X-Request-Id: 906d1130-cd0f-11ec-8002-6ada2a120bb2
Date: Fri, 06 May 2022 07:38:47 GMT
Transfer-Encoding: chunked

{"results":[{"statement_id":0}]}                                                                                                                              
```

### 写入数据
``` http

> curl -i -XPOST 'http://localhost:8086/write?db=mydb' --data-binary 'cpu,host=server01,region=Beijing idle=0.72' 
```
```
HTTP/1.1 204 No Content
Content-Type: application/json
X-Cnosdb-Version: 0.0.0
X-Request-Id: ade613b0-cd0f-11ec-8004-6ada2a120bb2
Date: Fri, 06 May 2022 07:39:37 GMT
```

### 查询数据

``` http

> curl -G 'http://localhost:8086/query?pretty=true' --data-urlencode "db=mydb" --data-urlencode "q=SELECT \"idle\" FROM \"cpu\" WHERE \"region\"='Beijing'"
```
```
{
    "results": [
        {
            "statement_id": 0,
            "series": [
                {
                    "name": "cpu",
                    "columns": [
                        "time",
                        "idle"
                    ],
                    "values": [
                        [
                            "2022-05-06T07:39:36.738321Z",
                            0.72
                        ]
                    ]
                }
            ]
        }
    ]
}
```