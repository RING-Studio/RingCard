@tool
class_name DialogicSaveEvent
extends DialogicEvent








var slot_name: = ""






func _execute() -> void :
    if slot_name.is_empty():
        if dialogic.Save.get_latest_slot():
            dialogic.Save.save(dialogic.Save.get_latest_slot())
        else:
            dialogic.Save.save()
    else:
        dialogic.Save.save(slot_name)
    finish()






func _init() -> void :
    event_name = "Save"
    set_default_color("Color6")
    event_category = "Other"
    event_sorting_index = 0


func _get_icon() -> Resource:
    return load(self.get_script().get_path().get_base_dir().path_join("icon.svg"))






func get_shortcode() -> String:
    return "save"


func get_shortcode_parameters() -> Dictionary:
    return {

        "slot": {"property": "slot_name", "default": "Default"}, 
    }






func build_event_editor() -> void :
    add_header_edit("slot_name", ValueType.SINGLELINE_TEXT, {"left_text": "Save to slot"})
