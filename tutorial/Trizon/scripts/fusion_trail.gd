extends Path2D



func _ready():
    pass



func _process(delta):
    pass

var twn_scale: Tween
var twn_trail: Tween
func start_trail(data, opposite: bool, time: float = 1.0):
    var target = $PathFollow2D / Card
    var follower = $PathFollow2D
    target.card_data = data
    target.scale = Vector2(3.5, 3.5)
    follower.progress_ratio = 0
    if opposite: target.rotation_degrees = 270
    else: target.rotation_degrees = 90
    if twn_scale != null: twn_scale.kill()
    if twn_trail != null: twn_trail.kill()
    target.play_burn(true, Tween.EASE_OUT, Tween.TRANS_QUART, 0.0, false)
    twn_scale = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
    twn_trail = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
    if opposite:
        twn_scale.tween_interval(0.1)
        twn_trail.tween_interval(0.1)
    twn_scale.tween_property(target, "scale", Vector2(1.0, 1.0), time)
    twn_trail.tween_property(follower, "progress_ratio", 1.0, time)
    await twn_scale.finished
    target.play_burn(true, Tween.EASE_OUT, Tween.TRANS_QUART, 0.4, true)
