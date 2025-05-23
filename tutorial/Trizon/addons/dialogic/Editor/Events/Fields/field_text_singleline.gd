@tool
extends DialogicVisualEditorField




var placeholder: = "":
    set(value):
        placeholder = value
        self.placeholder_text = placeholder





func _ready() -> void :
    self.text_changed.connect(_on_text_changed)


func _load_display_info(info: Dictionary) -> void :
    self.placeholder = info.get("placeholder", "")


func _set_value(value: Variant) -> void :
    self.text = str(value)


func _autofocus() -> void :
    grab_focus()







func _on_text_changed(value: = "") -> void :
    value_changed.emit(property_name, self.text)
