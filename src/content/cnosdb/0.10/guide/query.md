# HTTP查询

要执行`CnosQL`查询，请向`/query`端点发送GET请求，将URL参数设置`db`为目标数据库，然后将URL参数设置`q`为查询，也可`POST`通过发送与URL参数相同或作为正文一部分参数来使用请求`application/x-www-form-urlencoded`.

```bash
curl -G 'http://localhost:8086/query?pretty=true' --data-urlencode "db=mydb" --data-urlencode "q=SELECT \"value\" FROM \"cpu_load_short\" WHERE \"region\"='us-west'"
```

CnosDB 返回 JSON:


```json
{
    "results": [
        {
            "statement_id": 0,
            "series": [
                {
                    "name": "cpu_load_short",
                    "columns": [
                        "time",
                        "value"
                    ],
                    "values": [
                        [
                            "2015-01-29T21:55:43.702900257Z",
                            2
                        ],
                        [
                            "2015-01-29T21:55:43.702900257Z",
                            0.55
                        ],
                        [
                            "2015-06-11T20:46:02Z",
                            0.64
                        ]
                    ]
                }
            ]
        }
    ]
}
```

> **Note:** 附加`pretty=true`到URL会启用精美打印的JSON输出，虽然这对于调试或在使用诸如之类的工具直接查询很有用`curl`，但不建议用于生产环境，因为会消耗很多不必须要的网络带宽
