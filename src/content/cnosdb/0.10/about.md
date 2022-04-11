# CnosDB

CnosDB是一个由社区驱动的开源时间序列数据库。

## 使用场景

> CnosDB是一个专注于时序数据场景的时序型数据库，适用于各种时序场景，如服务器指标、应用程序指标、性能指标、函数接口调用指标、网络流量数据、探测器数据、日志、市场交易记录等。

### DevOps监控

通过监控基础设施（服务器、容器、数据库、微服务、云服务等）的核心指标来及时发现问题并在影响关键业务之前解决问题，尽管一些新兴技术提升了基础设施的DevOps监控的复杂性，但CnosDB都能很好的适应。CnosDB通过灵活的插件的形式，采集指标或者从第三方服务（如StatsD或Kafka）拉取数据，并通过自定义配置按需上报给外部存储系统。

### IoT监控

主要用于接收和处理来自IoT设备的海量数据，并进行实时分析，在无人工干预的情况下，执行预定义操作，IoT设备无处不在，公路摄像头，智能网联车、手机、冰箱都有它的身影，不过IoT设备的硬件性能和缓存能力有限，数据往往是以流式方式实时上报，所以需要一个弹性、扩展性强的高性能时序后台来应对突发流量的挑战。CnosDB的水平扩展、实时分析等能力，是专门针对这类场景来设计的，具有足够的读写性能和容量弹性。

## 产品特性

- 全面与InfluxDB 1.X 稳定版兼容。
- 开源分布式集群，产品永久免费。
- 24*7全球开源社区支持。
- 实时时序数据库：可将您的离线监控平台，提升为一个实时决策系统
- 支持海量时间序列线：在海量标签、海量时间序列线的情况下，依然能够高效实现分布式迭代器及查询优化
- 低成本/碳中和：高效的存储引擎可充分发挥硬件性能，并在高效压缩存储的同时保障查询效率
- 强大完整的生态：可集成市面上主流的采集、存储、分析、可视化等工具