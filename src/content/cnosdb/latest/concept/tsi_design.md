# TSI的设计

## 文件结构
  TSI 由如下几部分构成
    - 索引:包含单个分片的整个索引数据集。
    - 分区:包含用于分片的数据的分片分区。
    - 日志文件:以内存索引的形式包含新写入的series，并持久化为WAL。
    - 索引文件:包含一个不可变的、内存映射的索引，由一个日志文件构建或由两个连续的索引文件合并而成。
    - 序列文件：它包含整个数据库中所有series keys的集合。数据库中的每个分片共享相同的序列文件。

## 写入

  当写入操作系统时，会发生以下情况。

  1. Series被添加到Series文件中，如果Series文件已经存在，则查找它。这将返回一个自动递增的序列ID。
  2. series被发送到索引。索引维护现有系列id的咆哮位图，并忽略已经创建的series。
  3. 该series被hash并发送到适当的分区。
  4. 分区将series作为一个条目写入日志文件。
  5. 日志文件将该series写入磁盘上的预写日志文件，并将该series添加到一组内存索引中。

## 压缩

  一旦日志文件大小超过阈值(5MB)，就会创建一个新的活跃日志文件，并将前一个日志文件压缩到一个索引文件中。第一个索引文件的级别为L1。日志文件被认为是级别L0。

  索引文件也可以通过合并两个较小的索引文件来创建。例如，如果两个相邻的L1索引文件存在，则可以将它们合并到L2索引文件中。

## 读取

  索引提供了几个API调用来检索数据集，例如:

  `MeasurementIterator ()`: 返回已排序的`measurement`名称列表。

  `TagKeyIterator() `: 返回`measurements`中已排序的`tag keys`列表。

  `TagValueIterator()`: 返回`tag keys`的`tag values`的排序列表。

  `MeasurementSeriesIDIterator()`: 返回measurements的所有series id的排序列表。

  `TagKeySeriesIDIterator()`: 返回`tag keys`的所有`series id`的排序列表。

  `TagValueSeriesIDIterator() `: 返回一个`tag values`的所有`series id`的排序列表。

## 日志文件结构

  日志文件的结构很简单，它是按顺序写入磁盘的LogEntry对象列表。日志文件一直写到5MB，然后压缩成索引文件。日志中的条目对象可以是以下任何一种类型:

  - AddSeries
  - DeleteSeries
  - DeleteMeasurement
  - DeleteTagKey
  - DeleteTagValue

  日志文件的内存索引跟踪以下内容:

  - `measurements`的名字
  - `measurements`的`tag keys`
  - `tag keys`的`tag values`
  - `series`的`measurements`
  - `series`的`tag values`
  - `series`, `measurements`, `tag keys`和`tag values`的`tombstones`文件

## 索引文件结构

  索引文件是一个不可变的文件，它跟踪与日志文件类似的信息，但所有数据都被索引并写入磁盘，以便可以直接从内存映射中访问它。

  索引文件包含以下部分：

  - `TagBlocks`: 为单个`tag key`维护`tag value`的索引。
  - `MeasurementBlock`: 维护`measurements`值及其`tag keys`的索引。
  - `Trailer`: 存储文件的偏移量信息，以及用于基数估计的`HyperLogLog`草图。

## MANIFEST文件

  MANIFEST文件存储在索引目录中，并列出属于该索引的所有文件以及访问它们的顺序。每次发生压缩时，都会更新此文件。目录中任何不在索引文件中的文件都是正在压缩过程中的索引文件。

## 文件集

  文件集是在CnosDB进程运行时获得的清单的内存快照。这需要提供索引在某个时间点的一致视图。该文件集还促进了对其所有文件的引用计数，以便在文件的所有读取器完成对文件的操作之前，不会通过压缩删除任何文件。
