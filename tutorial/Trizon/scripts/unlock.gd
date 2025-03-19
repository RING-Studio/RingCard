extends ColorRect
var cards = []
var alpha_tween: Tween
var jump_tween: Tween
var ready_to_be_hide: bool = false
func _enter_tree(): Global.unlock_view = self

func _on_gui_input(event):
    if (event is InputEventMouseButton and ready_to_be_hide and 
    (event.button_index == MOUSE_BUTTON_LEFT)):
        for c in cards:
            c.back_to_pool()
        cards.clear()
        visible = false
        ready_to_be_hide = false
        await Global.load.blur()
        Global.back_to_title()

func jump_text(x):
    var label = $UnlockText
    label.text = "！ " + str(x) + tr("UNLOCKCARD") + " ！"
    label.scale = Vector2(0.1, 1.5)
    if jump_tween != null: jump_tween.kill()
    jump_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
    jump_tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.9)

var to_delete = [
        "meat", 
        "rabit", 
        "slime", 
        "beast", 
        "earth_element", 
        "goblin", 
        "goat", 
        "bear", 
        "fox", 
        "lion", 
        "living_armor", ]
func unlock(arr_c_name):
    for c_ in arr_c_name:
        if Global.shiny_pool.has(c_) and !Global.meta_progress.unlocked_best_pick_pool.has(c_): Global.meta_progress.unlocked_best_pick_pool.append(c_)
        elif !Global.meta_progress.unlocked_basic_pick_pool.has(c_):
            for unlocked_c in Global.meta_progress.unlocked_basic_pick_pool:
                if to_delete.has(unlocked_c):
                    Global.meta_progress.unlocked_basic_pick_pool.erase(unlocked_c)
                    break
            Global.meta_progress.unlocked_basic_pick_pool.append(c_)
    Global.basic_pick_pool = Global.meta_progress.unlocked_basic_pick_pool
    Global.best_pick_pool = Global.meta_progress.unlocked_best_pick_pool
    Global.save_meta_progress()
    jump_text(arr_c_name.size())
    visible = true
    if alpha_tween != null: alpha_tween.kill()
    alpha_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
    alpha_tween.tween_property(material, "shader_parameter/alpha", 1.0, 0.3)

    for c_name in arr_c_name:
        var unlocked_c = Global.instantiate_from_pool()
        unlocked_c.card_data.merge(Global.card_prototypes.get(c_name), true)
        add_child(unlocked_c)
        unlocked_c.play_burn(true, Tween.EASE_OUT, Tween.TRANS_QUAD, 0.0, true)
        cards.append(unlocked_c)
        unlocked_c.movable = false
        unlocked_c.initial_scale = Vector2(1.5, 1.5)
        unlocked_c.scale = Vector2(1.5, 1.5)
        unlocked_c.global_position = Vector2(2050, 540 - unlocked_c.size.y * 1.5 / 2)
        order()
        await get_tree().create_timer(0.5).timeout
        unlocked_c.play_burn(true, Tween.EASE_OUT, Tween.TRANS_QUART, 0.7, false)
        await get_tree().create_timer(0.2).timeout
    ready_to_be_hide = true

func order():
    var max = 5.0
    for i in range(cards.size()):
        var relative_index: float = float(i + 0.5) - float(cards.size()) / 2.0
        var multiplier: float = max / float(cards.size())
        if cards.size() >= max:
            cards[i].move_to(Vector2(

                global_position.x + size.x / 2 - (cards[i].size.x * 1.5 - 60) / 2 + (cards[i].size.x * 1.5 + 60) * (multiplier) * relative_index, 
                540 - cards[i].size.y * 1.5 / 2
            ))
        else:
            cards[i].move_to(Vector2(
                global_position.x + size.x / 2 - (cards[i].size.x * 1.5 - 60) / 2 + (cards[i].size.x * 1.5 + 60) * relative_index, 
                540 - cards[i].size.y * 1.5 / 2
            ))
