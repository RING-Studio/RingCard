@tool
class_name DialogicGlossaryEvent
extends DialogicEvent








func _execute() -> void :
    pass






func _init() -> void :
    event_name = "Glossary"
    set_default_color("Color6")
    event_category = "Other"
    event_sorting_index = 0





func get_shortcode() -> String:
    return "glossary"

func get_shortcode_parameters() -> Dictionary:
    return {
    }





func build_event_editor() -> void :
    pass
