+++
title = "리소스 이슈 인한 인프라 재구축"
draft = false
bookHidden = true
+++

### 상황
![resource issue](/troubleshooting/resource-request.png)

다음과 같은 이슈가 발생했다. 현재 구축된 스택은 ceph, minio, kafka, kafka-ui뿐인데, request&limit을 최적화했음에도 내 환경에서는 다소 버거운 것으로 보인다.
따라서 다음과 같은 결정을 하게됐다.

### 문제 원인
위 스택들의 request를 다음과 같이 최소화했을때
항목 | Before | After
|-|-|-|
Ceph OSD 5개 CPU 요청 | 2.5코어 | 1.5코어
Kafka Pod 3개 CPU 요청 | 1.5코어 | 0.9코어
Kafka-UI | 없음 | 0.1코어
총합 감소량 | 약 2.5~3코어 | 1.5코어 이상 확보

아래와 같이 리소스를 사용한다.
```sh
ubuntu@ctrl-node:~/kafka$ kubectl describe nodes | grep -A5 "Allocated resources"
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests       Limits
  --------           --------       ------
  cpu                1050m (43%)    1 (41%)
  memory             370760Ki (5%)  1280288k (17%)
--
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests        Limits
  --------           --------        ------
  cpu                900m (37%)      0 (0%)
  memory             210800640 (2%)  1024288k (13%)
--
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests        Limits
  --------           --------        ------
  cpu                800m (23%)      0 (0%)
  memory             137400320 (1%)  709715200 (9%)
--
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests          Limits
  --------           --------          ------
  cpu                1675m (69%)       1700m (70%)
  memory             2987972608 (18%)  6346859776 (40%)
--
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests         Limits
  --------           --------         ------
  cpu                2625m (77%)      2800m (82%)
  memory             4957750Ki (32%)  9165432064 (57%)
--
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests         Limits
  --------           --------         ------
  cpu                2675m (78%)      2300m (67%)
  memory             4752950Ki (30%)  10104956160 (63%)
--
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests         Limits
  --------           --------         ------
  cpu                2625m (77%)      2800m (82%)
  memory             4884022Ki (31%)  10373391616 (65%)
--
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests         Limits
  --------           --------         ------
  cpu                2375m (69%)      1400m (41%)
  memory             3835446Ki (24%)  8494343424 (53%)
```
현실적으로 턱없이 부족한 리소스다.


### 해결 방법
사실 해결을 했다기보단, 현실적인 대안을 찾게됐다.
1. Worker node 개수를 4대로 줄이고 리소스 추가 할당
2. Cloud Storage 도입

항목 | AWS | GCP | Azure
|-|-|-|-|
Block Storage | EBS (가장 안정적, 옵션 다양) | Persistent Disk (속도 좋음, 가격 저렴) | Managed Disk (무난함)
Object Storage | S3 (업계 표준, 생태계 최강) | GCS (가격 저렴, 성능 빠름) | Blob Storage (무난)
File Storage | EFS (비쌈) | Filestore (가격 적당, 성능 빠름) | Azure Files (가장 저렴)
총평 | "기업표준" & 비쌈 | "가격/성능 균형" 최고 | "비용 최저" 목적이면 고려

비용만 생각한다면 **Azure**가 최선이지만, 편의성을 고려하면 **AWS**나 **GCP**를 선택해야한다.
따라서 **GCP**의 스토리지들을 채택했다.
|Storage Type| Product|
|-|-|
|Block Storage| Balanced Persistent Disk (pd-balanced)|
|Object Storage| GCS Standard|
|File Storage|Filestore Basic HDD|
