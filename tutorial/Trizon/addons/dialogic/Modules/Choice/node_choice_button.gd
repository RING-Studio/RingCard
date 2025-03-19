class_name DialogicNode_ChoiceButton
extends Button













@export var choice_index: int = -1


@export var sound_pressed: AudioStream

@export var sound_hover: AudioStream

@export var sound_focus: AudioStream

@export var text_node: Node


func _ready() -> void :
    add_to_group("dialogic_choice_button")
    shortcut_in_tooltip = false
    hide()


func _load_info(choice_info: Dictionary) -> void :
    set_choice_text(choice_info.text)
    visible = choice_info.visible
    disabled = choice_info.disabled



func set_choice_text(new_text: String) -> void :
    if text_node:
        text_node.text = new_text
    else:
        text = new_text
