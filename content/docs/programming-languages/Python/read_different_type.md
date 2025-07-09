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

### GeoJSON 위치 데이터
```py
# 목표: 박물관 이름과 위도/경도 좌표 추출
import geopandas as gpd

gdf = gpd.read_file("Museums_in_DC.geojson")

print(gdf[["NAME", "geometry"]].head())

print(gdf.describe())
print(gdf.info())
```

### WAV 오디오 파일
```py
# 목표: 오디오의 채널 수, 샘플링 레이트, 길이(sec) 출력
import wave

with wave.open("audio.wav", "rb") as wf:
    n_channels = wf.getnchannels()
    framerate = wf.getframerate()
    n_frames = wf.getnframes()
    duration = n_frames / float(framerate)

    print(f"Channels: {n_channels}")
    print(f"Sample Rate: {framerate}")
    print(f"Duration : {duration: .2f} seconds")
```

### 이미지 메타데이터
```py
# 목표: 이미지 크기 및 모드 출력
from PIL import Image

for path in ["matplotlib.png", "marie.png"]:
    with Image.open(path) as img:
        print(f"{path} -> size : {img.size}, mode: {img.mode}")
```