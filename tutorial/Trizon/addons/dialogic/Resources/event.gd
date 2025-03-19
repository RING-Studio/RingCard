@tool
class_name DialogicEvent
extends Resource








signal event_started(event_resource: DialogicEvent)



signal event_finished(event_resource: DialogicEvent)





var event_name: = "Event"

var _translation_id: = ""

var dialogic: DialogicGameHandler = null






var needs_indentation: = false

var can_contain_events: = false

var end_branch_event: DialogicEndBranchEvent = null

var wants_to_group: = false





var event_node_as_text: = ""

var event_node_ready: = false

var empty_lines_above: int = 0





var event_color: = Color("FBB13C")

var dialogic_color_name: = ""

var event_sorting_index: int = 0

var disable_editor_button: = false

var expand_by_default: = false

var help_page_path: = ""

var created_by_button: = false



var editor_node: Control = null


var event_category: = "Other"





enum Location{HEADER, BODY}


enum ValueType{

    MULTILINE_TEXT, SINGLELINE_TEXT, CONDITION, FILE, 

    BOOL, BOOL_BUTTON, 

    DYNAMIC_OPTIONS, FIXED_OPTIONS, 

    ARRAY, DICTIONARY, 

    NUMBER, 
    VECTOR2, VECTOR3, VECTOR4, 

    CUSTOM, BUTTON, LABEL, COLOR, AUDIO_PREVIEW
}

var editor_list: Array = []

var this_folder: String = get_script().resource_path.get_base_dir()


signal ui_update_needed
signal ui_update_warning(text: String)



func _to_string() -> String:
    return "[{name}:{id}]".format({"name": event_name, "id": get_instance_id()})








func execute(_dialogic_game_handler) -> void :
    event_started.emit(self)
    dialogic = _dialogic_game_handler
    call_deferred("_execute")



func finish() -> void :
    event_finished.emit(self)






func _clear_state() -> void :
    pass



func _execute() -> void :
    finish()










func get_end_branch_control() -> Control:
    return null






func should_execute_this_branch() -> bool:
    return false








func _get_translatable_properties() -> Array:
    return []



func _get_property_original_translation(_property_name: String) -> String:
    return ""




func can_be_translated() -> bool:
    return !_get_translatable_properties().is_empty()



func add_translation_id() -> String:
    _translation_id = DialogicUtil.get_next_translation_id()
    return _translation_id


func remove_translation_id() -> void :
    _translation_id = ""


func get_property_translation_key(property_name: String) -> String:
    return event_name.path_join(_translation_id).path_join(property_name)



func get_property_translated(property_name: String) -> String:
    if !_translation_id.is_empty() and ProjectSettings.get_setting("dialogic/translation/enabled", false):
        var translation: = tr(get_property_translation_key(property_name))

        return translation if translation != get_property_translation_key(property_name) else _get_property_original_translation(property_name)
    else:
        return _get_property_original_translation(property_name)










func _store_as_string() -> String:
    if !_translation_id.is_empty() and can_be_translated():
        return to_text() + " #id:" + str(_translation_id)
    else:
        return to_text()



func update_text_version() -> void :
    event_node_as_text = _store_as_string()



func _load_from_string(string: String) -> void :
    _load_custom_defaults()
    if "#id:" in string and can_be_translated():
        _translation_id = string.get_slice("#id:", 1).strip_edges()
        from_text(string.get_slice("#id:", 0))
    else:
        from_text(string)
    event_node_ready = true



func _load_custom_defaults() -> void :
    for default_prop in DialogicUtil.get_custom_event_defaults(event_name):
        if default_prop in self:
            set(default_prop, DialogicUtil.get_custom_event_defaults(event_name)[default_prop])



func _test_event_string(string: String) -> bool:
    if "#id:" in string and can_be_translated():
        return is_valid_event(string.get_slice("#id:", 0))
    return is_valid_event(string.strip_edges())









