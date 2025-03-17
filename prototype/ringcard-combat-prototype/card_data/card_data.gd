class_name CardData extends Resource

enum Type { POLICY, MEASURE, EVENT }
enum TargetType { SELF, OPPONENT, AREA }

@export_group("Card Visual")
@export var name: String
@export_multiline var discription: String
@export var type: Type
@export var icon: Texture
@export var cost: int
@export var duration: int = 0 # 政策卡持续回合

@export_group("Card Info")
@export var target_type: TargetType
@export var target_num: int = 0
#@export var sound: AudioStream


func _ready():
	resource_local_to_scene = true


func apply_effects(targets: Array[Node]):
	print_debug(name, " played")
	pass
