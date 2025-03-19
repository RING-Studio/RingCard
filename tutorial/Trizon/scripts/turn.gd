extends Label
var initial_pos
var tween: Tween

func refresh(turn: int, wave: int = 0):
    var new_text = ""
    if wave == 0: new_text += tr("LASTWAVE")
    else: new_text += tr("WAVELEFT") + " " + str(wave)
    new_text += "\n" + tr("TURN") + " " + str(turn)
    if tween != null: tween.kill()
    tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
    tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.4)
    tween.tween_property(self, "text", new_text, 0.0)
    tween.tween_property(self.material, "shader_parameter/height", 5.0, 2.0).from(16.0)
    if turn != 0: tween.parallel().tween_property(self, "modulate", Color.WHITE, 0.4)
