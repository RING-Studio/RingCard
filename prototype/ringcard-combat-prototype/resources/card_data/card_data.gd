class_name CardData extends Resource

enum Type { POLICY, MEASURE, EVENT }
enum TargetType { SELF, OPPONENT, SITE, NONE }

@export_group("Visual")
@export var card_name: String
@export_multiline var discription: String
@export var type: Type
@export var cost: int
@export var duration: int = 0 # 政策卡持续回合

@export_subgroup("Texture")
@export var template_texture: Texture = preload("res://asset/kenney_boardgame-pack/PNG/Cards/cardBack_green1.png") # 卡牌模板 
@export var illust_texture: Texture = preload("res://asset/kenney_boardgame-pack/PNG/Pieces (White)/pieceWhite_border10.png") # 卡牌插画
@export var back_texture: Texture = preload("res://asset/kenney_boardgame-pack/PNG/Cards/cardBack_green5.png") # 卡背
@export var cost_texture: Texture = preload("res://asset/kenney_boardgame-pack/PNG/Chips/chipGreen_border.png") # 费用背景图

@export_group("Info")
@export var target_type: TargetType
@export var target_num: int = 0
@export var random_target: bool = false
@export var fixed_target_names: Array[String] = [] # 事先固定的目标，有这个就不需要select

#@export var sound: AudioStream


func _ready():
	resource_local_to_scene = true


func apply_effects(targets: Array[Node]):
	print_debug(card_name, " played")
	return

	
func card_play_animation():
	await Utils.await_time(2)
	return
