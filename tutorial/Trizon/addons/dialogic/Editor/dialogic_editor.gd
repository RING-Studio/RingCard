@tool
class_name DialogicEditor
extends Control




signal resource_saved()
signal resource_unsaved()

signal opened

var current_resource: Resource


enum ResourceStates{SAVED, UNSAVED}
var current_resource_state: ResourceStates:
    set(value):
        current_resource_state = value
        if value == ResourceStates.SAVED:
            resource_saved.emit()
        else:
            resource_unsaved.emit()

var editors_manager: Control

var alternative_text: String = ""


func _register() -> void :
    pass



func _get_icon() -> Texture:
    return null


func _get_title() -> String:
    return ""



func _open_resource(_resource: Resource) -> void :
    pass



func _save() -> void :
    pass



func _open(_extra_info: Variant = null) -> void :
    pass



func _close() -> void :
    pass




func _clear() -> void :
    pass
