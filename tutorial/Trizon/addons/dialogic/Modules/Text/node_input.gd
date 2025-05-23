class_name DialogicNode_Input
extends Control





func _ready() -> void :
    add_to_group("dialogic_input")
    gui_input.connect(_on_gui_input)


func _input(_event: InputEvent) -> void :
    if Input.is_action_pressed(ProjectSettings.get_setting("dialogic/text/input_action", "dialogic_default_action")):
        mouse_filter = Control.MOUSE_FILTER_STOP
    else:
        mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_gui_input(event: InputEvent) -> void :
    DialogicUtil.autoload().Inputs.handle_node_gui_input(event)