func get_shortcode() -> String:
    return "default_shortcode"



func get_shortcode_parameters() -> Dictionary:
    return {}




func to_text() -> String:
    var shortcode: = store_to_shortcode_parameters()
    if shortcode:
        return "[" + self.get_shortcode() + " " + store_to_shortcode_parameters() + "]"
    else:
        return "[" + self.get_shortcode() + "]"




func from_text(string: String) -> void :
    load_from_shortcode_parameters(string)



func store_to_shortcode_parameters(params: Dictionary = {}) -> String:
    if params.is_empty():
        params = get_shortcode_parameters()
    var custom_defaults: Dictionary = DialogicUtil.get_custom_event_defaults(event_name)
    var result_string: = ""
    for parameter in params.keys():
        var parameter_info: Dictionary = params[parameter]
        var value: Variant = get(parameter_info.property)
        var default_value: Variant = custom_defaults.get(parameter_info.property, parameter_info.default)

        if parameter_info.get("custom_stored", false):
            continue

        if "set_" + parameter_info.property in self and not get("set_" + parameter_info.property):
            continue

        if typeof(value) == typeof(default_value) and value == default_value:
            if not "set_" + parameter_info.property in self or not get("set_" + parameter_info.property):
                continue

        result_string += " " + parameter + "=\"" + value_to_string(value, parameter_info.get("suggestions", Callable())) + "\""

    return result_string.strip_edges()


func value_to_string(value: Variant, suggestions: = Callable()) -> String:
    var value_as_string: = ""
    match typeof(value):
        TYPE_OBJECT:
            value_as_string = str(value.resource_path)

        TYPE_STRING:
            value_as_string = value

        TYPE_INT when suggestions.is_valid():

            for option in suggestions.call().values():
                if option.value != value:
                    continue

                if option.has("text_alt"):
                    value_as_string = option.text_alt[0]
                else:
                    value_as_string = var_to_str(option.value)

                break

        TYPE_DICTIONARY:
            value_as_string = JSON.stringify(value)

        _:
            value_as_string = var_to_str(value)

    if not ((value_as_string.begins_with("[") and value_as_string.ends_with("]")) or (value_as_string.begins_with("{") and value_as_string.ends_with("}"))):
        value_as_string.replace("\"", "\\\"")

    return value_as_string


func load_from_shortcode_parameters(string: String) -> void :
    var data: Dictionary = parse_shortcode_parameters(string)
    var params: Dictionary = get_shortcode_parameters()
    for parameter in params.keys():
        var parameter_info: Dictionary = params[parameter]
        if parameter_info.get("custom_stored", false):
            continue

        if not parameter in data:
            if "set_" + parameter_info.property in self:
                set("set_" + parameter_info.property, false)
            continue

        if "set_" + parameter_info.property in self:
            set("set_" + parameter_info.property, true)

        var param_value: String = data[parameter].replace("\\\"", "\"")
        var value: Variant
        match typeof(get(parameter_info.property)):
            TYPE_STRING:
                value = param_value

            TYPE_INT:

                if parameter_info.has("suggestions"):
                    for option in parameter_info.suggestions.call().values():
                        if option.has("text_alt") and param_value in option.text_alt:
                            value = option.value
                            break

                if not value:
                    value = float(param_value)

            _:
                value = str_to_var(param_value)

        set(parameter_info.property, value)



func is_valid_event(string: String) -> bool:
    if string.strip_edges().begins_with("[" + get_shortcode() + " ") or string.strip_edges().begins_with("[" + get_shortcode() + "]"):
        return true
    return false





func is_string_full_event(string: String) -> bool:
    if get_shortcode() != "default_shortcode": return string.strip_edges().ends_with("]")
    return true



