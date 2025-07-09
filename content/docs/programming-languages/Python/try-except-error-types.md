+++
title = "try-except에서 자주 보이는 에러 타입들"
draft = false
+++
## ValueError
- 값은 맞지만, 내용이 예상 범위가 아닐 때
- e.g. int("abc"), 날짜 포맷 잘못됨
```py
try:
    val = int("abc")
except ValueError:
    print("숫자로 변환할 수 없는 값입니다")
```

## TypeError
- 타입이 잘못되었을 때 (예: 문자열 + 숫자)
- e.g. 'abc' + 1, len(3)
```py
try:
    val = 'abc' + 1
except TypeError:
    print("타입이 맞지 않습니다")
```

## KeyError
- 딕셔너리나 DataFrame에서 없는 키를 접근
- e.g. my_dict['missing_key'], df['없는컬럼']
```py
try:
    val = df['gender']
except KeyError:
    print("해당 컬럼이 존재하지 않습니다")
```

## IndexError
- 리스트나 DataFrame의 인덱스 범위 초과
- e.g. my_list[10], df.iloc[100]
```py
try:
    val = my_list[10]
except IndexError:
    print("인덱스 범위를 초과했습니다")
```

## ZeroDivisionError
- 0으로 나누었을 때
- e.g. 1 / 0
```py
try:
    val = 1 / 0
except ZeroDivisionError:
    print("0으로 나눌 수 없습니다")
```

## FileNotFoundError
- 열려는 파일이 존재하지 않을 때
- e.g. open('abc.txt')
```py
try:
    with open('abc.txt') as f:
        data = f.read()
except FileNotFoundError:
    print("파일이 존재하지 않습니다")
```

## AttributeError
- 객체에 없는 속성/메서드를 사용하려 할때
- e.g. None.upper(), 123.append()
```py
try:
    val = None.upper()
except AttributeError:
    print("없는 속성 또는 메서드입니다")
```

## TypeError (함수 인자 문제 포함)
- 함수에 인자를 잘못 줬을 때
- e.g. sum(1, 2) -> sum은 iterable만 받음
```py
try:
    result = sum(1, 2)
except TypeError:
    print("함수 인자 오류")
```

## JSONDecodeError (from json module)
- JSON 문자열 파싱 실패
- e.g. json.loads('{bad json}')
```py
import json
try:
    data = json.loads('{"id": 1')  # 닫는 괄호 누락
except json.JSONDecodeError:
    print("JSON 파싱 실패")
```

## ModuleNotFoundError
- 없는 패키지를 import할 때
- e.g. import nonexist_module
```py
try:
    import nonexist_module
except ModuleNotFoundError:
    print("해당 모듈을 찾을 수 없습니다")
```

## NameError
- 선언되지 않은 변수를 사용
- e.g. print(x) (x 선언 안됨)
```py
try:
    print(undeclared_variable)
except NameError:
    print("정의되지 않은 변수입니다")
```

## PermissionError
- 읽기/쓰기 권한 없는 파일에 접근
- e.g. open('/root/file.txt', 'w')
```py
try:
    with open('/root/file.txt', 'w') as f:
        f.write('test')
except PermissionError:
    print("쓰기 권한이 없습니다")
```

## StopIteration
- next()로 더 이상 순회할 수 없을 때
- e.g. next(iterator)
```py
it = iter([1])
try:
    next(it)
    next(it)  # 여기서 예외
except StopIteration:
    print("더 이상 반복할 요소가 없습니다")
```

