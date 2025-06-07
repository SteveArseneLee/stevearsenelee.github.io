+++
title = "Flink to GCS"
draft = false
bookHidden = true
+++
## 1. GCP 준비
- Bucket 생성
- Service account 생성 (최소 권한)
    - Storage Object Admin
    - Storage Object Creator
- Service account key(Json file) 생성 후 다운로드

## 2. K8s Secret 생성
```sh
kubectl create secret generic {secret_key_name} \
  --from-file={1번에서 발급받은 json파일}={/path/to/your/keyfile.json} \
  -n flink

# e.g.
kubectl create secret generic gcp-steve-account-key \
  --from-file=squidengineer-25d36a46ab7f.json=/path/to/your/keyfile.json \
  -n flink
```

## 3. GCS Connector 준비
### 필요 JAR 목록
- flink-gs-fs-hadoop-1.20.1.jar : Flink가 GCS를 지원하는 플러그인
- gcs-connector-hadoop2-latest.jar : GCS와 HDFS 인터페이스를 연결하는 Google 제공 connector

```sh
wget https://repo1.maven.org/maven2/org/apache/flink/flink-gs-fs-hadoop/1.20.1/flink-gs-fs-hadoop-1.20.1.jar
wget https://storage.googleapis.com/hadoop-lib/gcs/gcs-connector-hadoop2-latest.jar
```

> 참고:  
> flink-gs-fs-hadoop은 Flink 1.20 공식 릴리스부터 기본 지원.  
> 단, 여전히 "gcs-connector-hadoop"은 별도 필요함 (GCP 라이브러리).

## 4. Custom Flink Docker image 만들기
### Dockerfile 작성
```dockerfile
FROM flink:1.20.1-scala_2.12

# GCS connector 플러그인 및 라이브러리 추가
RUN mkdir -p /opt/flink/plugins/flink-gs-fs-hadoop
COPY flink-gs-fs-hadoop-1.20.1.jar /opt/flink/plugins/flink-gs-fs-hadoop/
COPY gcs-connector-hadoop2-latest.jar /opt/flink/lib/

# 플러그인 활성화
RUN echo "plugins.enable: flink-gs-fs-hadoop" >> /opt/flink/conf/flink-conf.yaml
RUN chmod -R 755 /opt/flink/plugins/flink-gs-fs-hadoop
```

### 이미지 빌드 및 업로드
```sh
docker build -t {dockerhub-username}/steve-flink-gcs:1.20.1 .
docker push {dockerhub-username}/steve-flink-gcs:1.20.1
```

## 5. FlinkDeployment YAML 작성
```yaml
apiVersion: flink.apache.org/v1beta1
kind: FlinkDeployment
metadata:
  name: {cluster-name}
  namespace: flink
spec:
  image: {dockerhub-username}/steve-flink-gcs:1.20.1
  flinkVersion: v1_20
  serviceAccount: flink
  mode: standalone

  flinkConfiguration:
    taskmanager.numberOfTaskSlots: "2"
    jobmanager.memory.process.size: "1024m"
    taskmanager.memory.process.size: "2048m"
    kubernetes.rest-service.exposed.type: ClusterIP
    kubernetes.deployment.target: standalone

    fs.gs.project.id: {gcp-project-id}
    fs.gs.system.bucket: {bucket-name}
    fs.gs.auth.service.account.json.keyfile: /opt/flink/custom-config/{gcp-secret-key}

    fs.gs.impl: com.google.cloud.hadoop.fs.gcs.GoogleHadoopFileSystem
    fs.AbstractFileSystem.gs.impl: com.google.cloud.hadoop.fs.gcs.GoogleHadoopFS

    plugins.enable: flink-gs-fs-hadoop

  jobManager:
    replicas: 1
    resource:
      memory: "2048m"
      cpu: 1
    podTemplate:
      spec:
        volumes:
          - name: gcp-sa-key
            secret:
              secretName: {secret-name}
        containers:
          - name: flink-main-container
            env:
              - name: GOOGLE_APPLICATION_CREDENTIALS
                value: /opt/flink/custom-config/{gcp-secret-key}
            volumeMounts:
              - mountPath: /opt/flink/custom-config/{gcp-secret-key}
                name: gcp-sa-key
                subPath: {gcp-secret-key}

  taskManager:
    replicas: 2
    resource:
      memory: "2048m"
      cpu: 1
    podTemplate:
      spec:
        volumes:
          - name: gcp-sa-key
            secret:
              secretName: {secret-name}
        containers:
          - name: flink-main-container
            volumeMounts:
              - mountPath: /opt/flink/custom-config/{gcp-secret-key}
                name: gcp-sa-key
                subPath: {gcp-secret-key}
            env:
              - name: GOOGLE_APPLICATION_CREDENTIALS
                value: /opt/flink/custom-config/squidengineer-25d36a46ab7f.json

  ingress:
    template: "{ingress-name}"
    className: nginx
    annotations:
      nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
      nginx.ingress.kubernetes.io/ssl-passthrough: "true"
      cert-manager.io/cluster-issuer: "selfsigned-cluster-issuer"
```
> 꼭 ```env```로 ```GOOGLE_APPLICATION_CREDENTIALS``` 설정을 해줘야 **권한 인증** 가능

## 6. Flink SQL Client로 데이터 삽입
```sh
kubectl exec -it -n flink deploy/{cluster-name}-jobmanager -- /opt/flink/bin/sql-client.sh embedded
```
로 접속 후, 테스트 용도로
```sql
DROP TABLE IF EXISTS {TABLE_NAME};

CREATE TABLE {TABLE_NAME} (
  id INT,
  name STRING
) WITH (
  'connector' = 'filesystem',
  'path' = 'gs://{bucket-name}/{folder-name}/',
  'format' = 'csv',
  'sink.partition-commit.policy.kind' = 'success-file'
);

INSERT INTO {TABLE_NAME} VALUES
  (1, 'steve'),
  (2, 'chatgpt'),
  (3, 'gpt4o');
```
위를 실행한다.
