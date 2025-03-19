extends Control

var global = Global
var deck_view
var twn: Tween
var mapbttwn: Tween
var pick_chance_last_frame = 0
var item_label_scene = preload("res://scenes/item_label.tscn")
@onready var map = $Map

func jump_number(label = $PickChances):
    if twn != null: twn.kill()
    twn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
    twn.tween_property(label, "scale", Vector2(1.0, 1.0), 0.0)
    twn.tween_property(label, "scale", Vector2(1.28, 1.28), 0.24)
    twn.set_ease(Tween.EASE_IN)
    twn.tween_property(label, "scale", Vector2(1.0, 1.0), 0.16)

func _ready():
    global.toplayerui = self
    deck_view = Global.deck_view
    deck_view.connect("gui_input", close_deck_view)
    deck_view.gradually_load_from(global.all_cards_pools)
    deck_view.gradually_load_from(global.constant_deck)
    deck_view.set_hide()

func wave(at):

    $Wave.material.set_shader_parameter("force", 0.02)
    $Wave.material.set_shader_parameter("center", at / $Wave.size)
    $Wave.material.set_shader_parameter("size", 0.1)
    $Wave.material.set_shader_parameter("thickness", 0.0)
    var wave_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
    wave_tween.tween_property($Wave.material, "shader_parameter/size", 1.0, 1.0)
    wave_tween.parallel().tween_property($Wave.material, "shader_parameter/thickness", 1.0, 1.0)
    wave_tween.parallel().tween_property($Wave.material, "shader_parameter/force", 0.0, 1.0)

func close_deck_view(event):
    if (event is InputEventMouseButton and 
    (event.button_index == MOUSE_BUTTON_RIGHT or event.button_index == MOUSE_BUTTON_LEFT)):
        deck_view.fake_hide()

func _process(_delta):


    $LP.text = str(global.LP) + " / " + str(global.max_LP)

    $PickChances.text = str(global.pick_chances)
    $Deck.text = global.ui["deck"] + " " + str(global.constant_deck.size())
    if pick_chance_last_frame != Global.pick_chances:
        jump_number()
        pick_chance_last_frame = Global.pick_chances

func shine_relic(relic_name):
    for relic in $ItemColumnScroll / ItemColumn.get_children():
        if relic.hold_item == relic_name: relic.shine()

func update_relicflag():
    var arr = Global.relic_current_path()
    $RelicFlag / Label.text = str(arr[0]) + " / " + str(arr[1])
    jump_number($RelicFlag / Label)

func update_reliccol():
    var col = $ItemColumnScroll / ItemColumn
    for old_child in col.get_children(): old_child.free()
    var item_list = Global.relics
    for item_name in item_list:
        var new_item_label = item_label_scene.instantiate()
        col.add_child(new_item_label)
        new_item_label.update(item_name)

func _on_deck_pressed():
    toggle_deck_view(global.constant_deck)

func toggle_deck_view(deck):
    Music.sound_random_UI()
    if !deck_view.visibility:
        deck_view.update_deck(deck, true)
        deck_view.fake_appear()
    else: deck_view.fake_hide()

func _on_check_button_3_pressed():
    Music.sound_random_UI()
    $CardDetail.show_tutorial()

func _on_map_pressed():
    Music.sound_random_UI()
    if map.visible and map.read_only:
        map.close()
    elif !map.visible and map.read_only:
        map.open()

func toggle_map_button(bo: bool):
    var color = Color.TRANSPARENT
    if bo: color = Color.WHITE
    if mapbttwn != null: mapbttwn.kill()
    mapbttwn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
    mapbttwn.tween_property($MapButton, "modulate", color, 0.3)

func _on_open_esu_pressed():
    Music.sound_random_UI()
    Global.esc.toggle()
