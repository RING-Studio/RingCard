extends Control
var slide_twn: Tween

func _enter_tree(): Global.gameover = self

func show_summary():
    if Global.current_map.map_info.battle_won == 0:
        gameover()
        return
    skipable = false
    visible = true
    var long_list = $Sprite2D
    var short_list = $Sprite2D2
    if slide_twn != null: slide_twn.kill()
    slide_twn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
    long_list.material.set_shader_parameter("offset", -1200)
    short_list.material.set_shader_parameter("offset", -800)
    slide_twn.tween_property(long_list.material, "shader_parameter/offset", 0, 0.5)
    slide_twn.tween_property(short_list.material, "shader_parameter/offset", 0, 0.5)
    slide_twn.tween_property(self, "skipable", true, 0.5)

    pop_right()
    var showcase_arr: Array = []
    showcase_arr.append(tr("ENEMYKILLED") + "  " + str(Global.current_map.map_info["enemies_killed"]))
    showcase_arr.append(tr("BATTLEWON") + "  " + str(Global.current_map.map_info["battle_won"]))
    showcase_arr.append(tr("PASSEDNODE") + "  " + str(Global.current_map.map_info["passed_node"]))
    showcase_arr.append(tr("FUSIONTIME") + "  " + str(Global.current_map.map_info["fusion_time"]))
    pop_left(showcase_arr)
    await Global.load.blur()

var right_twn: Tween
func pop_right():
    $Control / Label3.text = (tr("AREA") + " " + str(Global.current_map.map_info["depth"]) + 
                                ": " + str(int(100 * Global.current_map.passed_node_count())) + "%")
    var right_labels = $Control.get_children()
    for label in right_labels:
        label.modulate = Color.TRANSPARENT
    if right_twn != null: right_twn.kill()
    right_twn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
    right_twn.tween_interval(0.5)
    for label in right_labels:
        right_twn.tween_property(label, "modulate", Color.WHITE, 0.5)

var skipable: bool = false
func _on_gui_input(event):
    if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT
    and event.is_pressed() and skipable and !clicking_cg):
        visible = false
        gameover()

func gameover():
    Global.current_map.visible = false
    Global.current_map.read_only = true
    Global.graveyard = []
    Global.deck_to_draw = []
    await Global.load.blur()
    Global.current_battle.respawn()
    if Global.constant_deck.is_empty() or Global.streak == 0:
        Global.abandon_current_run()
    else:
        Global.pick_from_deck.refresh("loot_card")
        await Global.switch_to_scene(Global.pick_from_deck)

var bounce_twn: Tween
func bounce():
    var cg = $cg
    if cg.texture == load("res://UI/win_cg.png"):
        cg.texture = load("res://UI/sad_cg.png")
    else: cg.texture = load("res://UI/win_cg.png")
    cg.material.set_shader_parameter("bulge", 0.4)
    cg.scale = Vector2(0.8, 0.8)
    if bounce_twn != null: bounce_twn.kill()
    bounce_twn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel()
    bounce_twn.tween_property(cg.material, "shader_parameter/bulge", 0.0, 0.4)
    bounce_twn.tween_property(cg, "scale", Vector2(1.0, 1.0), 0.4)

func _on_area_2d_input_event(viewport, event, shape_idx):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
        bounce()

func pop_left(messages: Array = ["text", "saadaga", "llllllll", "10131g1", "ppppplplp", "vmammmva", "tessssst"]):
    var anchor = $LeftStart
    for node in anchor.get_children(): node.free()

    var tilt = $Sprite2D.skew
    var order = 0
    var labels: Array = []
    var template = anchor.duplicate()
    for message in messages:
        var new_label = template.duplicate()
        new_label.text = message
        anchor.add_child(new_label)
        labels.append(new_label)
        new_label.position = order * Vector2(abs(tan(tilt)) * new_label.size.y, new_label.size.y) + Vector2(-1100, 0)
        order += 1
    template.queue_free()
    for index in range(labels.size()):
        var label = labels[index]
        var left_message_twn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
        left_message_twn.tween_interval(0.25 * index)
        left_message_twn.tween_property(label, "position", label.position + Vector2(1100, 0), 1.2)

var clicking_cg: bool = false
func _on_area_2d_mouse_entered():
    clicking_cg = true

func _on_area_2d_mouse_exited():
    clicking_cg = false
