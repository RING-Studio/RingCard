@tool
class_name DialogicVisualEditorField
extends Control

signal value_changed(property_name: String, value: Variant)
var property_name: = ""

var event_resource: DialogicEvent = null





func _load_display_info(info: Dictionary) -> void :
    pass



func _set_value(value: Variant) -> void :
    pass



func _autofocus() -> void :
    pass




func set_value(value: Variant) -> void :
    _set_value(value)


func take_autofocus() -> void :
    _autofocus()
