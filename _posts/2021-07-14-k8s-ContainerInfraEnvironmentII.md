---
title:  "[Docker&Kubernetes] Container Infra Environment II"
excerpt: "Service"

categories:
  - Docker&Kubernetes
tags:
  - [Docker&Kubernetes]

toc: true
toc_sticky: true
 
date: 2021-07-14
last_modified_at: 2021-07-14
---
## Service

외부에서 쿠버네티스 클러스터에 접속하는 방법

### NodePort

외부에서 쿠버네티스 클러스터의 내부에 접속하는 가장 쉬운 방법

## Ingress

고유한 주소를 제공해 사용 목적에 따라 다른 응답을 제공할 수 있고, 트래픽에 대한 L4/L7 로드밸런서와 보안 인증서를 처리하는 기능 제공

### NGINX 인그레스 컨트롤러 작동 단계

1. 사용자는 노드마다 설정된 노드포트를 통해 노드포트 서비스로 접속. 이때 노드포트 서비슬르 NGINX 인그레스 컨트롤러로 구성
2. NGINX 인그레스 컨트롤러는 사용자의 접속 경로에 따라 적합한 클러스터 IP 서비스로 경로 제공
3. 클러스터 IP 서비스는 사용자를 해당 파드로 연결해줌
>인그레스 컨트롤러는 파드와 직접 통신할 수 없어서 노드포트 또는 로드밸런서 서비스와 연동되어야 함

실습

1. 테스트용으로 디플로이먼트 2개 배포

    ```docker
    kubectl create deployment in-hname-pod --image=sysnet4admin/echo-hname
    kubectl create deployment in-ip-pod --image=sysnet4admin/echo-ip
    ```

2. 배포된 파드의 상태 확인

    ```docker
    kubectl get pods
    ```

3. NGINX 인그레스 컨트롤러 설치

    ```docker
    kubectl apply -f ~/_Book_k8sInfra/ch3/3.3.2/ingress-nginx.yaml
    ```

4. NGINX 인그레스 컨트롤러의 파드가 배포됐는지 확인. NGINX 인그레스 컨트롤러는 default 네임스페이스가 아닌 ingress-nginx 네임스페이스에 속하므로 -n ingress-nginx 옵션 추가해야 함. 여기서 -n은 namespace의 약어로, default 외의 네임스페이스를 확인할 때 사용하는 옵션. 파드뿐만 아니라 서비스를 확인할 떄도 동일한 옵션 줌.

    ```docker
    kubectl get pods -n ingress-nginx
    ```

5. 인그레스를 사용자 요구 사항에 맞게 설정하려면 경로와 작동을 정의해야 함.

    ```docker
    kubectl apply -f ~/_Book_k8sInfra/ch3/3.3.2/ingress-config.yaml
    ```

6. 인그레스 설정 파일이 제대로 등록됐는지 kubectl get ingress로 확인

## LoadBalancer

로드밸런서를 사용하려면 로드밸런서를 이미 구현해 둔 서비스업체의 도움을 받아 쿠버네티스 클러스터 외부에 구현해야 함

- MetalLB : bare metal로 구성된 쿠버네티스에서도 로드밸런서를 사용할 수 있게 고안된 프로젝트. MetalLB는 특별한 네트워크 설정이나 구성이 있는 것이 아니라 기존읜 L2 네트워크와 L3 네트워크로 로드밸런서 구현.
- MetalLB 컨트롤러는 프로토콜을 정의하고 EXTERNAL-IP를 부여해 관리.
- MetalLB speaker는 정해진 작동 방식에 따라 경로를 만들 수 있도록 네트워크 정보를 광고하고 수집해 각 파드의 경로를 제공.

<실습>

1. 디플로이먼트를 이용해 2종류의 파드 생성. 그리고 scale 명령으로 파드를 3개로 늘려 노드 당 1개씩 파드가 배포되게 함

    ```docker
    kubectl create deployment lb-hname-pods --image=sysnet4admin/echo-hname
    kubectl scale deployment lb-hname-pods --replicas=3
    kubectl create deployment lb-ip-pods --image=sysnet4admin/echo-ip
    kubectl scale deployment lb-ip-pods --replicas=3
    ```

