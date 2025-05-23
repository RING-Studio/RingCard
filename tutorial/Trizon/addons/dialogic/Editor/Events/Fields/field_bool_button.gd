@tool
extends DialogicVisualEditorField






func _ready() -> void :
    add_theme_color_override("icon_normal_color", get_theme_color("disabled_font_color", "Editor"))
    add_theme_color_override("icon_hover_color", get_theme_color("warning_color", "Editor"))
    add_theme_color_override("icon_pressed_color", get_theme_color("icon_saturation", "Editor"))
    add_theme_color_override("icon_hover_pressed_color", get_theme_color("warning_color", "Editor"))
    add_theme_color_override("icon_focus_color", get_theme_color("disabled_font_color", "Editor"))
    self.toggled.connect(_on_value_changed)


func _load_display_info(info: Dictionary) -> void :
    if info.has("editor_icon"):
        if not is_inside_tree():
            await ready
        self.icon = callv("get_theme_icon", info.editor_icon)
    else:
        self.icon = info.get("icon", null)


func _set_value(value: Variant) -> void :
    self.button_pressed = true if value else false







func _on_value_changed(value: bool) -> void :
    value_changed.emit(property_name, value)
