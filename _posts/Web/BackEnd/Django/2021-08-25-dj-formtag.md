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

#### 값의 유무
필드를 새로 만들었기 때문에
```python
if request.method == 'POST':
        form = LoginForm(request.POST)
        # 유효성 검사
        if form.is_valid():
            # session
            return redirect('/')
```
이렇게 새로운 형식을 **login 함수**에 넣어주었다. 위에 **is_valid()** 는 입력을 다 했는지 확인하는 것이다.

#### 비밀번호의 일치/불일치
```python
def clean(self):
        cleaned_data = super().clean()
```
super를 통해 기존 Form안에 들어있던 clean함수를 먼저 호출해준다. 만약 값이 들어있지 않으면 ```cleaned_data = super().clean()```에서 실패처리가 되서 나간다.

이번 포스트로 **forms.py**를 만들었고 이를 통해 유효성 검사나 데이터 검증을 처리할 수 있어서 **views.py**가 매우 깔끔해졌다.

정리된 **forms.py**
```python
from django import forms
from .models import Fcuser
from django.contrib.auth.hashers import check_password

class LoginForm(forms.Form):
    username = forms.CharField(
        error_messages={
            'required' : '아이디를 입력해주세요.'
        },
        max_length=32, label="사용자 이름")
    password = forms.CharField(
        error_messages= {
            'required':'비밀번호를 입력해주세요.'  
        },
        widget=forms.PasswordInput, label="비밀번호")
    
    def clean(self):
        cleaned_data = super().clean()
        username = cleaned_data.get('username')
        password = cleaned_data.get('password')
        
        # 각 값이 들어있을 때
        if username and password:
            fcuser = Fcuser.objects.get(username=username)
            if not check_password(password, fcuser.password):
                self.add_error('password', '비밀번호를 틀렸습니다')
            else:
                self.user_id = fcuser.id
```

정리된 **views.py**
```python
from django.http import HttpResponse
from django.shortcuts import render, redirect
from django.contrib.auth.hashers import make_password, check_password
from .models import Fcuser
from .forms import LoginForm

def home(request):
    user_id = request.session.get('user')
    
    if user_id:
        fcuser = Fcuser.objects.get(pk=user_id)
        return HttpResponse(fcuser.username)
        
    return HttpResponse('Home!')

def logout(request):
    if request.session.get('user'):
        del(request.session['user'])
    
    return redirect('/')

def login(request):
    if request.method == 'POST':
        form = LoginForm(request.POST)
        # 유효성 검사
        if form.is_valid():
            # session
            request.session['user'] = form.user_id
            return redirect('/')
    else:
        form = LoginForm()
    return render(request, 'login.html', {'form':form})
    
    # if request.method == 'GET':
    #     return render(request, 'login.html')
    # elif request.method == 'POST':
    #     username = request.POST.get('username', None)
    #     password = request.POST.get('password', None)
        
    #     res_data = {}
    #     if not (username and password):
    #         res_data['error'] = '모든 값을 입력해야합니다.'
    #     else:
    #         # 다시 Fcuser라는 모델에서 정보를 가져옴
    #         fcuser = Fcuser.objects.get(username=username)
    #         if check_password(password, fcuser.password):
    #             # 비밀번호가 일치, 로그인 처리
    #             # 세션!
    #             request.session['user'] = fcuser.id
    #             # redirect로 다시 홈으로 돌아가기
    #             return redirect('/') # /을 쓰면 현재 쓰는 웹 사이트의 root로 감
    #         else:
    #             res_data['error'] = '비밀번호를 틀렸습니다.'
        
        # return render(request, 'login.html', res_data)
        

# Create your views here.
def register(request):
    if request.method == 'GET':
        return render(request, 'register.html')
    elif request.method == 'POST':
        username = request.POST.get('username', None)
        useremail = request.POST.get('useremail', None)
        password = request.POST.get('password', None)
        re_password = request.POST.get('re-password', None)
        
        # Error 메세지를 담는 공간
        res_data={}
        
        if not (username and useremail and password and re_password):
            res_data['error'] = '모든 값을 입력해야합니다'
        elif password != re_password:
            # return HttpResponse('비밀번호가 다릅니다')
            res_data['error'] = '비밀번호가 다릅니다'
        else:       
            fcuser = Fcuser(
                username = username,
                useremail = useremail,
                password = make_password(password)
            )
            
            fcuser.save()
        
        return render(request, 'register.html', res_data)
        ```

``````
``````
``````

