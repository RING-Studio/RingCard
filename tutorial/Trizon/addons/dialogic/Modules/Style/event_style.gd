@tool
class_name DialogicStyleEvent
extends DialogicEvent







var style_name: = ""






func _execute() -> void :
    dialogic.Styles.change_style(style_name)

    await dialogic.get_tree().process_frame
    finish()






func _init() -> void :
    event_name = "Change Style"
    set_default_color("Color8")
    event_category = "Visuals"
    event_sorting_index = 1





func get_shortcode() -> String:
    return "style"


func get_shortcode_parameters() -> Dictionary:
    return {

        "name": {"property": "style_name", "default": "", "suggestions": get_style_suggestions}, 
    }






func build_event_editor() -> void :
    add_header_edit("style_name", ValueType.DYNAMIC_OPTIONS, {
            "left_text": "Use style", 
            "placeholder": "Default", 
            "suggestions_func": get_style_suggestions, 
            "editor_icon": ["PopupMenu", "EditorIcons"], 
            "autofocus": true})


func get_style_suggestions(_filter: = "") -> Dictionary:
    var styles: Array = ProjectSettings.get_setting("dialogic/layout/style_list", [])

    var suggestions: = {}
    suggestions["<Default Style>"] = {"value": "", "editor_icon": ["MenuBar", "EditorIcons"]}
    for i in styles:
        var style: DialogicStyle = load(i)
        suggestions[style.name] = {"value": style.name, "editor_icon": ["PopupMenu", "EditorIcons"]}
    return suggestions
