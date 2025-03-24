extends CanvasLayer
class_name SiteSelectHUD

@onready var confirm_button: Button = $ConfirmButton
@onready var site_icon_container: ScrollContainer = $SiteIconContainer
@onready var h_box_container: HBoxContainer = $SiteIconContainer/HBoxContainer

var current_card: Card
var target_num: int
var random_select: bool = false

var selected_sites: Array[Site] = []

func _ready() -> void:
	Events.start_site_selecting.connect(_on_start_site_selecting)
	init()
	visible = false


func init():
	site_icon_container.visible = true
	current_card = null
	site_clear()

func reset():
	site_icon_container.visible = true
	current_card = null
	site_clear()
	site_append()

func site_clear():
	for child in h_box_container.get_children():
		child.queue_free()
	selected_sites = []

func site_append():
	var sites = get_tree().get_nodes_in_group("site") as Array[Site]
	for site in sites:
		var new_site = site.duplicate() as Site
		new_site.remove_from_group("site")
		(new_site.texture_button as TextureButton).pressed.connect(_on_site_selected)
		h_box_container.add_child(new_site)


func _on_site_selected(site: Site):
	if site in selected_sites:
		site.outline_off()
		selected_sites.erase(site)
		return
		
	if selected_sites.size() >= target_num:
		return
		
	site.outline_on()
	selected_sites.append(site)
	


func _on_start_site_selecting(card: Card):
	reset()
	visible = true
	current_card = card
	target_num = card.target_num
	random_select = card.random_target
	select_site(current_card.target_num)


func select_site(target_num: int):
	pass


func _on_hide_button_pressed() -> void:
	site_icon_container.visible = !site_icon_container.visible


func _on_confirm_button_pressed() -> void:
	Events.end_site_selecting.emit(current_card.targets)
	visible = false
