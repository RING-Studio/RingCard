class_name DialogicNode_ButtonSound
extends AudioStreamPlayer





@export var sound_pressed: AudioStream

@export var sound_hover: AudioStream

@export var sound_focus: AudioStream

func _ready() -> void :
    add_to_group("dialogic_button_sound")
    _connect_all_buttons()


func play_sound(sound) -> void :
    if sound != null:
        stream = sound
        play()

func _connect_all_buttons() -> void :
    for child in get_parent().get_children():
        if child is DialogicNode_ChoiceButton:
            child.button_up.connect(_on_pressed.bind(child.sound_pressed))
            child.mouse_entered.connect(_on_hover.bind(child.sound_hover))
            child.focus_entered.connect(_on_focus.bind(child.sound_focus))





func _on_pressed(custom_sound) -> void :
    if custom_sound != null:
        play_sound(custom_sound)
    else:
        play_sound(sound_pressed)

func _on_hover(custom_sound) -> void :
    if custom_sound != null:
        play_sound(custom_sound)
    else:
        play_sound(sound_hover)

func _on_focus(custom_sound) -> void :
    if custom_sound != null:
        play_sound(custom_sound)
    else:
        play_sound(sound_focus)
