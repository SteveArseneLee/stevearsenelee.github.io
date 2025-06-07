+++
title = "Ceph를 구축하며 발생한 cpu 이슈.."
draft = false
+++


### 상황
> Ceph 클러스터를 Kubernetes에 구축하는 과정 중,
csi-rbdplugin, csi-cephfsplugin, csi-snapshotter 등의 csi-* 계열 Pod들이 CrashLoopBackOff 또는 Error 상태로 지속적으로 실패함.

### 문제 원인
1. Ceph과 glibc의 관계
- Ceph은 내부적으로 glibc(GNU C Library)를 사용하여 시스템 호출과 메모리 관리를 수행함.
- 최신 Ceph(v18, v19) 버전은, 최신 glibc(>=2.34) 기반으로 빌드되어 있음.
- 이 glibc 버전들은 CPU가 'x86-64-v2' 명령어 집합을 지원한다고 가정하고 최적화되어 있음.

2. x86-64-v2란?
> x86-64-v2는 기존 x86-64 아키텍처보다 더 발전된 명령어 집합(Instruction Set)을 의미함.

필수 지원 명령어는 다음과 같음:
플래그 | 설명
|-|-|
sse3 | 스트리밍 SIMD 확장(SSE3)
ssse3 | 보강된 스트리밍 SIMD 확장(SSSE3)
sse4_1 | 스트리밍 SIMD 확장(SSE4.1)
sse4_2 | 스트리밍 SIMD 확장(SSE4.2)
popcnt | 비트 카운트(Population Count)
cx16 | 16바이트 비교/교환(CMPXCHG16B)

이 중 하나라도 CPU가 지원하지 않으면 glibc가 오류를 발생시키고, Ceph 데몬이 프로세스 레벨에서 바로 죽음.

3. 가상화 환경의 문제
- KVM/QEMU 환경에서는 기본적으로 "QEMU Virtual CPU"라는 에뮬레이션 CPU를 VM에게 제공함.
- 이 기본 설정은 x86-64-v2 명령어 지원이 없음.
- 따라서 Ceph 데몬(특히 mon, mgr, osd 등)이 초기화될 때, 필수 명령어를 찾지 못해 에러 발생 → Pod Crash로 이어짐.

#### 확인 방법
VM 또는 Kubernetes Node에서 다음 명령어 실행
```sh
lscpu | grep Flags
# or
cat /proc/cpuinfo | grep flags
```
- 출력 결과에 sse3, ssse3, sse4_1, sse4_2, popcnt, cx16 등이 반드시 포함되어 있어야 함.
- 만약 포함되지 않았다면, 해당 VM은 x86-64-v2 기준을 만족하지 않음.




### 해결 방법
항목 | 설정값 | 이유
|-|-|-|
CPU Type | Host Passthrough | 물리 CPU의 모든 기능을 VM에 직접 전달하여 x86-64-v2 명령어 지원 보장
Emulated Machine | 기존과 동일 (예: pc-q35-6.2) | 별도 변경 불필요
디스크 포맷 | qcow2 | 성능과 스냅샷 기능을 동시에 고려
부팅 디스크 | 30GB ~ 50GB | Kubernetes OS용 디스크 사이즈
추가 디스크 | 필요시 추가 | Ceph OSD 디스크용 등
Firmware | BIOS | 기존 환경 유지
vCPU | 계획한 대로 (ex: master 3core, worker 4core) | 
Memory | 계획한 대로 (ex: master 8GB, worker 16GB) | 
네트워크 | Bridge 연결 (br0 등) | Kubernetes 클러스터 통신을 위해


## 요약
QEMU 기본 CPU → x86-64-v2 명령어 미지원 → 최신 glibc 기반 Ceph 데몬 죽음 → csi-*, mon, mgr Pod Crash.
→ VM 생성 시 Host Passthrough 설정 필수!
