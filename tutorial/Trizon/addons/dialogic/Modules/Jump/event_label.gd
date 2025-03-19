@tool
class_name DialogicLabelEvent
extends DialogicEvent







var name: = ""
var display_name: = ""







func _execute() -> void :

    dialogic.Jump.passed_label.emit(
        {
            "identifier": name, 
            "display_name": get_property_translated("display_name"), 
            "display_name_orig": display_name, 
            "timeline": DialogicResourceUtil.get_unique_identifier(dialogic.current_timeline.resource_path)
        })
    finish()






func _init() -> void :
    event_name = "Label"
    set_default_color("Color4")
    event_category = "Flow"
    event_sorting_index = 3


func _get_icon() -> Resource:
    return load(self.get_script().get_path().get_base_dir().path_join("icon_label.png"))





func to_text() -> String:
    if display_name.is_empty():
        return "label " + name
    else:
        return "label " + name + " (" + display_name + ")"



func from_text(string: String) -> void :
    var regex: = RegEx.create_from_string("label +(?<name>[^(]+)(\\((?<display_name>.+)\\))?")
    var result: = regex.search(string.strip_edges())
    if result:
        name = result.get_string("name").strip_edges()
        display_name = result.get_string("display_name").strip_edges()


func is_valid_event(string: String) -> bool:
    if string.strip_edges().begins_with("label"):
        return true
    return false




func get_shortcode_parameters() -> Dictionary:
    return {

        "name": {"property": "name", "default": ""}, 
        "display": {"property": "display_name", "default": ""}, 
    }


func _get_translatable_properties() -> Array:
    return ["display_name"]


func _get_property_original_translation(property_name: String) -> String:
    match property_name:
        "display_name":
            return display_name
    return ""





func build_event_editor() -> void :
    add_header_edit("name", ValueType.SINGLELINE_TEXT, {"left_text": "Label", "autofocus": true})
    add_body_edit("display_name", ValueType.SINGLELINE_TEXT, {"left_text": "Display Name:"})





func _get_start_code_completion(_CodeCompletionHelper: Node, TextNode: TextEdit) -> void :
    TextNode.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, "label", "label ", event_color.lerp(TextNode.syntax_highlighter.normal_color, 0.3))





func _get_syntax_highlighting(Highlighter: SyntaxHighlighter, dict: Dictionary, line: String) -> Dictionary:
    dict[line.find("label")] = {"color": event_color.lerp(Highlighter.normal_color, 0.3)}
    dict[line.find("label") + 5] = {"color": event_color.lerp(Highlighter.normal_color, 0.5)}
    return dict
