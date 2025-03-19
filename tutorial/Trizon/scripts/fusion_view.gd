extends Control

func _ready(): Global.fusion_view = self





func fusion_animation(data1, data2, data3, time = 2.5):
    appear()
    Global.resolving += 1
    var target = % Card
    target.play_burn(true, Tween.EASE_OUT, Tween.TRANS_QUART, 0.0, true)
    % Path2D.start_trail(data1, false, time)
    await % Path2D2.start_trail(data2, true, time)
    await change_into(data3)
    Global.resolving -= 1
    disappear()

var twn_respawn: Tween
func change_into(data):
    var target = % Card
    target.card_data = data
    target.scale = Vector2(1.0, 1.0)
    target.play_burn(true, Tween.EASE_OUT, Tween.TRANS_QUART, 0.4, false)
    if twn_respawn != null: twn_respawn.kill()
    twn_respawn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
    twn_respawn.tween_property(target, "scale", Vector2(1.5, 1.5), 0.6)
    await twn_respawn.finished

var black_tween: Tween
func disappear():
    if black_tween != null: black_tween.kill()
    black_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
    black_tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.2)
    black_tween.tween_property(self, "visible", false, 0.0)

func appear():
    if black_tween != null: black_tween.kill()
    black_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
    black_tween.tween_property(self, "visible", true, 0.0)
    black_tween.tween_property(self, "modulate", Color.WHITE, 0.2)
