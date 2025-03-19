@tool
extends DialogicEvent




func _execute() -> void :

    finish()






func _init() -> void :
    event_name = "Default"
    event_color = Color("#ffffff")
    event_category = "Main"
    event_sorting_index = 0






func get_shortcode() -> String:
    return "default_shortcode"


func get_shortcode_parameters() -> Dictionary:
    return {


    }












func build_event_editor() -> void :
    pass
