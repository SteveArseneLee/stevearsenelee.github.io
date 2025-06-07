+++
title = "Tracing에 대해서..."
draft = false

+++

## Tracing이란?
> microservice가 시스템을 경유하며 **transaction** 을 처리하는 과정에서 발생하는 세부적인 정보
> 또한, 트랜잭션이 이동한 경로, 트랜잭션을 처리하는 과정에서 발생하는 대기시간과 지연시간, 병목현상이나 에러를 일으키는 원인을 문맥(context)과 로그, 태그 등의 **metadata**에 출력함

### Tracing과 관련된 용어
#### Span
- 전반적인 수행 시간 정보뿐만 아니라, 각기 하위 동작의 시작과 소요 시간 정보를 알 수 있음. Span은 동작 정보, 타임라인과 부모 스팬과의 의존성을 모두 포함하는 수행 시간을 담고 있음.

#### Span Context
- 새로운 span을 생성하기 위해선 다른 스팬을 참조해야 하는데, *span context* 는 이때 필요한 정보를 제공함. *Span context* 로 표현된 메타데이터를 쓸 수 있는 **Inject** 와 읽을 수 있는 **Extract** 메서드를 제공함.
- 즉, *Span context* 는 주입과 추출을 통해 헤더에 전달되며, 전달된 *Span context* 에서 추출한 스팬 정보로 새로운 자식 스팬을 생성할 수 있음.

![alt text](/observability/traces/span-context.png)

#### Span Reference
- 두 스팬 사이의 인과관계를 가리킴
- 스팬 사이의 인과관계를 정의하고, 스팬들이 동일한 추적에 속한다는 것을 tracer가 알 수 있게 하는 것. 이렇나 관계는 *span reference* 로 나타남. *Span reference* 에는 ```child of```와 ```following from```의 두 가지 유형이 있음.
- e.g. <span style="color: blue">Span B</span>는 <span style="color: blue">Span A</span>의 ```child of```이거나, <span style="color: blue">Span A</span>의 ```following from```이라고 정의할 수 있음.