---
title:  "[Vision] 시작"
excerpt: "Vision 시작"

categories:
  - Vision
tags:
  - [Vision]

toc: true
toc_sticky: true
 
date: 2021-07-19
last_modified_at: 2021-07-19
---
### Object Detection & Segmentation
- Localization : 단 하나의 Object 위치를 Bounding box로 지정해 찾음
- Object Detection : 여러 개의 Object들에 대한 위치를 Bounding Box로 지정해 찾음
- Segmentation : Detection보다 더 발전된 형태로 Pixel 레벨 Detection 수행

- Localization/Detection은 해당 Object의 위치를 Bounding Box로 찾고, Bounding Box내의 오브젝트를 판별
- Localization/Detection은 Bounding Box regression(box의 좌표값을 예측)과 Classification 두개의 문제가 합쳐져 있음
- Localization에 비해 Detection은 두개 이상의 Object를 이미지의 임의 위치에서 찾아야 하므로 상대적으로 Localization보다 여러가지 여러운 문제에 봉착

### Object Detection의 주요 구성 요소
- 영역 추정
  - Region Proposal
- Detection을 위한 Deep Learning 네트워크 구성
  - Feature Extraction, FPN, Network Prediction
- Detection을 구성하는 기타 요소
  - IOU, NMS, mAP, Anchor box


### Object Detection의 난제
- Classification + Regression을 동시에
  - 이미지에서 여러 개의 물체를 classification함과 동시에 위치를 찾아야 함
- 다양한 크기와 유형의 오브젝트가 섞임
  - 크기가 서로 다르고, 생김새가 다양한 오브젝트가 섞인 이미지에서 이들을 Detect
- 중요한 Detect 시간
  - Detect 시간이 중요한 실시간 영상 기반에서 Detect해야 하는 요구사항 증대
- 명확하지 않은 이미지
  - 오브젝트 이미지가 명확하지 않은 경우가 많음. 또한 전체 이미지에서 Detect할 오브젝트가 차지하는 비중이 높지 않음.
- 데이터 세트의 부족
  - 훈련 가능한 데이터 세트가 부족하며 annotation을 만들어야 해서 훈련 데이터 세트를 생성하기가 상대적으로 어려움

### Object Localization 개요
원본 이미지 -> Feature Extractor -> Feature Map -> FC Layer -> Soft max Class score

### Sliding Window 방식
Window를 왼쪽 상단에서부터 오른쪽 하단으로 이동시키면서 Object를 Detection하는 방식
  - 다양한 형태의 Window를 각각 sliding 시키는 방식
  - Window Scale은 고정하고 scale을 변경한 여러 이미지를 사용하는 방식
- Object Detection의 초기 기법으로 활용
- 오브젝트 없는 영역도 무조건 슬라이딩해야하며 여러 형태의 Window와 여러 Scale을 가진 이미지를 스캔해서 검출해야해서 수행시간이 오래걸리고 검출 성능이 상대적으로 낮음
- Region Proposal(영역 추정) 기법의 등장으로 활용도는 떨어졌지만 Object Detection 발전을 위한 기술적 토대 제공

### Object Detection - 두개 이상의 Object를 검출




