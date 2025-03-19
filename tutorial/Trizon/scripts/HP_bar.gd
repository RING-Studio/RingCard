extends Control

var HP_last_frame = 0
var tween: Tween

func _process(_delta):
    if Global.LP != HP_last_frame: update()
    HP_last_frame = Global.LP

func update():
    if tween != null: tween.kill()
    tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
    tween.tween_property( % bar.material, "shader_parameter/progress", Global.LP / float(Global.max_LP), 0.4)

func _on_mouse_entered():
    Popups.pop_at(global_position + Vector2(size.x + 18.0, + size.y + 8.0), tr("HPBAR"))

func _on_mouse_exited():
    Popups.unpop()
