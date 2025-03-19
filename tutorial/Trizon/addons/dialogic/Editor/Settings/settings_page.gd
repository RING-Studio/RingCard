@tool
extends Control
class_name DialogicSettingsPage

@export_multiline var short_info: = ""


func _get_title() -> String:
    return name



func _get_priority() -> int:
    return 0



func _is_feature_tab() -> bool:
    return false



func _refresh() -> void :
    pass




func _about_to_close() -> void :
    pass



func _get_info_section() -> Control:
    return null
