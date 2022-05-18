# Golang

  学习使用CnosDB Golang SDK 操作CnosDB

- ## 使用`/ping`查看cnosdb状态

  ```
  func ExampleClient_Ping() {
  
      c, err := client.NewHTTPClient(client.HTTPConfig{
          Addr: "http://localhost:8086",
      })
      if err != nil {
          fmt.Println("Error creating CnosDB Client: ", err.Error())
      }
      defer c.Close()
  
      _, rs, err := c.Ping(0)
      fmt.Println("version:", rs)
      if err != nil {
          fmt.Println("Error pinging CnosDB: ", err.Error())
      }
  }
  ```

- ## 使用http client写入一个point

  ```
  func ExampleClient_write() {
      // Make client
      c, err := client.NewHTTPClient(client.HTTPConfig{
          Addr: "http://localhost:8086",
      })
      if err != nil {
          fmt.Println("Error creating CnosDB Client: ", err.Error())
      }
      defer c.Close()
  
      // Create a new point batch
      bp, _ := client.NewBatchPoints(client.BatchPointsConfig{
          Database:  "oceanic_station",
          Precision: "s",
      })
  
      // Create a point and add to batch
      tags := map[string]string{"station": "XiaoMaiDao"}
      fields := map[string]interface{}{
          "temperature": 67,
          "visibility":  58,
      }
      pt, err := client.NewPoint("air", tags, fields, time.Now())
      if err != nil {
          fmt.Println("Error: ", err.Error())
      }
      bp.AddPoint(pt)
  
      // Write the batch
      c.Write(bp)
  }
  ```

- ## 创建一个BatchPoint，并添加一个Point

  ```
  func ExampleBatchPoints() {
      // Create a new point batch
      bp, _ := client.NewBatchPoints(client.BatchPointsConfig{
          Database:  "oceanic_station",
          Precision: "s",
      })
  
      // Create a point and add to batch
      tags := map[string]string{"station": "XiaoMaiDao"}
      fields := map[string]interface{}{
          "temperature": 67,
          "visibility":  58,
      }
      pt, err := client.NewPoint("air", tags, fields, time.Now())
      if err != nil {
          fmt.Println("Error: ", err.Error())
      }
      bp.AddPoint(pt)
  }
  ```

- ## 使用BatchPoint的setter方法

  ```
  func ExampleBatchPoints_setters() {
      // Create a new point batch
      bp, _ := client.NewBatchPoints(client.BatchPointsConfig{})
      bp.SetDatabase("oceanic_station")
      bp.SetPrecision("ms")
  
      // Create a point and add to batch
      tags := map[string]string{"station": "XiaoMaiDao"}
      fields := map[string]interface{}{
          "temperature": 67,
          "visibility":  58,
      }
      pt, err := client.NewPoint("air", tags, fields, time.Now())
      if err != nil {
          fmt.Println("Error: ", err.Error())
      }
      bp.AddPoint(pt)
  }
  ```

- ## 创建一个point并设置时间戳

  ```
  func ExamplePoint() {
      tags := map[string]string{"station": "XiaoMaiDao"}
      fields := map[string]interface{}{
          "temperature": 67,
          "visibility":  58,
      }
      pt, err := client.NewPoint("air", tags, fields, time.Now())
      if err == nil {
          fmt.Println("We created a point: ", pt.String())
      }
  }
  ```

- ## 创建一个没有时间戳的point

  ```
  func ExamplePoint_withoutTime() {
      tags := map[string]string{"station": "XiaoMaiDao"}
      fields := map[string]interface{}{
          "temperature": 67,
          "visibility":  58,
      }
      pt, err := client.NewPoint("air", tags, fields)
      if err == nil {
          fmt.Println("We created a point w/o time: ", pt.String())
      }
  }
  ```

- ## 创建一个查询请求

  ```
  func ExampleClient_query() {
      // Make client
      c, err := client.NewHTTPClient(client.HTTPConfig{
          Addr: "http://localhost:8086",
      })
      if err != nil {
          fmt.Println("Error creating CnosDB Client: ", err.Error())
      }
      defer c.Close()
  
      q := client.NewQuery("SELECT temperature FROM air limit 10", "oceanic_station", "ns")
      if response, err := c.Query(q); err == nil && response.Error() == nil {
          fmt.Println(response.Results)
      }
  }
  ```

- ## 创建一个查询请求并指定数据库

  ```
  func ExampleClient_createDatabase() {
      // Make client
      c, err := client.NewHTTPClient(client.HTTPConfig{
          Addr: "http://localhost:8086",
      })
      if err != nil {
          fmt.Println("Error creating CnosDB Client: ", err.Error())
      }
      defer c.Close()
  
      q := client.NewQuery("CREATE DATABASE mydb", "", "")
      if response, err := c.Query(q); err == nil && response.Error() == nil {
          fmt.Println(response.Results)
      }
  }
  
  ```
