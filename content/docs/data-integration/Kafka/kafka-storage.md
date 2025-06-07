+++
title = "Kafka의 저장소"
draft = false
+++

Kubernetes에서 kafka를 사용할때 kafka의 데이터 저장소는 어떤 것이 적절한지에 대한 글이다.

> Efficient data storage is essential for Strimzi to operate effectively, and block storage is strongly recommended. Strimzi has been tested only with block storage, and file storage solutions like NFS are not guaranteed to work.  

Strimzi는 block storage만을 대상으로 테스트 및 인증했으며, NFS 기반 스토리지는 다음과 같은 이유로 사용을 권장하지 않음
- 동시 접근 시 locking 이슈 발생
- rename, append 등 Kafka가 요구하는 파일 시스템 특성과 충돌 가능
- Latency 및 Throughput 불안정성 (특히 segment flush, recovery 시 심각)
- File handle 누수나 lease 문제가 발생할 수 있음


### Kafka의 저장 방식 순서
1. log message를 segment file에 append
2. memory flush → fsync to disk
3. segment가 일정 크기 도달 시 rename(segment.000.log → segment.001.log)
4. index 파일 동기화 및 offset 확인
5. restart 시 파일 정합성 체크

→ 위 작업들은 block-level consistency와 atomic operation 보장을 전제로 설계됨

즉, Kafka는 log-segment 기반으로
- 데이터는 지속적으로 append-write 되고
- 주기적으로 fsync, flush, segment 파일 rename 작업이 발생
- 재시작 시 segment recovery를 위해 .log, .index 파일의 정합성이 매우 중요


하지만… NFS는
- client마다 lock 동작 방식 다름 → flock이나 fcntl 무력화 가능
- 파일 locking과 rename에 제약이 있으며
- Kafka는 재시작 시 log/index 파일을 복구 → NFS는 file handle 누락, incomplete rename으로 인해 fail 가능
- write latency가 높고, IOPS가 낮은 경우가 많음
-> Kafka의 안정성과 성능에 치명적일 수 있음
