---
title:  "[Vision] Tensorflow기초"
excerpt: "Tensorflow 사용법"

categories:
  - Vision
tags:
  - [Vision]

toc: true
toc_sticky: true
 
date: 2021-07-29
last_modified_at: 2021-08-03
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

#### DropOut
```python
layer = tf.keras.layers.Dropout(0.7)
output = layer(output)

output.shape
```

### Build Model
```python
from tensorflow.keras import layers

input_shape = (28,28,1)
# class 개수 지정
num_classes = 10
inputs = layers.input(shape=input_shape)

# Feature Extraction
## Convolution Block
net = layers.Conv2D(32,3, padding='SAME')(inputs)
net = layers.Activation('relu')(net)
net = layers.Conv2D(32,3, padding='SAME')(net)
net = layers.Activation('relu')(net)
net = layers.MaxPool2D((2,2))(net)
net = layers.Dropout(0.25)(net)

## Convolution Block
net = layers.Conv2D(64,3, padding='SAME')(net)
net = layers.Activation('relu')(net)
net = layers.Conv2D(64,3, padding='SAME')(net)
net = layers.Activation('relu')(net)
net = layers.MaxPool2D((2,2))(net)
net = layers.Dropout(0.25)(net)

# Fully Connected
net = layers.Flatten()(net)
net = layers.Dense(512)(net)
net = layers.Activation('relu')(net)
net = layers.Dropout(0.25)(net)
net = layers.Dense(10)(net)
net = layers.Activation('softmax')(net)

model = tf.keras.Model(inputs=inputs, outputs=net, name='Basic_CNN')
model.summary()
```

## Optimization & Training
- tf와 layers 패키지 불러오기
- MNIST Dataset 준비
```python
import tensorflow as tf
from tensorflow.keras import layers
from tensorflow.keras import datasets

(train_x, train_y), (test_x, test_y) = datasets.mnist.load_data()
```
### Optimization
모델을 학습하기 전 설정
- Loss Function
- Optimization
- Metrics
### Loss Function
#### Categorical VS Binary
```python
loss = 'binary_crossentropy'
loss = 'categorical_crossentropy'
```
#### sparse_categorical_crossentropy vs categorical_crossentropy
```python
loss_fun = tf.keras.losses.sparse_categorical_crossentropy
tf.keras.losses.categorical_crossentropy
tf.keras.losses.binary_crossentropy
```

##### Metrics
모델을 평가하는 방법
- accuracy를 이름으로 넣는 방법
```python
metrics = ['accuracy']
```
- tf.keras.metrics.
```python
tf.keras.metrics.Accuracy()
```

### Compile
Optimizer 적용
- 'sgd'
- 'rmsprop'
- 'adam'
```python
optm = tf.keras.optimizers.Adam()
```
- tf.keras.optimizers.SGD()
- tf.keras.optimizers.RMSprop()
- tf.keras.optimizers.Adam()
```python
# model.compile(optimizer=optm, loss=loss_fun, metrics=metrics)
model.compile(optimizer=tf.keras.optimizers.Adam(), loss='sparse_categorical_crossentropy', metrics=[tf.keras.metrics.Accuracy()])
```

### Prepare Dataset
- shape 확인
```python
print(train_x.shape, train_y.shape)
print(test_x.shape, test_y.shape)
```
- 차원 수 늘리기
```python
import numpy as np
# np.expand_dims(train_x, -1).shape

train_x = train_x[..., tf.newaxis]
test_x = test_x[..., tf.newaxis]

# 차원 수가 잘 늘었는지 확인
train_x.shape
```
Rescaling
```python
print(np.min(train_x), np.max(train_x))

train_x = train_x / 255.
test_x = test_x / 255.

print(np.min(train_x), np.max(train_x))
```

### Training
Hyperparameter설정
- num_epochs
- batch_size
```python
num_epochs = 1
batch_size = 32
```
- model.fit
```python
model.fit(train_x, train_y, batch_size=batch_size,shuffle=True, epochs=num_epochs)
```

---