func parse_shortcode_parameters(shortcode: String) -> Dictionary:
    var regex: = RegEx.new()
    regex.compile("(?<parameter>[^\\s=]*)\\s*=\\s*\"(?<value>(\\{[^}]*\\}|\\[[^]]*\\]|([^\"]|\\\\\")*|))(?<!\\\\)\\\"")
    var dict: = {}
    for result in regex.search_all(shortcode):
        dict[result.get_string("parameter")] = result.get_string("value")
    return dict







func _get_icon() -> Resource:
    var _icon_file_name: = "res://addons/dialogic/Editor/Images/Pieces/closed-icon.svg"

    if ResourceLoader.exists(self.get_script().get_path().get_base_dir() + "/icon.svg"):
        _icon_file_name = self.get_script().get_path().get_base_dir() + "/icon.svg"
    elif ResourceLoader.exists(self.get_script().get_path().get_base_dir() + "/icon.png"):
        _icon_file_name = self.get_script().get_path().get_base_dir() + "/icon.png"
    return load(_icon_file_name)


func set_default_color(value: Variant) -> void :
    dialogic_color_name = value
    event_color = DialogicUtil.get_color(value)



func _enter_visual_editor(_timeline_editor: DialogicEditor) -> void :
    pass








func _get_code_completion(_CodeCompletionHelper: Node, _TextNode: TextEdit, _line: String, _word: String, _symbol: String) -> void :
    pass


func _get_start_code_completion(_CodeCompletionHelper: Node, _TextNode: TextEdit) -> void :
    pass







func _get_syntax_highlighting(_Highlighter: SyntaxHighlighter, dict: Dictionary, _line: String) -> Dictionary:
    return dict







func get_event_editor_info() -> Array:
    if Engine.is_editor_hint():
        if editor_list != null:
            editor_list.clear()
        else:
            editor_list = []

        build_event_editor()
        return editor_list
    else:
        return []



func build_event_editor() -> void :
    pass










func add_header_label(text: String, condition: = "") -> void :
    editor_list.append({
        "name": "something", 
        "type": + TYPE_STRING, 
        "location": Location.HEADER, 
        "usage": PROPERTY_USAGE_EDITOR, 
        "field_type": ValueType.LABEL, 
        "display_info": {"text": text}, 
        "condition": condition
        })


func add_header_edit(variable: String, editor_type: = ValueType.LABEL, extra_info: = {}, condition: = "") -> void :
    editor_list.append({
        "name": variable, 
        "type": typeof(get(variable)), 
        "location": Location.HEADER, 
        "usage": PROPERTY_USAGE_DEFAULT, 
        "field_type": editor_type, 
        "display_info": extra_info, 
        "left_text": extra_info.get("left_text", ""), 
        "right_text": extra_info.get("right_text", ""), 
        "condition": condition, 
        })


func add_header_button(text: String, callable: Callable, tooltip: String, icon: Variant = null, condition: = "") -> void :
    editor_list.append({
        "name": "Button", 
        "type": TYPE_STRING, 
        "location": Location.HEADER, 
        "usage": PROPERTY_USAGE_DEFAULT, 
        "field_type": ValueType.BUTTON, 
        "display_info": {"text": text, "tooltip": tooltip, "callable": callable, "icon": icon}, 
        "condition": condition, 
    })


func add_body_edit(variable: String, editor_type: = ValueType.LABEL, extra_info: = {}, condition: = "") -> void :
    editor_list.append({
        "name": variable, 
        "type": typeof(get(variable)), 
        "location": Location.BODY, 
        "usage": PROPERTY_USAGE_DEFAULT, 
        "field_type": editor_type, 
        "display_info": extra_info, 
        "left_text": extra_info.get("left_text", ""), 
        "right_text": extra_info.get("right_text", ""), 
        "condition": condition, 
        })


func add_body_line_break(condition: = "") -> void :
    editor_list.append({
        "name": "linebreak", 
        "type": TYPE_BOOL, 
        "location": Location.BODY, 
        "usage": PROPERTY_USAGE_DEFAULT, 
        "condition": condition, 
        })
