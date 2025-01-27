## 模块



### 数据

指可以用于**初始化**和**重载**进度的数据

#### 代码缩写

稳定度 —— ST（stability）

行动力 —— AP（Action Point）

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
classname AreaInfo

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

func updateAreaCard(){
  # 更新对应的地点卡
}
```

目前地点：西郊（1,6），自治会本部（7,0），第一食堂（2,1），学生宿舍（3,0），第一教学楼（3,1），纠察队办公室（4,0），第五教学楼（2,2），活动中心（2,1）

#### 玩家/ai

玩家/ai主要数据为手牌、弃牌堆、抽牌堆、稳定度等

公有数据：手牌数量、弃牌堆数量、抽牌堆数量、稳定度、行动力、绝对控制数量、政策buff

私有数据：手牌、弃牌堆、抽牌堆(?)

```python
classname Player

var hand: Array[HandCard]
var 
```



### 卡牌

包括卡牌的各种形态（位于手中、挂在场上等等）

#### 通用

用于存储卡牌信息

```python
classname CardInfo

var name: string
var type: string # enum{"counter", "policy", "event"}
var cost: int
var last: int # 持续回合

var sprite: Sprite2D

func on_drawn(){
  # 抽到时效果
}

func on_played(){
  # 打出时效果
}

func on_hung(){
  # 挂在头上时持续产生的效果
}
```



#### 手牌

需要做成一个Area

从牌库抽牌时检测顺序

1. 实体化CardInfo为HandCard
2. 触发on_drawn()
3. 若不被丢弃，加入手牌

```python
classname Hand

var hand_cards: Array[HandCard]

func draw_card(){
	# 
}
```

```python
classname HandCard

var area: Area2D
var card_info: CardInfo
```





### AI逻辑

根据当前场面进行固定操作。暂不开发。

试验阶段可以**从左到右遍历能出的牌**出。



### 棋盘UI

#### 组件

##### 玩家区

​	头像区、手牌、弃牌、抽牌、政策buff栏

​	结束回合按钮

​	（试验阶段）确认按钮（用于确认出牌、弃牌、指定对象等等）

##### 地图区

​	地图、地点卡

##### ai区

​	头像区、手牌、弃牌、抽牌、政策buff栏

##### 系统

​	esc
