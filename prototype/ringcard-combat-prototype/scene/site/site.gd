extends Area2D
class_name Site

@export var site_data: SiteData

@onready var icon: Sprite2D = $Icon
# TODO: CollisionPolygon2D不太容易适应换图标，之后改成button，用透明度mask
@onready var name_label: Label = $NameLabel
@onready var p_if_label: Label = $pIFLabel
@onready var c_if_label: Label = $cIFLabel

var pIF: int
var cIF: int


func _ready() -> void:
	pIF = site_data.init_pIF
	cIF = site_data.init_cIF

	icon.texture = site_data.texture
	name_label.text = site_data.site_name
	update_IF_label()

	# TODO: 自适应texture形状
	#texture_button.pivot_offset = texture_button.size / 2.0
	#texture_button.texture_click_mask.create_from_image_alpha(texture_button.texture_normal.get_image())


func change_pIF(value: int):
	pIF += value
	pIF = min(12, max(0, pIF))
	update_IF_label()


func change_cIF(value: int):
	cIF += value
	cIF = min(12, max(0, cIF))
	update_IF_label()
	

func update_IF_label():
	p_if_label.text = str(pIF)
	c_if_label.text = str(cIF)


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouse:
		if event.is_action_pressed("mouse_left"):
			print_debug(site_data.site_name, " : ", site_data.discription)
