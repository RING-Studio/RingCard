extends Control
@onready var parent = get_parent()
@onready var aura = $aura
@onready var parent_original_text
var showing: bool = false
var tween: Tween

func _ready():

    global_position = parent.global_position - Vector2(1.0, 1.0)
    size = parent.size + Vector2(2.0, 2.0)
    aura.global_position = parent.global_position
    aura.size = parent.size
    parent.pressed.connect(reset_aura)

func reset_aura():
    if tween != null: tween.kill()
    tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
    tween.tween_property(aura.material, "shader_parameter/alpha", 0.0, 0.5)
    parent.text = parent_original_text
    showing = false

func _gui_input(event):
    if ( !showing and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and 
    event.is_pressed() and parent.mouse_filter != Control.MOUSE_FILTER_IGNORE):
        showing = true
        parent_original_text = parent.text
        if tween != null: tween.kill()
        tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
        tween.tween_property(aura.material, "shader_parameter/alpha", 1.0, 0.5)
        parent.text = tr("CONFIRM") + "?"

        accept_event()

func _on_mouse_exited():
    if showing: reset_aura()

func _on_mouse_entered():
    parent_original_text = parent.text
