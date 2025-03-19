@tool
class_name DialogicCharacterEditorPortraitSection
extends Control






signal changed

signal update_preview


var character_editor: Control


var selected_item: TreeItem = null


var hint_text: = ""



func _get_title() -> String:
    return "CustomSection"



func _show_title() -> bool:
    return true



func _start_opened() -> bool:
    return false



func _load_portrait_data(data: Dictionary) -> void :
    pass





func _recheck(data: Dictionary) -> void :
    pass
