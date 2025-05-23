@tool
class_name DialogicReturnEvent
extends DialogicEvent









func _execute() -> void :
    if !dialogic.Jump.is_jump_stack_empty():
        dialogic.Jump.resume_from_last_jump()
    else:
        dialogic.end_timeline()






func _init() -> void :
    event_name = "Return"
    set_default_color("Color4")
    event_category = "Flow"
    event_sorting_index = 5


func _get_icon() -> Resource:
    return load(self.get_script().get_path().get_base_dir().path_join("icon_return.svg"))





func to_text() -> String:
    return "return"


func from_text(_string: String) -> void :
    pass


func is_valid_event(string: String) -> bool:
    if string.strip_edges() == "return":
        return true
    return false






func build_event_editor() -> void :
    add_header_label("Return")





func _get_start_code_completion(_CodeCompletionHelper: Node, TextNode: TextEdit) -> void :
    TextNode.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, "return", "return\n", event_color.lerp(TextNode.syntax_highlighter.normal_color, 0.3))





func _get_syntax_highlighting(Highlighter: SyntaxHighlighter, dict: Dictionary, line: String) -> Dictionary:
    dict[line.find("return")] = {"color": event_color.lerp(Highlighter.normal_color, 0.3)}
    dict[line.find("return") + 6] = {"color": event_color.lerp(Highlighter.normal_color, 0.5)}
    return dict
