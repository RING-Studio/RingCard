extends Control
var begin: Vector2 = Vector2(1430, -643)
var goal: Vector2 = Vector2(1356, 400)
var tail: Vector2 = Vector2(1299, 1483)
var twn: Tween
var c_twn: Tween
func _enter_tree(): Global.reveal = self

func reveal(card_data):
    Global.current_battle.play_with_reveal()
    start(card_data)
    await get_tree().create_timer(1.2).timeout
    Global.current_battle.stop_with_reveal()
    await end()

func start(card_data = null):
    mouse_filter = MOUSE_FILTER_STOP
    if card_data != null: $Card.card_data = card_data
    if twn != null: twn.kill()
    if c_twn != null: c_twn.kill()
    $Card.position = begin
    twn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
    twn.tween_property($BlackSideUp.material, "shader_parameter/offset", 0, 0.6)
    twn.parallel().tween_property($BlackSideDown.material, "shader_parameter/offset", 0, 0.6)
    twn.parallel().tween_property($Blurbg.material, "shader_parameter/alpha", 1, 0.6)
    c_twn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
    c_twn.tween_property($Card, "position", goal, 0.9)

func end():
    if twn != null: twn.kill()
    if c_twn != null: c_twn.kill()
    twn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
    twn.tween_property($BlackSideUp.material, "shader_parameter/offset", 400, 0.6)
    twn.parallel().tween_property($BlackSideDown.material, "shader_parameter/offset", 400, 0.6)
    twn.parallel().tween_property($Blurbg.material, "shader_parameter/alpha", 0, 0.6)
    c_twn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
    c_twn.tween_property($Card, "position", tail, 0.6)
    await twn.finished
    mouse_filter = MOUSE_FILTER_IGNORE
