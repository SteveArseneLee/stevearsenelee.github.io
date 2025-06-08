+++
title = "Topic 설계"
author = "LogLee"
+++

### Fact Topics
테이블명 | Kafka Topic 이름 | 파티션 | 복제 수
-|-|-|-
equipment_metrics | iot.equipment_metrics | 6 |3
qc_result | iot.qc_result | 3 | 3
energy_usage | iot.energy_usage | 3 | 3
robot_status | iot.robot_status | 3 | 3
environmental_readings | iot.environmental_readings | 3 | 3
device_status | iot.device_status | 3 | 3

### Dimension Topics
테이블명 | Kafka Topic 이름 | 파티션 | 복제 수
-|-|-|-
dim_equipment | dim.equipment | 1 | 3
dim_product | dim.product | 1 | 3
dim_process | dim.process | 1 | 3
dim_inspection | dim.inspection | 1 | 3
dim_location | dim.location | 1 | 3
dim_sensor | dim.sensor | 1 | 3
dim_factory | dim.factory | 1 | 3
dim_employee | dim.employee | 1 | 3
dim_defect_code | dim.defect_code | 1 | 3