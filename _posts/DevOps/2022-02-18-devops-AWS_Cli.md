---
title:  "[DevOps] AWS CLI"
excerpt: "AWS CLI"

categories:
  - DevOps
tags:
  - [DevOps]

toc: true
toc_sticky: true
 
date: 2022-02-18
last_modified_at: 2022-02-18
---
## AWS CLI [cli link](https://aws.amazon.com/cli)
[github_aws cli](https://github.com/aws/aws-cli)
- AWS 서비스 관리를 위한 CLI 명령형 도구

와... 진짜 몇주만에 성공했냐...  
이 부분은 vmware도 2번이나 갈아엎어보고 강의대로 해봐도 안되고... 참...  
결국에 pc까지 포맷했다가 이번엔 vm 안쓰고 직접 해봤다... 그래도 안됐다...  
강의는 Mac에서 virtualbox 쓰는 모양인데, 윈도우에선 진짜 chmod부터 시작해서 ./aws/config가 vim으로 안열린다!!!!!!!!  

답은 생각보다 간단했다...


1. 먼저 aws cli version 2를 다운받는다.  
[github cli 2](https://github.com/aws/aws-cli/tree/v2)
2. ```cat 자격증명.csv```로 Access Key Id와 Secret Access Key를 받는다.
3. ```aws configure```를 하면 정보 입력하는게 나온다.
4. 이때 위에서 받은 Key를 입력하고 region에는 ap-northeast-2를 입력한다.
5. default output format은 [site](https://docs.aws.amazon.com/ko_kr/cli/latest/userguide/cli-usage-output-format.html)에서 보면 된다.
나는 yaml으로 했다.
6. ```aws sts get-caller-identity```로 Account와 Arn, UserId를 본다.
(이때 겁나 조마조마했다....)
7. ```aws ec2 describe-key-pairs```를 보면 KeyPairId가 나온다.
계정에 들어가서 계정ID를 확인해본다. (드디어 맞았다....)

```aws configure --profile 새로운사용자명```으로 추가적인 세팅 가능  
__AWS_PROFILE__ 환경변수 혹은 __--profile__ 옵션을 사용해 특정 사용자 프로파일로 명령어 수행 가능
```aws sts get-caller-identity --profile=사용자명```으로 검색가능

#### AWS CLI 사용법
```aws <command> <subcommand> [options and parameters]```

디버그 모드 활성화  
```aws sts get-caller-identity --debug```