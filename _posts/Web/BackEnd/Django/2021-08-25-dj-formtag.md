---
title:  "[Django] Django-Form활용하기"
excerpt: "Django의 form 활용"

categories:
  - Django
tags:
  - [Programming, python, Backend]

toc: true
toc_sticky: true
 
date: 2021-08-25
last_modified_at: 2021-08-25
---
## Django의 Form 활용하기
이번엔 django의 form을 활용해서 기존의 필드를 깔끔하게 만들어보겠다.
먼저, **forms.py**를 만들고 
```python
from django import forms

class LoginForm(forms.Form):
    username = forms.CharField(max_length=32)
    password = forms.CharField()
```

**views.py**를 다음과 같이 변경해주면
```python
def login(request):
    form = LoginForm()
    return render(request, 'login.html', {'form':form})
```
**login.html**에서 ```form```을 사용한다. 그러면 기존과는 다른 창이 나올것이다. 이는 장고에서 제공하는 폼인데 한곳을 입력하지 않으면 에러가 뜨는 식으로 자동으로 에러처리가 된다. 하지만 에러와는 별개로 비밀번호같은 경우 텍스트형식으로 떠서 다 보인다... 이제 그걸 처리해보겠다.

그 전에 form의 기능을 약간 소개하면 ```forms.as_p```로 하면 각 필드를 p태그로 감싼다는 느낌이다. 이외에는 ```form.as_table```이 있다.


```
```

```
```

``````
