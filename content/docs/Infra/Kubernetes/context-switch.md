+++
title = "여러 환경의 클러스터를 손쉽게 관리하기"
draft = false
+++
### 1. 원격 클러스터의 kubeconfig 받아오기
```sh
sudo cat /etc/kubernetes/admin.conf
```

### 2. 로컬 파일에 저장 내 경우
```sh
~/kubeconfig
|- kubeconfig-cluster1
|- kubeconfig-cluster2
|- ...
```
이런식으로 저장했음.

### 3. context, cluster, name이 중복되면 안돼서 변환해주는 스크립트 사용
auto-context.sh
```sh
#!/bin/bash
set -e

if [ $# -ne 1 ]; the원
  echo "❗ 사용법: $0 <kubeconfig-파일 경로>"
  exit 1
fi

INPUT_PATH="$1"
FILENAME=$(basename "$INPUT_PATH")
CLUSTER_ID="${FILENAME#kubeconfig-}"

echo "📌 클러스터 ID: $CLUSTER_ID"
echo "📂 대상 kubeconfig: $INPUT_PATH"

# 🔄 기존 등록 삭제
kubectl config delete-context ${CLUSTER_ID}-context 2>/dev/null || true
kubectl config delete-cluster ${CLUSTER_ID}-cluster 2>/dev/null || true
kubectl config delete-user ${CLUSTER_ID}-user 2>/dev/null || true

# 🔍 정보 추출
SERVER=$(KUBECONFIG=$INPUT_PATH kubectl config view -o jsonpath="{.clusters[0].cluster.server}")
CERT_AUTH_DATA=$(KUBECONFIG=$INPUT_PATH kubectl config view -o jsonpath="{.clusters[0].cluster.certificate-authority-data}")
CLIENT_CERT_DATA=$(KUBECONFIG=$INPUT_PATH kubectl config view -o jsonpath="{.users[0].user.client-certificate-data}")
CLIENT_KEY_DATA=$(KUBECONFIG=$INPUT_PATH kubectl config view -o jsonpath="{.users[0].user.client-key-data}")

# 🔧 base64 decode → temp 파일
CA_FILE=$(mktemp)
CERT_FILE=$(mktemp)
KEY_FILE=$(mktemp)

echo "$CERT_AUTH_DATA" | base64 -d > "$CA_FILE"
echo "$CLIENT_CERT_DATA" | base64 -d > "$CERT_FILE"
echo "$CLIENT_KEY_DATA" | base64 -d > "$KEY_FILE"

# ✅ 완전 등록 (PEM 파일 방식)
kubectl config set-cluster ${CLUSTER_ID}-cluster \
  --server="$SERVER" \
  --certificate-authority="$CA_FILE" \
  --embed-certs=true

kubectl config set-credentials ${CLUSTER_ID}-user \
  --client-certificate="$CERT_FILE" \
  --client-key="$KEY_FILE" \
  --embed-certs=true

kubectl config set-context ${CLUSTER_ID}-context \
  --cluster=${CLUSTER_ID}-cluster \
  --user=${CLUSTER_ID}-user

# 🔁 병합
echo "🔁 병합 중..."
MERGE_TARGETS=$(find ~/kubeconfig -type f -name 'kubeconfig-*' | tr '\n' ':' | sed 's/:$//')
KUBECONFIG=$MERGE_TARGETS kubectl config view --flatten > ~/.kube/config
chmod 600 ~/.kube/config

# 🧹 임시 파일 정리
rm -f "$CA_FILE" "$CERT_FILE" "$KEY_FILE"

echo "✅ 병합 완료: ~/.kube/config 갱신됨"
```

### 4. config 파일 수정
config 파일을 처음 받아오면 certificate-authority-data 등의 데이터에 ```DATA+OMITTED```라고 써있는 경우가 있다. 이런 경우 실제 데이터로 바꿔준다.
```sh
base64 -w 0 /etc/kubernetes/pki/ca.crt  # 서버에서 추출해서
```

### 5. 이제 위 config를 사용해 자동으로 context를 바꾸기
/usr/local/bin/usr에 sc라는 파일을 만들어주고
```sh
#!/bin/zsh

autoload -Uz colors && colors

typeset -A CLUSTERS
CLUSTERS=(
  1 context1
  2 context2
  3 context3
)

typeset -A DESCRIPTIONS
DESCRIPTIONS=(
  1 "🎯 Description of context1"
  2 "🧪 Description of context2"
  3 "💻 Description of context3"
)

ORDER=(1 2 3)  # 순서 고정

current_context=$(kubectl config current-context 2>/dev/null)

echo ""
echo "${fg[cyan]}🌐 Kubernetes Context Switcher v3.0${reset_color}"
echo "${fg[white]}──────────────────────────────────────────────${reset_color}"

for key in "${ORDER[@]}"; do
  ctx=${CLUSTERS[$key]}
  desc=${DESCRIPTIONS[$key]}
  if [[ "$ctx" == "$current_context" ]]; then
    printf " %s) ${fg[green]}%s${reset_color} %s ${fg[yellow]}(현재 선택됨)${reset_color}\n" "$key" "$ctx" "$desc"
  else
    printf " %s) ${fg[white]}%s${reset_color} %s\n" "$key" "$ctx" "$desc"
  fi
done

echo "${fg[white]}──────────────────────────────────────────────${reset_color}"
echo ""
read "choice?🔢 번호 입력: "

context="${CLUSTERS[$choice]}"

if [[ -n "$context" ]]; then
  echo ""
  echo "${fg[blue]}🔁 전환 중...${reset_color}"
  kubectl config use-context "$context"

  echo "${fg[blue]}📡 클러스터 상태 확인 중...${reset_color}"
  if kubectl get nodes &>/dev/null; then
    echo "${fg[green]}✅ 연결 성공!${reset_color}"
  else
    echo "${fg[red]}❌ 연결 실패. VPN이나 네트워크 상태를 확인하세요.${reset_color}"
  fi
else
  echo "${fg[red]}❌ 유효하지 않은 선택입니다.${reset_color}"
  exit 1
fi
```
