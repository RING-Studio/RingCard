@tool
class_name DialogicEndTimelineEvent
extends DialogicEvent







func _execute() -> void :
    dialogic.end_timeline()







func _init() -> void :
    event_name = "End"
    set_default_color("Color4")
    event_category = "Flow"
    event_sorting_index = 10







func get_shortcode() -> String:
    return "end_timeline"







func build_event_editor() -> void :
    add_header_label("End Timeline")
