+++
title = "Kafka의 성능 측정 (Block storage vs NFS)"
draft = false
categories = ["Kafka"]
+++
## 개요
[Kafka docs](https://kafka.apache.org/documentation/)에는 어디에 데이터를 저장해야한다는 글이 없지만, Kafka를 k8s에 올릴 때 사용하는 [strimzi operator](https://strimzi.io/docs/operators/latest/deploying#considerations-for-data-storage-str)에는 다음과 같은 문구가 있다.
> Efficient data storage is essential for Strimzi to operate effectively, and block storage is strongly recommended. Strimzi has been tested only with block storage, and file storage solutions like NFS are not guaranteed to work.

기존에는 k8s에서 kafka의 저장소로 nfs를 사용했던 터라, block storage를 추가로 깔아야한다고 생각했고 이에 따라 longhorn, openebs, ceph 중 ceph가 가장 대중적(?)이면서 de-factor standard로 알고있어서 채요했다. 물론 ceph의 여러 storage가 있지만 그 중 ceph rbd만을 사용했으며, nfs와의 성능 테스트에 대한 글이다.

성능 테스트를 위한 시나리오는 크게 6가지로 잡았다.

시나리오 ID | 테스트 목적 | 입력 조건 | 기대 출력 (측정 지표)
-|-|-|-
S1 | 단일 Producer Throughput | 1KB × 10만건, throughput=-1 | 초당 처리량 (MB/s), 평균 전송 지연
S2 | 병렬 Producer 처리량 | Producer 5개 | 총 처리량 (MB/s), Broker 부하
S3 | 단일 Consumer 처리 속도 | test-topic의 10만 메시지 | 총 처리 시간, 초당 소비량
S4 | 장시간 부하 → 리소스 누수 | 1시간 지속 전송 (throughput=10000/s) | 메모리 증가
S5 | 대용량 메시지 처리 | 100KB, 10만건, throughput 제한 없음 | 처리량(MB/s), 전송/소비 실패율
S6 | Producer latency 측정 | acks=all, linger.ms=5, batch.size=32KB | 평균/최대 latency(ms)

이제 코드와 결과 및 분석 내용에 대해 순차적으로 나열하겠다.

## S1. 단일 Producer Throughput 측정
```sh
bin/kafka-producer-perf-test.sh \
  --topic test-topic \
  --num-records 100000 \
  --record-size 1024 \
  --throughput -1 \
  --producer-props bootstrap.servers=<bootstrap>
```

### S1 - 결과
메시지 수 | Throughput (NFS) | Avg Latency (NFS) | Throughput (Ceph) | Avg Latency (Ceph)
-|-|-|-|-
100 | 0.06 MB/sec | 270.57 ms | 0.16 MB/sec | 121.25 ms 
500 | 0.25 MB/sec | 678.76 ms | 0.70 MB/sec | 99.58 ms
1000 | 0.32 MB/sec | 1,187.67 ms | 1.00 MB/sec | 258.99 ms
3000 | 0.39 MB/sec | 3,355.14 ms | 1.78 MB/sec | 559.59 ms
5000 | 0.40 MB/sec | 5,602.60 ms | 2.11 MB/sec | 802.07 ms
10000 | 0.41 MB/sec | 11,196.89 ms | 2.31 MB/sec | 1,813.02 ms

- Ceph RBD는 처리량(Throughput)이 NFS 대비 4~6배 이상 높고, latency도 현저히 낮음
- NFS는 쓰기 IOPS 한계와 fsync() 동기화 지연으로 인해 latency가 선형적으로 증가
- Ceph은 병렬 쓰기 처리 능력이 훨씬 뛰어나 throughput을 일정 수준 이상으로 유지함

클러스터 | Kafka UI Topic Size | 메시지 수
NFS | 약 63 MB | 19,000
Ceph | 약 383 MB | 19,000



## S2. 다중 Producer Throughput 측정
```sh
for i in {1..5}; do
  echo "[INFO] Starting producer $i"
  bin/kafka-producer-perf-test.sh \
    --topic test-topic \
    --num-records 100000 \
    --record-size 1024 \
    --throughput -1 \
    --producer-props bootstrap.servers=<bootstrap> \
```
### S2 - 결과
Storage | 메시지 수 | Avg Throughput (MB/s) | Std | Avg Latency (ms) | Std
-|-|-|-|-|-
Ceph | 100 | 145.41 | ±4.58 | 75.62 | ±10.33
Ceph | 500 | 524.29 | ±25.50 | 171.46 | ±20.00
Ceph | 1,000 | 1079.18 | ±71.19 | 160.37 | ±32.10
Ceph | 3,000 | 1497.76 | ±97.84 | 593.03 | ±76.98
Ceph | 5,000 | 1773.06 | ±70.65 | 1002.05 | ±64.60
Ceph | 10,000 | 1117.00 | ±6.63 | 3967.63 | ±110.83
Ceph | 50,000 | 1355.23 | ±4.85 | 14715.06 | ±182.03
-|-|-|-|-|-
NFS | 100 | 65.54 | ±11.68 | 40.95 | ±97.09
NFS | 500 | 106.50 | ±5.61 | 1,940.27 | ±122.21
NFS | 1,000 | 399.04 | ±14.09 | 976.34 | ±67.71
NFS | 3,000 | 446.17 | ±6.79 | 3000.52 | ±129.00
NFS | 5,000 | 428.52 | ±3.59 | 5285.97 |±107.04
NFS | 10,000 | 439.79 | ±2.63 | 10777.37 | ±152.69
NFS | 50,000 | 425.29 | ±2.34 | 51486.65 | ±539.49

✅ Ceph RBD는 전 구간에서 NFS 대비 3~4배 이상 우수한 성능
- Throughput은 NFS 대비 3~4배 이상 높음
- Latency는 NFS 대비 4~10배 이상 낮음

✅ NFS는 메시지 수 증가에 따라 Latency가 선형적으로 악화
- 디스크 flush 주기와 fsync() 동기화 지연이 누적되어 전체 처리 시간 증가
- 초당 처리량은 일정 수준(400~440 MB/s)에서 정체, 스로틀링 발생

✅ Ceph은 병렬 쓰기 구조로 throughput 유지력 우수
- 메시지 수 증가에도 일정 수준 throughput 유지 (특히 50,000건에서 안정적)
- 병렬 처리, OSD 분산 저장, 빠른 segment flush 구조가 원인




## S3. Consumer 처리 시간
```sh
time bin/kafka-consumer-perf-test.sh \
  --broker-list <bootstrap> \
  --topic test-topic \
  --messages 100000 \
```
### S3 - 결과
메시지 수 | Ceph Throughput (msg/s) | NFS Throughput (msg/s) | 차이 배율 | 비고
-|-|-|-|-
100 | 2,994.0 | 123.5 | 24.2× | 초기 메시지 수 적음에도 latency 차이 큼
500 | 114.2 | 123.7 | 0.92× | NFS가 소폭 빠름
1000 | 124.5 | 44.1 | 2.8× |초기 메시지 수 적음에도 latency 차이 큼
3000 | 740.1 | 766.6 | 1.0× | 거의 비슷
5000 | 1261.6 | 1270.3 | 1.0× | 거의 비슷
10000 | 2686.9 | 2419.9 | 1.1× | Ceph이 더 빠름
50000 | 8797.9 | 8732.2 | 1.0× | 동일 수준
100000 | 13595.7 | 13653.5 | 0.99× | NFS가 소폭 빠름

✅ Ceph RBD는 전체적으로 안정적이지만, Consumer 테스트에선 Throughput에서 NFS와 큰 차이는 없음. 그러나 Fetch Time과 Rebalance Time에서 Ceph이 일관되고 짧은 시간을 보임.
- Fetch Time : Kafka Consumer가 Broker로부터 message를 가져오는 데 걸리는 시간
- Rebalance Time : Kafka Consumer Group에서 새로운 Consumer가 join하거나 leave 할 때, 파티션이 재할당되며 이 과정에서 걸리는 시간


## S4. 장시간 부하테스트
```sh
time bin/kafka-producer-perf-test.sh \
  --topic test-topic \
  --num-records 3600000 \
  --record-size 1024 \
  --throughput 1000 \
  --producer-props bootstrap.servers=<bootstrap> \
```
### S4 - 결과
항목 | NFS | Ceph RBD | 차이 분석
-|-|-|-
전송 총량 | 3,600,000 records | 3,600,000 records | 동일
전송 속도 (records/sec) | 405.74 | 999.98 | Ceph이 약 2.46배 빠름
데이터 전송량 (MB/sec) | 0.40 MB/sec | 0.98 MB/sec | Ceph이 2.45배 높음
평균 Latency | 75,165.08 ms | 89.75 ms | NFS가 837배 느림 
최대 Latency | 83,580.00 ms | 1,923.00 ms | NFS가 43.5배 느림
50th Percentile (p50) | 75,989 ms | 26 ms | NFS가 2,922배 느림
95th Percentile (p95) | 80,636 ms | 502 ms | NFS가 160배 느림
99th Percentile (p99) | 82,362 ms | 824 ms | NFS가 99.9배 느림
99.9th Percentile (p99.9) | 82,991 ms | 1,326 ms | NFS가 62.5배 느림


## S5. 대용량 메세지 처리 테스트
```sh
bin/kafka-producer-perf-test.sh \
  --topic test-topic-large \
  --num-records 100000 \
  --record-size 100000 \
  --throughput -1 \
  --producer-props bootstrap.servers=<bootstrap>
```

## 총평
항목 | Ceph RBD | NFS
-|-|-
Throughput | ✔ 최대치 거의 도달 (안정적 유지) | ❌ 400~440 records/sec에서 정체
Latency | ✔ 10~20ms 수준, 전 구간 안정적 | ❌ 수십~수천 ms, 메시지 수 증가 시 악화
병렬 처리 | ✔ OSD 기반 분산 쓰기, flush 효율 높음 | ❌ sync/flush 병목, 선형적 지연 발생
자원 사용 (CPU) | ✔ 더 많이 쓰고 성능 확보 | ❌ 적게 쓰지만 처리 성능 낮음
운영 적합성 | ✔ 실시간 스트리밍 / 고부하 환경 | ❌ dev/test 등 저부하 용도에 한정

- Ceph RBD는 모든 구간에서 NFS 대비 3~10배 이상 우수
- Kafka의 특성상, 저장소 선택이 성능과 안정성에 직접 영향
- NFS는 실시간 처리 시스템에 부적합
- 운영 환경에서는 반드시 block 기반 고성능 스토리지 사용 권장

> 이 테스트를 마칠 떄 쯤 한가지 깨달은게 있었다. k8s 클러스터 외부에 두는게 가장 성능은 좋지만, "성능"만 생각한다면 굳이 block storage tool을 안쓰고도 Local PV를 쓸 수 있고 이를 잘만 백업해둔다면 "장애" 측면도 무리가 없다는 것을...