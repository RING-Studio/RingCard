extends Resource
class_name SiteData

@export_group("Visual")
@export var site_name: String
@export var texture: Texture
@export var init_pIF: int
@export var init_cIF: int

@export_group("Info")
@export_multiline var discription: String


func _ready():
	resource_local_to_scene = true
