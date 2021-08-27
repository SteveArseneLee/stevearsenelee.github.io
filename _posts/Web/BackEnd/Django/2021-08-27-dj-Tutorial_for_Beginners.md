---
title:  "[Django] Django-Django for Beginners"
excerpt: "강의 정리"

categories:
  - Django
tags:
  - [Programming, python, Backend]

toc: true
toc_sticky: true
 
date: 2021-08-27
last_modified_at: 2021-08-27
---
## Django Tutorial for Beginners
### 기본 환경 생성
이번 포스트는 [Youtube](https://www.youtube.com/watch?v=rHux0gMZ3Eg&t=273s)를 보고 정리한 내용입니다.
```shell
➜  Desktop mkdir storefront
➜  Desktop cd storefront
➜  storefront pipenv install django
```
1. **storefront**라는 폴더를 먼저 생성합니다.
2. **storefront**라는 폴더에 가상으로 장고를 설치합니다.

여기서 ```ls```를 하면 Pipfile과 Pipfile.lock가 자동으로 깔려있는 것을 볼 수 있습니다.

Pipfile을 들어가보면 ```django = "*"```가 있는데 이는 어떤 버전의 장고든 사용가능하다는 뜻이고, ```python_version = "파이썬 버전"```은 가상 환경을 생성할 때 지정했던 파이썬 버전이 명시되어 있음을 알 수 있습니다.


쉘에서 다시 ```pipenv shell```을 쳐보도록 합니다. 이 명령어는 지정한 파이썬 버전의 환경을 실행하는 것을 말합니다. 

### StartProject
```django-admin startproject storefront .```를 통해 현재 폴더에 프로젝트를 생성합니다.
