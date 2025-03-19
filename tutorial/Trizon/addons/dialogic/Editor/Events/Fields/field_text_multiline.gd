@tool
extends DialogicVisualEditorField



@onready var code_completion_helper: Node = find_parent("EditorsManager").get_node("CodeCompletionHelper")





func _ready() -> void :
    self.text_changed.connect(_on_text_changed)
    self.syntax_highlighter = code_completion_helper.text_syntax_highlighter


func _load_display_info(info: Dictionary) -> void :
    pass


func _set_value(value: Variant) -> void :
    self.text = str(value)


func _autofocus() -> void :
    grab_focus()







func _on_text_changed(value: = "") -> void :
    value_changed.emit(property_name, self.text)








func _request_code_completion(force: bool):
    code_completion_helper.request_code_completion(force, self, 0)




func _filter_code_completion_candidates(candidates: Array) -> Array:
    return code_completion_helper.filter_code_completion_candidates(candidates, self)




func _confirm_code_completion(replace: bool) -> void :
    code_completion_helper.confirm_code_completion(replace, self)








func _on_symbol_lookup(symbol, line, column):
    code_completion_helper.symbol_lookup(symbol, line, column)



func _on_symbol_validate(symbol: String) -> void :
    code_completion_helper.symbol_validate(symbol, self)
