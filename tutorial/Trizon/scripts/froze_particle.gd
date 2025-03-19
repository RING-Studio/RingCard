extends AnimatedSprite2D



func _ready():
    var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).set_loops()
    tween.tween_property(self, "frame", 12, 2.0).from(1)


func _process(delta):
    pass
