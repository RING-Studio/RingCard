## 模块



### 数据

#### 重要缩写

稳定度 —— ST（stability）

行动力 —— AP（Action Point）

地点 —— Area

影响力 —— IF（Influence）

玩家/ai —— p-/c-

#### 全局

```python
classname ValueManager

# 常量

# 设置变量

# RingCard变量
areas: Array[Area]
```



#### 地点

每个地点表现为一张地点卡，左下为玩家影响力pIF，右下为ai影响力cIF

```python
classname Area

var name: string
var init_pIF: int
var init_cIF: int
var pIF: int
var cIF: int

func update(){
  # 更新该地点状态总调用
  updateIF()
  updateCard()
}

func updateIF(){
  # 更新IF
  # 上报并更新全局IF
}

func updateCard(){
  # 更新对应的地点卡
}
```

目前地点：西郊（1,6），自治会本部（7,0），第一食堂（2,1），学生宿舍（3,0），第一教学楼（3,1），纠察队办公室（4,0），第五教学楼（2,2），活动中心（2,1）

#### 玩家

```python
```

