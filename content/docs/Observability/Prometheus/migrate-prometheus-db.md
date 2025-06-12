+++
title = "How to Migrate Prometheus DB?"
draft = false
+++

<aside>
💡 이 글은 kube-prometheus-stack을 기준으로 작성된 글입니다.

</aside>

Server A에서 Server B로 data를 migration하는 방법은 여러 가지가 있다.

필자는 다음과 같은 방법들을 사용해봤다.

1. data 전체를 tar로 압축하거나 / 압축하지 않고 그대로
2. scp로 데이터를 전송 후 압축 해제

하지만 위 방법들을 사용하고 추출을 확인할 땐, 이런 문제가 발생했다…

```python
Exception: Error querying Prometheus: 422 - b'{"status":"error","errorType":"execution","error":"cannot populate chunk 334271146 from block 00000000000000000000000000: segment doesn\'t include enough bytes to read the chunk size data field - required:334271151, available:152137216"}'
```

다행히도 Prometheus에서는 snapshot을 제공한다고 한다. 하지만, snapshot을 사용하기 위해선 관리자 API를 활성화해야한다.

일반적으로는 `prometheus --config.file=/path/to/prometheus.yml --web.enable-admin-api`를 통해 관리자 API를 활성화 할 수 있지만, 현재 사용중인 prometheus는 helm chart로 설치한 터라 values.yaml에서 `enableAdminAPI: true`로 넣어줘야한다.

```yaml
prometheus:
  prometheusSpec:
    enableAdminAPI: true
```

수정 후 꼭 Helm 차트를 업그레이드 해주자.

```yaml
helm upgrade [RELEASE_NAME] [CHART_NAME] -f values.yaml
```
