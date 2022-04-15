# 目录

<!--本目录为重构后的目录
1. 参考内容
    https://influxdb-v1-docs-cn.cnosdb.com/
    https://www.cnosdb.com/
    https://docs.influxdata.com/influxdb/v1.8/
2. 替换文档中所有的到的所有示例数据，例如 NOAA_water_database，foodships以及Devops数据 
3. 新的示例数据，由@ailunyegeer提供，参考的是中国海洋站一些[台站的数据](http://mds.nmdis.org.cn/pages/dataViewDetail.html?dataSetId=4-1)
4. 未来的最新文档只放在latest目录下，历史文档不会被更新
-->

[介绍]()

[快速开始]()

- [下载和安装和启动](download_install_run.md)
  <!--Ubuntu/debain， Mac OS， CentOS/Rathat，Windows， Docker， k8s） -->
- 入门指南
  <!-- Link to 入门指南.cnosdb-cli -->

[概念]()

- CnosDB VS SQL
- 设计原则
- 设计架构和TSM
- TSI的设计
- 文件系统布局

[入门指南]()
- cnosdb-cli
  <!-- 导入数据到数据库，Link to CnosQL入门  -->
- Go SDK example 
- Curl 查询和写入数据

[运维管理]()
- 备份和还原
- 导入和导出
- CnosDB配置
  - 端口
  - 日志
  - 索引
  - 监控
  - … …
- CnosDB工具
  - cnosdb
  - cnosdb-cli
  - cnosdb_inspect

[CnosQL]()
- CnosQL入门
- CnosQL语法
- schema查询
- 管理数据库
- 连续查询
- CnosQL函数
- CnosQL数学运算符
- CnosQL参考

[数据协议]()
- CnosDB line Protocol
- CnosDB Write API
- CnosDB Query API
- Prometheus
- Telegraf

[集群管理]()
- 敬请期待

[疑难解答]()

