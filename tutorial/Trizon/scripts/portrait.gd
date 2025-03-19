@tool
extends DialogicPortrait
var portrait_c
var scale_twn: Tween
func _ready():
    portrait_c = $Card
    Dialogic.signal_event.connect(_on_dialogic_signal)
    Dialogic.timeline_ended.connect(_on_dialogic_timeline_ended)








func _on_dialogic_timeline_ended():



    $Card.unglow()
    $Card.play_burn(true, Tween.EASE_OUT, Tween.TRANS_QUART, 0.0, true)
    $Card.card_data = Global.card_prototypes.get("Letter").duplicate()

func _on_dialogic_signal(argument: String):

    if argument.match ("hit*"):
        var damage_amount = argument.substr(3).to_int()
        portrait_c.hit(damage_amount)
        portrait_c.card_data["hp"] -= damage_amount
        return
    if Global.card_prototypes.has(argument) and portrait_c.card_data != Global.card_prototypes.get(argument):
        if scale_twn != null: scale_twn.kill()
        portrait_c.scale = Vector2(0.5, 0.5)
        scale_twn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
        scale_twn.tween_property(portrait_c, "scale", Vector2(1.2, 1.2), 0.5)
        portrait_c.card_data = Global.card_prototypes.get(argument).duplicate()
        portrait_c.play_burn(true, Tween.EASE_OUT, Tween.TRANS_QUART, 0.5, false)
        portrait_c.glow(1.0)
        portrait_c.play_do_effect()
    if argument == "" or Global.card_prototypes.has(argument): portrait_c.play_do_effect()
    if argument == "black": self.modulate = Color(0.056, 0.056, 0.056)
    elif argument == "white": self.modulate = Color.WHITE


func _get_covered_rect() -> Rect2:
    return Rect2(portrait_c.global_position, portrait_c.size)
