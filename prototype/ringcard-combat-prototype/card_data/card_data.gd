# 卡牌基类 CardData.gd
class_name CardData extends Resource
enum TYPE { POLICY, COUNTERMEASURE, EVENT }

@export var card_name: String
@export var cost: int
@export var card_type: TYPE
@export var duration: int  # 政策卡持续回合
@export var effect_script: GDScript  # 效果逻辑分离