# Expert Version
## Optimization & Training
```python
import tensorflow as tf
from tensorflow.keras import layers
from tensorflow.keras import datasets

input_shape = (28,28,1)
num_classes = 10

inputs = layers.input(shape=input_shape, dtype=tf.float64)

# Feature Extraction
## Convolution Block
net = layers.Conv2D(32,3, padding='SAME')(inputs)
net = layers.Activation('relu')(net)
net = layers.Conv2D(32,3, padding='SAME')(net)
net = layers.Activation('relu')(net)
net = layers.MaxPool2D((2,2))(net)
net = layers.Dropout(0.25)(net)

## Convolution Block
net = layers.Conv2D(64,3, padding='SAME')(net)
net = layers.Activation('relu')(net)
net = layers.Conv2D(64,3, padding='SAME')(net)
net = layers.Activation('relu')(net)
net = layers.MaxPool2D((2,2))(net)
net = layers.Dropout(0.25)(net)

# Fully Connected
net = layers.Flatten()(net)
net = layers.Dense(512)(net)
net = layers.Activation('relu')(net)
net = layers.Dropout(0.25)(net)
net = layers.Dense(10)(net)
net = layers.Activation('softmax')(net)

model = tf.keras.Model(inputs=inputs, outputs=net, name='Basic_CNN')
```
### Preprocess
- tf.data 사용
```python
mnist = tf.keras.datasets.mnist

# Load Data from MNIST
(x_train, y_train), (x_test, y_test) = mnist.load_data()

# Channel 차원 추가
x_train = x_train[..., tf.newaxis]
x_test = x_test[..., tf.newaxis]

# Data Normalization
x_train, x_test = x_train / 255.0, x_test / 255.0
```

- from_tensor_slices()
- shuffle()
- batch()
```python
train_ds = tf.data.Dataset.from_tensor_slices((x_train, y_train))
train_ds = train_ds.shuffle(1000)
train_ds = train_ds.batch(32)

test_ds = tf.data.Dataset.from_tensor_slices((x_test, y_test))
test_ds = test_ds.batch(32)
```

### Visualization Data
- matplotlib 불러와서 데이터 시각화
```python
import matplotlib.pyplot as plt
%matplotlib inline
```
- train_ds.take()
```python
for image, label in train_ds.take(2):
    plt.title(label[0])
    plt.imshow(image[0,:,:,0], 'gray')
    plt.show()
```

#### Training (Keras) (참고)
- Keras로 학습할 때는 기존과 같지만, train_ds는 generator라서 그대로 넣을 수 있음
```python
model.compile(optimizer='adam', loss='sparse_categorical_crossentropy')
model.fit(train_ds, epochs=1000)
```

### Optimization
- Loss Function
- Optimizer
```python
loss_object = tf.keras.losses.SparseCategoricalCrossentropy()

optimizer = tf.keras.optimizers.Adam()
```
- Loss Funciton을 담을 곳
- Metrics
```python
train_loss = tf.keras.metrics.Mean(name='train_loss')
train_accuracy = tf.keras.metrics.SparseCategoricalAccuracy(name='train_accuracy')

test_loss = tf.keras.metrics.Mean(name='test_loss')
test_accuracy = tf.keras.metrics.SparseCategoricalAccuracy(name='test_accuracy')
```

### Training
- @tf.function - 기존 session 열었던 것처럼
```python
@tf.function
def train_step(images, labels):
    with tf.GradientTape() as tape:
        predictions = model(images)
        loss = loss_object(labels, predictions)
    gradients = tape.gradient(loss, model.trainable_variables)
    optimizer.apply_gradients(zip(gradients, model.trainable_variables))

    train_loss(loss)
    train_accuracy(labels, predictions)
```

```python
@tf.function
def test_step(images, labels):
    predictions = model(images)
    t_loss = loss_object(labels, predictions)

    test_loss(t_loss)
    test_accuracy(labels, predictions)
```

```python
for epoch in range(2):
    for images, labels in train_ds:
        train_step(images, labels)
    
    for test_images, test_labels in test_ds:
        test_step(test_images, test_labels)
    
    template = 'Epoch {}, Loss: {}, Accuracy: {}, Test Accuracy: {}'

    print(template.format(epoch+1,train_loss.result(),train_accuracy.result()*100, test_loss.result()*100))
```

## Evaluating & Predicting
### Training
```python
num_epochs = 1
batch_size = 64

hist = model.fit(train_x, train_y, batch_size=batch_size, shuffle=True)

print(hist.history)
```
### Evaluating
- 학습한 모델 확인
```python
model.evaluate(test_x, test_y, batch_size=batch_size)
```
#### 결과 확인
input으로 들어갈 이미지 데이터 확인
```python
import matplotlib.pyplot as plt
import numpy as np
%matplotlib inline

test_image = test_x[0,:,:,0]
test_image.shape

plt.title(test_y[0])
plt.imshow(test_image)
plt.show()

# test_image.shape
pred = model.predict(test_image.reshape(1,28,28,1))
# pred.shape

np.argmax(pred)
```

### Test Batch
- Batch로 Test Dataset 넣기
```python
test_batch = test_x[:32]
test_batch.shape

preds = model.predict(test_batch)
preds.shape

np.argmax(preds, -1)
```