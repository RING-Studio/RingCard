extends TextureRect

func _enter_tree(): visible = true

func _ready():
    await get_tree().create_timer(1.0).timeout
    var tween = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
    tween.tween_property(self.material, "shader_parameter/alpha", 0.0, 1.0)
    await tween.finished
    visible = false
