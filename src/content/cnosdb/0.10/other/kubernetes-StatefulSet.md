# 使用Kubernetes部署CnosDB集群

## 创建一个Kubernetes CnosDB部署文件
> 下面的清单中包含两个[Service](https://kubernetes.io/zh/docs/concepts/services-networking/service/)，两个[ConfigMap](https://kubernetes.io/zh/docs/concepts/configuration/configmap/https://kubernetes.io/zh/docs/concepts/configuration/configmap/)，和两个[StatefulSet](https://kubernetes.io/zh/docs/concepts/workloads/controllers/statefulset/)
> 本教程假设你的集群配置为动态的提供 PersistentVolumes。 如果你的集群没有配置成这样，在开始本教程前，你需要手动准备三个 20 GiB 和两个 2GiB 的卷。
```yaml
apiVersion: v1
kind: Service
metadata:
  name: cnosdb-meta
  labels:
    app: cnosdb-meta
spec:
  ports:
  - port: 8091
    name: meta
  selector:
    app: cnosdb-meta
---
apiVersion: v1
kind: Service
metadata:
  name: cnosdb-data
  labels:
    app: cnosdb-data
spec:
  type: LoadBalancer
  ports:
  - port: 8088
    name: data
  - port: 8086
    targetPort: 8086
    nodePort: 31086
    name: data-access
  selector:
    app: cnosdb-data
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: cnosdb-meta-pdb
spec:
  selector:
    matchLabels:
      app: cnosdb-meta
  maxUnavailable: 2
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: cnosdb-data-pdb
spec:
  selector:
    matchLabels:
      app: cnosdb-data
  maxUnavailable: 1
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: cnosdb-meta-config
  labels:
    app: cnosdb-meta
data:
  cnosdb-meta.conf: |+
    dir = "/var/lib/cnosdb/meta"
    retention-autocreate = true
    hostname = ""
    [HTTPD]
      logging-enabled = true
      http-bind-address = ":8091"
      https-enabled = false
      https-certificate = ""
      election-timeout = "1s"
      heartbeat-timeout = "1s"
      leader-lease-timeout = "500ms"
      commit-timeout = "50ms"
      cluster-tracing = false
      lease-duration = "1m0s"
    [Log]
      level = "INFO"
      format = "text"
      disable-timestamp = false
      development = false
      disable-caller = false
      disable-stacktrace = false
      disable-error-verbose = false
    [Log.file]
      filename = ""
      max-size = 0
      max-days = 0
      max-backups = 0
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: cnosdb-data-config
  labels:
    app: cnosdb-data
data:
  cnosdb-data.conf: |+
    bind-address = ":8088"
    cluster = true
    hostname = ""

    [Meta]
      dir = "/var/lib/cnosdb/meta"
      retention-autocreate = true

    [Data]
      dir = "/var/lib/cnosdb/data"
      index-version = "tsi1"
      wal-dir = "/var/lib/cnosdb/wal"
      wal-fsync-delay = "0s"
      validate-keys = false
      query-log-enabled = true
      cache-max-memory-size = 1073741824
      cache-snapshot-memory-size = 26214400
      cache-snapshot-write-cold-duration = "10m0s"
      compact-full-write-cold-duration = "4h0m0s"
      compact-throughput = 50331648
      compact-throughput-burst = 50331648
      max-series-per-database = 1000000
      max-values-per-tag = 100000
      max-concurrent-compactions = 0
      max-index-log-file-size = 1048576
      series-id-set-cache-size = 100
      trace-logging-enabled = false
      tsm-use-madv-willneed = false

    [Coordinator]
      force-remote-mapping = false
      write-timeout = "10s"
      shard-writer-timeout = "5s"
      max-remote-write-connections = 3
      shard-mapper-timeout = "5s"
      max-concurrent-queries = 0
      query-timeout = "0s"
      log-queries-after = "0s"
      max-select-point = 0
      max-select-series = 0
      max-select-buckets = 0

    [RetentionPolicy]
      enabled = true
      check-interval = "30m0s"

    [Precreator]
      enabled = true
      check-interval = "10m0s"
      advance-period = "30m0s"

    [Monitor]
      store-enabled = true
      store-database = "_internal"
      store-interval = "10s"

    [Subscriber]
      enabled = false
      http-timeout = "0s"
      insecure-skip-verify = false
      ca-certs = ""
      write-concurrency = 0
      write-buffer-size = 0

    [HTTPD]
      enabled = true
      bind-address = ":8086"
      auth-enabled = false
      log-enabled = true
      suppress-write-log = false
      write-tracing = false
      pprof-enabled = true
      debug-pprof-enabled = false
      https-enabled = false
      https-certificate = "/etc/ssl/cnosdb.pem"
      https-private-key = ""
      max-row-limit = 0
      max-connection-limit = 0
      shared-secret = ""
      realm = "CnosDB"
      unix-socket-enabled = false
      unix-socket-permissions = "0777"
      bind-socket = "/var/run/cnosdb.sock"
      max-body-size = 25000000
      access-log-path = ""
      max-concurrent-write-limit = 0
      max-enqueued-write-limit = 0
      enqueued-write-timeout = 30000000000

    [Log]
      level = "INFO"
      format = "text"
      disable-timestamp = false
      development = false
      disable-caller = false
      disable-stacktrace = false
      disable-error-verbose = false
    [Log.file]
      filename = ""
      max-size = 0
      max-days = 0
      max-backups = 0

    [ContinuousQuery]
      log-enabled = true
      enabled = true
      query-stats-enabled = false
      run-interval = "1s"

    [HintedHandoff]
      enabled = false
      dir = ""
      max-size = 0
      max-age = "0s"
      retry-rate-limit = 0
      retry-interval = "0s"
      retry-max-interval = "0s"
      purge-interval = "0s"

    [TLS]
      min-version = ""
      max-version = ""
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: cnosdb-meta
spec:
  selector:
    matchLabels:
      app: cnosdb-meta
  serviceName: cnosdb-meta
  replicas: 3
  updateStrategy:
    type: RollingUpdate
  podManagementPolicy: OrderedReady
  template:
    metadata:
      labels:
        app: cnosdb-meta
    spec:
      containers:
      - name: kubernetes-cnosdb-meta
        imagePullPolicy: Always
        image: "cnosdb/cnosdb-meta:latest"
        resources:
          requests:
            memory: "2Gi"
            cpu: "2"
        ports:
        - containerPort: 8091
          name: meta
        volumeMounts:
        - name: metadir
          mountPath: /var/lib/cnosdb
        - name: meta-config-volume
          mountPath: /etc/cnosdb/
        env:
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: CNOSDB_HOSTNAME
          value: "$(POD_NAME).cnosdb-meta"
      volumes:
        - name: meta-config-volume
          configMap:
            name: cnosdb-meta-config
  volumeClaimTemplates:
    - metadata:
        name: metadir
      spec:
        accessModes: [ "ReadWriteOnce" ]
        resources:
          requests:
            storage: 2Gi
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: cnosdb-data
spec:
  selector:
    matchLabels:
      app: cnosdb-data
  serviceName: cnosdb-data
  replicas: 2
  updateStrategy:
    type: RollingUpdate
  podManagementPolicy: OrderedReady
  template:
    metadata:
      labels:
        app: cnosdb-data
    spec:
      containers:
      - name: kubernetes-cnosdb-data
        imagePullPolicy: Always
        image: "cnosdb/cnosdb-data:latest"
        resources:
          requests:
            memory: "8Gi"
            cpu: "4"
        ports:
        - containerPort: 8088
          name: cnosdb-data
        - containerPort: 8086
          name: data-access
        volumeMounts:
        - name: datadir
          mountPath: /var/lib/cnosdb
        - name: data-config-volume
          mountPath: /etc/cnosdb/
        env:
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: CNOSDB_HOSTNAME
          value: "$(POD_NAME).cnosdb-data"
      volumes:
        - name: data-config-volume
          configMap:
            name: cnosdb-data-config
  volumeClaimTemplates:
    - metadata:
        name: datadir
      spec:
        accessModes: [ "ReadWriteOnce" ]
        resources:
          requests:
            storage: 20Gi
```

## 按照清单部署应用

```shell
kubectl apply -f cnosdb-cluster.yaml
```

## 将`meta node`加入到集群
> 使用`kubectl get pod`查看，当所有pod都处于Running时
```shell
for i in 0 1 2; do kubectl exec cnosdb-meta-0 -- cnosdb-ctl add-meta  cnosdb-meta-$i.cnosdb-meta:8091; done
```

## 如果以上命令执行成功
```shell
kubectl exec cnosdb-meta-0 -- cnosdb-ctl show
Data Nodes:
==========

Meta Nodes:
==========

1      cnosdb-meta-0.cnosdb-meta:8091
2      cnosdb-meta-1.cnosdb-meta:8091
3      cnosdb-meta-2.cnosdb-meta:8091

```

## 将`data node`加入到集群

```shell
for i in 0 1; do kubectl exec cnosdb-meta-0 -- cnosdb-ctl add-data  cnosdb-data-$i.cnosdb-data:8088; done
```

## 如果以上命令执行成功

```shell
kubectl exec cnosdb-meta-0 -n cnosdb-test -- cnosdb-ctl show
Data Nodes:
==========

4      cnosdb-data-0.cnosdb-data:8088
5      cnosdb-data-1.cnosdb-data:8088

Meta Nodes:
==========

1      cnosdb-meta-0.cnosdb-meta:8091
2      cnosdb-meta-1.cnosdb-meta:8091
3      cnosdb-meta-2.cnosdb-meta:8091

```

## 测试服务是否可用
```shell
curl -i -XPOST http://<nodeIP>:31086/query --data-urlencode "q=CREATE DATABASE test_db"
HTTP/1.1 200 OK
Content-Type: application/json
X-Request-Id: 41e2329b-6945-11ec-8001-0242ac110007
Date: Thu, 30 Dec 2021 07:51:12 GMT
Transfer-Encoding: chunked

{"results":[{"statement_id":0}]}
```