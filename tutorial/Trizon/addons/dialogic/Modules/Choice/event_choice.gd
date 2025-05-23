@tool
class_name DialogicChoiceEvent
extends DialogicEvent



enum ElseActions{HIDE = 0, DISABLE = 1, DEFAULT = 2}




var text: = ""

var condition: = ""

var else_action: = ElseActions.DEFAULT


var disabled_text: = ""


var extra_data: = {}



var _has_condition: = false



var regex: = RegEx.create_from_string("- (?<text>(?>\\\\\\||(?(?=.*\\|)[^|]|(?!\\[if)[^|]))*)\\|?\\s*(\\[if(?<condition>([^\\]\\[]|\\[[^\\]]*\\])+)\\])?\\s*(\\[(?<shortcode>[^]]*)\\])?")




func _execute() -> void :
    if dialogic.Choices.is_question(dialogic.current_event_idx):
        dialogic.Choices.show_current_question(false)
        dialogic.current_state = dialogic.States.AWAITING_CHOICE







func _init() -> void :
    event_name = "Choice"
    set_default_color("Color3")
    event_category = "Flow"
    event_sorting_index = 0
    can_contain_events = true
    wants_to_group = true



func get_end_branch_control() -> Control:
    return load(get_script().resource_path.get_base_dir().path_join("ui_choice_end.tscn")).instantiate()






func to_text() -> String:
    var result_string: = ""

    result_string = "- " + text.strip_edges()
    var shortcode: = store_to_shortcode_parameters()
    if (condition and _has_condition) or shortcode or extra_data:
        result_string += " |"
    if condition and _has_condition:
        result_string += " [if " + condition + "]"

    if shortcode or extra_data:
        result_string += " [" + shortcode
        if extra_data:
            var extra_data_string: = ""
            for i in extra_data:
                extra_data_string += " " + i + "=\"" + value_to_string(extra_data[i]) + "\""
            if shortcode:
                result_string += " "
            result_string += extra_data_string.strip_edges()
        result_string += "]"

    return result_string


func from_text(string: String) -> void :
    var result: = regex.search(string.strip_edges())
    if result == null:
        return
    text = result.get_string("text").strip_edges()
    condition = result.get_string("condition").strip_edges()
    _has_condition = not condition.is_empty()
    if result.get_string("shortcode"):
        load_from_shortcode_parameters(result.get_string("shortcode"))
        var shortcode: = parse_shortcode_parameters(result.get_string("shortcode"))
        shortcode.erase("else")
        shortcode.erase("alt_text")
        extra_data = shortcode.duplicate()


func get_shortcode_parameters() -> Dictionary:
    return {
        "else": {"property": "else_action", "default": ElseActions.DEFAULT, 
                                    "suggestions": func(): return {
                                        "Default": {"value": ElseActions.DEFAULT, "text_alt": ["default"]}, 
                                        "Hide": {"value": ElseActions.HIDE, "text_alt": ["hide"]}, 
                                        "Disable": {"value": ElseActions.DISABLE, "text_alt": ["disable"]}}}, 
        "alt_text": {"property": "disabled_text", "default": ""}, 
        "extra_data": {"property": "extra_data", "default": {}, "custom_stored": true}, 
        }


func is_valid_event(string: String) -> bool:
    if string.strip_edges().begins_with("-"):
        return true
    return false






func _get_translatable_properties() -> Array:
    return ["text", "disabled_text"]


func _get_property_original_translation(property: String) -> String:
    match property:
        "text":
            return text
        "disabled_text":
            return disabled_text
    return ""






