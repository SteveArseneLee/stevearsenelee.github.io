+++
title = "여러 가지 형식의 파일 입출력"
draft = false
+++
### CSV
```python
import pandas as pd
# 1. 데이터 불러오기
df = pd.read_csv('test.csv')
```

### Vega-lite JSON
```python
import json
import pandas as pd

with open('test.vl.json', 'r') as f:
    spec = json.load(f)

df = pd.DataFrame(spec["data"]["values"])
```

### FASTA
```python
from Bio import SeqIO

for record in SeqIO.parse("test.fasta", "fasta"):
    print(f"ID : {record.id}, Length: {len(record.seq)}")
```