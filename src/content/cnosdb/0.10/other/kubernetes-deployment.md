# 使用Kubernetes部署CnosDB

## 创建namespace

```shell
NAMESPACE=cnosdb-prod
kubectl create namespace $NAMESPACE
```

## 创建配置文件
```shell
wget -O cnosdb.conf https://cnosdb.github.io/content/cnosdb/0.9/other/cnosdb.sample.toml
kubectl create configmap cnosdb-config --from-file cnosdb.conf -n $NAMESPACE
```

## 编写Deployment文件

```shell
$ cat cnosdb-deployment.yaml
apiVersion: v1
kind: Deployment
metadata:
  name: cnosdb-deployment
  labels:
    app: cnosdb
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cnosdb
  template:
    metadata:
      labels:
        app: cnosdb
    spec:
      containers:
      - name: cnosdb
        image: cnosdb/cnosdb:latest
        ports:
        - name: cnosdb
          containerPort: 8086
          protocol: TCP
        volumeMounts:
        - name: cnosdbvolume
          mountPath: /cnosdb
      volumes:
      - name: cnosdbvolume
        hostPath:
          path: /opt/data
      - name: cnosdb-config
        configMap:
          name: cnosdb-config
```

## 编写Service文件

```shell
$ cat cnosdb-service.yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: cnosdb
  name: cnosdb-service
spec:
  ports:
  - port: 32085
    nodePort: 32086
    protocol: TCP
  selector:
    app: cnosdb
  type: NodePort
```
## 创建Deployment和Service

```shell
kubectl apply -f cnosdb-deployment.yaml -n $NAMESPACE
kubectl apply -f cnosdb-service.yaml -n $NAMESPACE
```

## 测试是否正确安装

```shell
$ kubectl get pods -n $NAMESPACE
NAME                                 READY   STATUS    RESTARTS   AGE
cnosdb-deployment-855c7f4c59-6xl67   1/1     Running   0          5m24s
$
$ kubectl get svc -n $NAMESPACE
NAME             TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)           AGE
cnosdb-service   NodePort   10.100.125.92   <none>        30085:32086/TCP   49m

$ curl -i -XPOST http://<nodeIP>:32086/query --data-urlencode "q=CREATE DATABASE test_db"
HTTP/1.1 200 OK
Content-Type: application/json
X-Request-Id: 41e2329b-6945-11ec-8001-0242ac110007
Date: Thu, 30 Dec 2021 07:51:12 GMT
Transfer-Encoding: chunked

{"results":[{"statement_id":0}]}
```

