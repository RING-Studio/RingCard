@tool
class_name DialogicConditionEvent
extends DialogicEvent



enum ConditionTypes{IF, ELIF, ELSE}



var condition_type: = ConditionTypes.IF

var condition: = ""






func _execute() -> void :
    if condition_type == ConditionTypes.ELSE:
        finish()
        return

    if condition.is_empty(): condition = "true"

    var result: bool = dialogic.Expressions.execute_condition(condition)
    if not result:
        var idx: int = dialogic.current_event_idx
        var ignore: = 1
        while true:
            idx += 1
            if not dialogic.current_timeline.get_event(idx) or ignore == 0:
                break
            elif dialogic.current_timeline.get_event(idx).can_contain_events:
                ignore += 1
            elif dialogic.current_timeline.get_event(idx) is DialogicEndBranchEvent:
                ignore -= 1

        dialogic.current_event_idx = idx - 1
    finish()




func should_execute_this_branch() -> bool:
    return condition_type == ConditionTypes.IF






func _init() -> void :
    event_name = "Condition"
    set_default_color("Color3")
    event_category = "Flow"
    event_sorting_index = 1
    can_contain_events = true



func get_end_branch_control() -> Control:
    return load(get_script().resource_path.get_base_dir().path_join("ui_condition_end.tscn")).instantiate()





func to_text() -> String:
    var result_string: = ""

    match condition_type:
        ConditionTypes.IF:
            result_string = "if " + condition + ":"
        ConditionTypes.ELIF:
            result_string = "elif " + condition + ":"
        ConditionTypes.ELSE:
            result_string = "else:"

    return result_string


func from_text(string: String) -> void :
    if string.strip_edges().begins_with("if"):
        condition = string.strip_edges().trim_prefix("if ").trim_suffix(":").strip_edges()
        condition_type = ConditionTypes.IF
    elif string.strip_edges().begins_with("elif"):
        condition = string.strip_edges().trim_prefix("elif ").trim_suffix(":").strip_edges()
        condition_type = ConditionTypes.ELIF
    elif string.strip_edges().begins_with("else"):
        condition = ""
        condition_type = ConditionTypes.ELSE


func is_valid_event(string: String) -> bool:
    if string.strip_edges() in ["if", "elif", "else"] or (string.strip_edges().begins_with("if ") or string.strip_edges().begins_with("elif ") or string.strip_edges().begins_with("else")):
        return true
    return false






func build_event_editor() -> void :
    add_header_edit("condition_type", ValueType.FIXED_OPTIONS, {
        "options": [
            {
                "label": "IF", 
                "value": ConditionTypes.IF, 
            }, 
            {
                "label": "ELIF", 
                "value": ConditionTypes.ELIF, 
            }, 
            {
                "label": "ELSE", 
                "value": ConditionTypes.ELSE, 
            }
        ], "disabled": true})
    add_header_edit("condition", ValueType.CONDITION, {}, "condition_type != %s" % ConditionTypes.ELSE)





func _get_code_completion(CodeCompletionHelper: Node, TextNode: TextEdit, line: String, _word: String, symbol: String) -> void :
    if (line.begins_with("if") or line.begins_with("elif")) and symbol == "{":
        CodeCompletionHelper.suggest_variables(TextNode)


func _get_start_code_completion(_CodeCompletionHelper: Node, TextNode: TextEdit) -> void :
    TextNode.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, "if", "if ", TextNode.syntax_highlighter.code_flow_color)
    TextNode.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, "elif", "elif ", TextNode.syntax_highlighter.code_flow_color)
    TextNode.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, "else", "else:\n	", TextNode.syntax_highlighter.code_flow_color)






func _get_syntax_highlighting(Highlighter: SyntaxHighlighter, dict: Dictionary, line: String) -> Dictionary:
    var word: = line.get_slice(" ", 0)
    dict[line.find(word)] = {"color": Highlighter.code_flow_color}
    dict[line.find(word) + len(word)] = {"color": Highlighter.normal_color}
    dict = Highlighter.color_condition(dict, line)
    return dict
