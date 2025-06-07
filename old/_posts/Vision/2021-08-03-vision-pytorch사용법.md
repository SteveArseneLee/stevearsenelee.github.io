---
title:  "[Vision] Pytorch Basic"
excerpt: "Pytorch 사용법"

categories:
  - Vision
tags:
  - [Vision]

toc: true
toc_sticky: true
 
date: 2021-08-03
last_modified_at: 2021-08-03
---
```python
import numpy as np
import torch
```
View
```python
range_nums = torch.arange(9).reshape(3,3)
print(range_nums.view(-1))
print(range_nums.view(1,9))
```
#### Slice and Index
```python
print(nums)
print(nums[1])
print(nums[1,1])
print(nums[1:])
```
#### Compile
numpy를 torch tensor로 불러오기
```python
arr = np.array([1])
arr_torch = torch.from_numpy(arr)
arr_torch.float()
device='cuda' if torch.cuda.is_available else 'cpu'
arr_torch.to(device)
```

#### AutoGrad
```python
x = torch.ones(2,2,requires_grad=True)
print(x)
y = x + 2
print(y)
print(y.grad_fn)
z = y*y*3
out = z.mean()
print(z,out)
out.backward()
print(x.grad)
```
## PyTorch Data Preprocess
```python
import torch
from torchvision import datasets, transforms
```
#### Data Loader 부르기
DataLoader를 불러 model에 넣음
```python
batch_size = 32
test_batch_size = 32

train_loader = torch.utils.data.DataLoader(datasets.MNIST('dataset/', train=True,download=True,transform=transform.Compose([transform.ToTensor(),transforms.Normalize(mean=(0.5,),std=(0.5,))])),batch_size=batch_size,shuffle=True)

test_loader = torch.utils.data.DataLoader(
    datasets.MNIST('dataset', train=False,transform=transforms.Compose([transforms.ToTensor(),transforms.Normalize((0.5,),(0.5))])),
    batch_size = test_batch_size, shuffle=True
)
```
#### 첫번째 iteration에서 나오는 데이터 확인
```python
images, labels = next(iter(train_loader))
print(images.shape, labels.shape)
```
#### 데이터 시각화
```python
import numpy as np
import matplotlib.pyplot as plt
%matplotlib inline

# images[0].shape
torch_image = torch.squeeze(images[0])
print(torch_image.shape)
image = torch_image.numpy()
print(image.shape)

label = labels[0].numpy()
print(label.shape)
print(label)

plt.title(label)
plt.imshow(image, 'gray')
plt.show()
```

# Pytorch Layer
```python
import torch
from torchvision import datasets, transforms

from PIL import image
import numpy as np
import matplotlib.pyplot as plt
%matplotlib inline

train_loader = torch.utils.data.DataLoader(
    datasets.MNIST('dataset', train=True,download=True, transform=transforms.Compose([
        transforms.ToTensor()
    ])),
    batch_size=1
)

image, label = next(iter(train_loader))
print(image.shape, label.shape)

plt.imshow(image[0,0,:,:])
plt.show()
```
## 각 Layer별 설명
- Network 쌓기 위한 준비
```python
import torch
import torch.nn as nn
import torch.nn.functional as F
# import torch.optim as optim
```
### Convolution
- in_channels : 받게 될 channel의 갯수
- out_channels : 보내고 싶은 channel의 갯수
- kernel_size : 만들고 싶은 kernel(weights)의 사이즈
```python
nn.Conv2d(in_channels=1,out_channels=20, kernel_size=5, stride=1)

layer = nn.Conv2d(1,20,5,1).to(torch.device('cpu'))
print(layer)
```
- weight 시각화를 위해 slice하고 numpy화
```python
weight = layer.weight
print(weight.shape)
```
- weight는 학습 가능한 상태여서 바로 numpy로 뽑아낼 수 없음
- detach() method는 그래프에서 잠깐 빼서 gradient에 영향을 받지 않게 함
```python
weight = weight.detach().numpy()
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