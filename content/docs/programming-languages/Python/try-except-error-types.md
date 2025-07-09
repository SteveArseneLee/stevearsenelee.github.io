+++
title = "try-except에서 자주 보이는 에러 타입들"
draft = true
+++
## ValueError
- 값은 맞지만, 내용이 예상 범위가 아닐 때
- e.g. ```int("abc")```, 날짜 포맷 잘못됨
```py
try:
    val = int("abc")
except ValueError:
    print("숫자로 변환할 수 없는 값입니다")
```

## TypeError
- 타입이 잘못되었을 때 (예: 문자열 + 숫자)
- 'abc' + 1, len(3)
```py
try:
    val = 'abc' + 1
except TypeError:
    print("타입이 맞지 않습니다")
```

## KeyError
- 딕셔너리나 DataFrame에서 없는 키를 접근
- my_dict['missing_key'], df['없는컬럼']
```py
try:
    val = df['gender']
except KeyError:
    print("해당 컬럼이 존재하지 않습니다")
```