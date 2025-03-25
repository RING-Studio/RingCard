extends CanvasLayer
class_name SiteSelectHUD

@onready var confirm_button: Button = $ConfirmButton
@onready var site_icon_container: ColorRect = $SiteIconContainer
@onready var scroll_container: ScrollContainer = $SiteIconContainer/ScrollContainer
@onready var h_box_container: HBoxContainer = $SiteIconContainer/ScrollContainer/HBoxContainer

var battle: Battle

var target_num: int
var random_select: bool = false

var selected_sites: Array[Node] = []

func _ready() -> void:
	Events.start_site_selecting.connect(_on_start_site_selecting)
	init()
	visible = false
	await owner.ready
	battle = get_tree().get_first_node_in_group("battle")


func init():
	confirm_button.disabled = true
	site_icon_container.visible = true
	clear()

func reset():
	confirm_button.disabled = true
	site_icon_container.visible = true
	clear()
	site_append()

func clear():
	visible = false
	for site in selected_sites:
		(site as Site).outline_off()
	selected_sites = []
	site_icon_clear()

func site_icon_clear():
	for child in h_box_container.get_children():
		child.queue_free()

func site_append():
	var sites = get_tree().get_nodes_in_group("site") as Array[Site]
	for site in sites:
		var new_site = site.duplicate() as Site
		new_site.remove_from_group("site")
		h_box_container.add_child(new_site)
		(new_site.texture_button as TextureButton).pressed.connect(_on_site_selected.bind(site))


func _on_site_selected(site: Site):
	if site in selected_sites:
		site.outline_off()
		selected_sites.erase(site)
		return
		
	if selected_sites.size() >= target_num:
		print_debug("目标数量溢出")
		return
		
	site.outline_on()
	selected_sites.append(site)
	
	if selected_sites.size() == target_num:
		confirm_button.disabled = false
	else:
		confirm_button.disabled = true


func _on_start_site_selecting(card: Card):
	reset()
	visible = true
	target_num = card.target_num
	random_select = card.random_target


func _on_hide_button_pressed() -> void:
	site_icon_container.visible = !site_icon_container.visible


func _on_confirm_button_pressed() -> void:
	battle.current_card.targets = selected_sites
	Events.end_site_selecting.emit(battle.current_card.targets)
	clear()


func _on_conceal_button_pressed() -> void:
	battle.current_card.targeting_concealed = true
	Events.end_site_selecting.emit(battle.current_card.targets)
	clear()
