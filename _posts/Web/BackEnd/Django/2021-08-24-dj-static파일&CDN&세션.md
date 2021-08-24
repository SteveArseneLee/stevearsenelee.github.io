---
title:  "[Django] 로그인(세션) & Static파일 & CDN"
# excerpt: ""

categories:
  - Django
tags:
  - [Programming, python]

toc: true
toc_sticky: true
 
date: 2021-08-24
last_modified_at: 2021-08-24
---
프로젝트 내에 static폴더를 생성하고, settings.py에
```python
STATICFILES_DIRS = [
    os.path.join(BASE_DIR, 'static'),
]
```
를 통해 어느 폴더에 있는지를 알려준다.
기존에는 CDN으로 css를 적용했다면, 이번에는 [Bootstrap 4.3 themes free 검색결과](https://bootswatch.com/)의 테마를 사용하겠다.
테마를 골랐다면 다운 후 static 폴더 안에 넣고 ```<link rel="stylesheet" href="/static/bootstrap.min.css" />```를 html에 넣어준다.


### 로그인 
```python

```

```python
```

```python
```