2. 2종류의 파드가 3개씩 배포됐는지 확인

    ```docker
    kubectl get pods
    ```

3. 오브젝트 스펙으로 MetalLB 구성

    ```docker
    kubectl apply -f ~/_Book_k8sInfra/ch3/3.3.4/metallb.yaml
    ```

4. 배포된 MetalLB의 파드가 5개(controller 1개, speaker 4개)인지 확인하고 IP와 상태 확인

    ```docker
    kubectl get pods pods -n metallb-system -o wide
    ```

5. MetalLB 설정

    ```docker
    kubectl apply -f ~/_Book_k8sInfra/ch3/3.3.4/metallb-l2config.yaml
    ```

6. ConfigMap이 생성됐는지 확인

    ```docker
    kubectl get configmap -n metallb-system
    ```

7. -o yaml 옵션을 주고 다시 실행해 MetalLB 설정이 올바르게 적용됐는지 확인

    ```docker
    kubectl get configmap -n metallb-system -o yaml
    ```

8. 모든 설정이 완료됐으면 각 디플로이먼트를 로드밸런서 서비스로 노출

    ```docker
    kubectl expose deployment lb-hname-pods --type=LoadBalancer --name=lb-hname-svc --port=80
    kubectl expose deployment lb-ip-pods --type=LoadBalancer --name=lb-ip-svc --port=80
    ```

9. 생성된 로드밸런서 서비스별로 CLUSTER-IP와 EXTERNEL-IP가 잘 적용됐는지 확인. 특히 EXTERNAL-IP에 ConfigMap을 통해 부여한 IP 확인

    ```docker
    kubectl get services
    ```

## HPA (Horizontal Pod Autoscaler)

쿠버네티스는 부하량에 따라 디플로이먼트의 파드 수를 유동적으로 관리하는 기능 제공

<실습>

1. 디플로이먼트 1개를 hpa-hname-pods라는 이름으로 생성

    ```docker
    kubectl create deployment hpa-hname-pods --image=sysnet4admin/echo-hname
    ```

2. MetalLB를 구성했으므로 expose를 실행해 hpa-hname-pods를 로드밸런서 서비스로 바로 설정 가능

    ```docker
    kubectl expose deployment hpa-hname-pods --type=LoadBalancer --name=hpa-hname-svc --port=80
    ```

3. 설정된 로드밸런서 서비스와 부여된 IP를 확인

    ```docker
    kubectl get services
    ```

4. HPA가 작동하려면 파드의 자원이 어느 정도 사용되는지 파악해야 함. 부하를 확인하는 명령은 리눅스의 top과 비슷한 kubectl top pods

    ```docker
    kubectl top pods
    ```

    - HPA가 자원을 요청할 때 Metrics-Server를 통해 계측값을 전달받기 떄문에 Metrics-Server를 미리 설정해야 함
5. Metrics-Server 생성

    ```docker
    kubectl create -f ~/_Book_k8sInfra/ch3/3.3.5/metrics-server.yaml
    ```

6. Metrics-Server를 설정했으니 kubectl top pods 명령

    ```docker
    kubectl top pods
    ```

7. edit 명령을 통해 배포된 디플로이먼트 내용 확인.

    ```docker
    kubectl edit deployment hpa-hname-pods
    ## 여기서 resources 내용 바꿈
    ```

8. kubectl top pods로 스펙 변경된거 확인

    ```docker
    kubectl top pods
    ```

9. hpa-hname-pods에 autoscale을 설정해 특정 조건이 만족되는 경우 자동으로 scale 명령이 수행되도록 함.

    ```docker
    kubectl autoscale deployment hpa-hname-pods --min=1 --max=30 --cpu-percent=50
    ```