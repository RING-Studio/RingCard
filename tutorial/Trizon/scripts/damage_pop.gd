extends Label

func do(damage_amount = 0):

    if randi() % 2 == 1: scale = Vector2(0.3, 0.1)
    else: scale = Vector2(0.1, 0.3)

    var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
    var time_span = damage_amount / (damage_amount + 10.0) + 0.3
    tween.tween_property(self, "scale", Vector2(1.0, 1.0), time_span)
    var destination = Vector2(-50 + randi() % 100, -100 + randi() % 30)
    pivot_offset = size / 2
    tween.parallel().tween_property(self, "global_position", destination, time_span).as_relative()

    var tween2 = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
    tween2.tween_interval(time_span)
    tween2.tween_property(self, "modulate", Color.TRANSPARENT, time_span)
    rotation += atan2(destination.x, - destination.y)