func build_event_editor() -> void :
    add_header_edit("text", ValueType.SINGLELINE_TEXT, {"autofocus": true})
    add_body_edit("", ValueType.LABEL, {"text": "Condition:"})
    add_body_edit("_has_condition", ValueType.BOOL_BUTTON, {"editor_icon": ["Add", "EditorIcons"], "tooltip": "Add Condition"}, "not _has_condition")
    add_body_edit("condition", ValueType.CONDITION, {}, "_has_condition")
    add_body_edit("_has_condition", ValueType.BOOL_BUTTON, {"editor_icon": ["Remove", "EditorIcons"], "tooltip": "Remove Condition"}, "_has_condition")
    add_body_edit("else_action", ValueType.FIXED_OPTIONS, {"left_text": "Else:", 
        "options": [
            {
                "label": "Default", 
                "value": ElseActions.DEFAULT, 
            }, 
            {
                "label": "Hide", 
                "value": ElseActions.HIDE, 
            }, 
            {
                "label": "Disable", 
                "value": ElseActions.DISABLE, 
            }
        ]}, "_has_condition")
    add_body_edit("disabled_text", ValueType.SINGLELINE_TEXT, {
            "left_text": "Disabled text:", 
            "placeholder": "(Empty for same)"}, "allow_alt_text()")
    add_body_line_break()
    add_body_edit("extra_data", ValueType.DICTIONARY, {"left_text": "Extra Data:"})


func allow_alt_text() -> bool:
    return _has_condition and (
        else_action == ElseActions.DISABLE or 
        (else_action == ElseActions.DEFAULT and 
        ProjectSettings.get_setting("dialogic/choices/def_false_behaviour", 0) == 1))






func _get_code_completion(CodeCompletionHelper: Node, TextNode: TextEdit, line: String, _word: String, symbol: String) -> void :
    line = CodeCompletionHelper.get_line_untill_caret(line)

    if !"[if" in line:
        if symbol == "{":
            CodeCompletionHelper.suggest_variables(TextNode)
        return

    if symbol == "[":
        if !"[if" in line and line.count("[") - line.count("]") == 1:
            TextNode.add_code_completion_option(CodeEdit.KIND_MEMBER, "if", "if ", TextNode.syntax_highlighter.code_flow_color)
        elif "[if" in line:
            TextNode.add_code_completion_option(CodeEdit.KIND_MEMBER, "else", "else=\"", TextNode.syntax_highlighter.code_flow_color)
    if symbol == " " and "[else" in line:
        TextNode.add_code_completion_option(CodeEdit.KIND_MEMBER, "alt_text", "alt_text=\"", event_color.lerp(TextNode.syntax_highlighter.normal_color, 0.5))
    elif symbol == "{":
        CodeCompletionHelper.suggest_variables(TextNode)
    if (symbol == "=" or symbol == "\"") and line.count("[") > 1 and !"\" " in line:
        TextNode.add_code_completion_option(CodeEdit.KIND_MEMBER, "default", "default", event_color.lerp(TextNode.syntax_highlighter.normal_color, 0.5), null, "\"")
        TextNode.add_code_completion_option(CodeEdit.KIND_MEMBER, "hide", "hide", event_color.lerp(TextNode.syntax_highlighter.normal_color, 0.5), null, "\"")
        TextNode.add_code_completion_option(CodeEdit.KIND_MEMBER, "disable", "disable", event_color.lerp(TextNode.syntax_highlighter.normal_color, 0.5), null, "\"")






func _get_syntax_highlighting(Highlighter: SyntaxHighlighter, dict: Dictionary, line: String) -> Dictionary:
    var result: = regex.search(line)

    dict[0] = {"color": event_color}

    if not result:
        return dict

    var condition_begin: = result.get_start("condition")
    var condition_end: = result.get_end("condition")

    var shortcode_begin: = result.get_start("shortcode")

    dict = Highlighter.color_region(dict, event_color.lerp(Highlighter.variable_color, 0.5), line, "{", "}", 0, condition_begin, event_color)

    if condition_begin > 0:
        var from: = line.find("[if")
        dict[from] = {"color": Highlighter.normal_color}
        dict[from + 1] = {"color": Highlighter.code_flow_color}
        dict[condition_begin] = {"color": Highlighter.normal_color}
        dict = Highlighter.color_condition(dict, line, condition_begin, condition_end)
    if shortcode_begin:
        dict = Highlighter.color_shortcode_content(dict, line, shortcode_begin, 0, event_color)
    return dict
