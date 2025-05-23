class_name DialogicNode_TextInput
extends Control





@export_node_path var input_line_edit: NodePath

@export_node_path var text_label: NodePath

@export_node_path var confirmation_button: NodePath


var _allow_empty: = false


func _ready() -> void :
    add_to_group("dialogic_text_input")
    if confirmation_button:
        get_node(confirmation_button).pressed.connect(_on_confirmation_button_pressed)
    if input_line_edit:
        get_node(input_line_edit).text_changed.connect(_on_input_text_changed)
        get_node(input_line_edit).text_submitted.connect(_on_confirmation_button_pressed)
    visible = false


func set_text(text: String) -> void :
    if get_node(text_label) is Label:
        get_node(text_label).text = text


func set_placeholder(placeholder: String) -> void :
    if get_node(input_line_edit) is LineEdit:
        get_node(input_line_edit).placeholder_text = placeholder
        get_node(input_line_edit).grab_focus()


func set_default(default: String) -> void :
    if get_node(input_line_edit) is LineEdit:
        get_node(input_line_edit).text = default
        _on_input_text_changed(default)


func set_allow_empty(boolean: bool) -> void :
    _allow_empty = boolean


func _on_input_text_changed(text: String) -> void :
    if confirmation_button.is_empty():
        return
    get_node(confirmation_button).disabled = !_allow_empty and text.is_empty()


func _on_confirmation_button_pressed(text: = "") -> void :
    if get_node(input_line_edit) is LineEdit:
        if !get_node(input_line_edit).text.is_empty() or _allow_empty:
            DialogicUtil.autoload().TextInput.input_confirmed.emit(get_node(input_line_edit).text)
