---
title:  "[Vision] Tensorflow"
excerpt: "Tensorflow"

categories:
  - Vision
tags:
  - [Vision]

toc: true
toc_sticky: true
 
date: 2021-07-29
last_modified_at: 2021-07-29
---

```python
import numpy as np
import tensorflow as tf
```
Tensor 생성
```python
# List 생성
[1,2,3]
[[1,2,3],[4,5,6]]
```
Array 생성
- tuple이나 list 둘 다 np.array()로 씌워서 array를 만들 수 있음
```python
arr = np.array([1,2,3])
arr.shape
```
#### Tensor 생성
- tf.constant()
    - list -> Tensor
```python
tf.constant([1,2,3])
```
- tf.constant()
    - tuple -> Tensor
```python
tf.constant(((1,2,3),(1,2,3)))
```
- tf.constant()
    - Array -> Tensor
```python
arr = np.array([1,2,3])
tensor = tf.constant(arr)
```

#### Tensor에 담긴 정보 확인
- shape 확인
```python
tensor.shape()
```
- data type 확인
    - Tensor 생성할 때도 data type을 정해주지 않아서 data type에 대한 혼동이 올 수 있음
    - Data Type 에 따라 모델의 무게나 성능 차이에도 영향을 줄 수 있음
```python
tensor.dtype
```
- data type 정의
```python
tf.constant([1,2,3], dtype=tf.float32)
```
- data type 변환
    - Numpy에서 astype()을 주듯이, Tensorflow에선 tf.cast사용
```python
arr = np.array([1,2,3], dtype=np.float32)
arr.astype(np.unit8)

tensor =  tf.constant([1,2,3], dtype=tf.float32)
tf.cast(tensor, dtype=tf.unit)
```

#### 난수 생성
- numpy에선 nomral distribution을 기본적으로 생성
    - np.random.randn()
```python
np.random.randn(9)
```
- tf.random.normal
```python
tf.random.normal(([3,3]))
```
- tf.random.uniform
```python
tf.random.uniform(([4,4]))
```

### Data Preprocess(MNIST)
```python
import numpy as np
import matplotlib.pyplot as plt

import tensorflow as tf
%matplotlib inline
```
#### 데이터 불러오기
Tensorflow에서 제공해주는 데이터셋(MNIST)예제 불러오기
```python
from tensorflow.keras import datasets
```
데이터 shape 확인하기
```python
mnist = datasets.mnist
(train_x, train_y), (test_x, test_y) = mnist.load_data()
train_x.shape
```

## Layer Explaination

```python
import tensorflow as tf
```
### Input Image
Input으로 들어갈 DataSet을 들여다보면서 시각화
- os
- glob
- matplotlib
```python
import matplotlib.pyplot as plt
%matplotlib inline
from tensorflow.keras import datasets

(train_x, train_y), (test_x, test_y) = datasets.mnist.load_data()

image = train_x[0]
image.shape
```
[batch_size, height, width, channel]
```python
# plt.imshow(image, 'gray')
# plt.show()
image = image[tf.newaxis, ... , tf.newaxis]
image.shape
```
### Convolution
- filters : layer에서 나갈 때 몇 개의 filter를 만들 것인지 (weights, filters, channels)
- kernel_size : filter(Weight)의 사이즈
- strides : 몇 개의 pixel을 skip하면서 훑어지나갈 것인지(사이즈에도 영향을 줌)
- padding : zero padding을 만들 것인지, VALID는 Padding이 없고, SAME은 Padding이 있음(사이즈에도 영향을 줌)
- activation : Activation Function을 만들것인지, 당장 설정 안해도 Layer층을 따로 만들 수 있음

```python
tf.keras.layers.Conv2D(filters=3, kernel_size=(3,3), strides=(1,1), padding='SAME', activation='relu')
```
(3,3) 대신에 3으로도 대체 가능
```python
tf.keras.layers.Conv2D(3,3,1,'SAME')
```

### Visualization
- tf.keras.layers.Conv2D
```python
image
image = tf.cast(image, dtype=tf.float32)
image.dtype

tf.keras.layers.Conv2D(3,3,1,padding='SAME')
# tf.keras.layers.Conv2D(5,3,1,padding='VALID')
layer

output = layer(image)
output

# import numpy as np
# np.min(image), np.max(image)

# np.min(output), np.max(output)

plt.subplot(1,2,1)
plt.imshow(image[0,:,:,0], 'gray')
plt.subplot(1,2,2)
plt.imshow(output[0,:,:,0], 'gray')
plt.show()
```

weight 불러오기
- layer.get_weights()
```python
weight = layer.get_weights()[0]
len(weight)
# weight의 모양
weight[0].shape
# bias
weight[1].shape
plt.figure(figsize=(15,5))
plt.subplot(131)
plt.hist(output.numpy().ravel(), range=[-2,2])
plt.ylim(0,100)
plt.subplot(132)
plt.title(weight[0].shape)
plt.subplot(133)
plt.title(output.shape)
plt.imshow(output[0,:,:,0], 'gray')
plt.colorbar()
plt.show()
```

```python
import numpy as np
np.min(output), np.max(output)

tf.keras.layers.ReLU()
act_layer = tf.keras.layers.ReLU()
act_output = act_layer(output)

output.shape, act_output
np.min(output), np.max(output)

plt.figure(figsize=(15,5))
plt.subplot(121)
plt.hist(act_output.numpy().ravel(), range=[-2,2])
ply.ylim(0,100)

plt.subplot(122)
plt.title(act_output.shape)
plt.imshow(act_output[0,:,:,0], 'gray')
plt.show()
```

### Pooling
- tf.keras.layers.MaxPool2D
```python
tf.keras.layers.MaxPool2D(pool_size=(2,2), strides=(2,2), padding='SAME')

pool_layer = tf.keras.layers.MaxPool2D(pool_size=(2,2), strides=(2,2), padding='SAME')
pool_output = pool_layer(act_output)

plt.figure(figsize=(15,5))
plt.subplot(121)
plt.hist(pool_output.numpy().ravel(), range=[-2,2])
plt.ylim(0,100)

plt.subplot(122)
plt.title(pool_output.shape)
plt.imshow(pool_output[0,:,:,0], 'gray')
plt.colorbar()
plt.imshow()
```

## Classification
### Fully Connected
- tf.keras.layers.Flatten()
```python
import tensorflow as tf

tf.keras.layers.Flatten()

layer = tf.keras.layers.Flatten()
flatten = layer(output)
flatten.shape

# 시각화
plt.figure(figsize=(10,5))
plt.subplot(211)
plt.hist(flatten.numpy().ravel())
plt.subplot(212)
plt.imshow(flatten[:,:,100])
plt.show()
```

### Dense
- tf.keras.layers.Dense
```python
tf.keras.layers.Dense(32, activation='relu')

layer = tf.keras.layers.Dense(32, avtivation='relu')
output = layer(flatten)
output.shape # 확 줄어든걸 볼 수 있다

layer_2 = tf.keras.layers.Dense(10, activation='relu')
output_example = layer_2(output)
```

```python

```

```python

```

```python

```

```python

```

```python

```

```python

```
