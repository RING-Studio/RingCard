@tool
class_name DialogicWaitInputEvent
extends DialogicEvent



var hide_textbox: = true





func _execute() -> void :
    if hide_textbox:
        dialogic.Text.hide_textbox()
    dialogic.current_state = DialogicGameHandler.States.IDLE
    dialogic.Inputs.auto_skip.enabled = false
    await dialogic.Inputs.dialogic_action
    finish()





func _init() -> void :
    event_name = "Wait for Input"
    set_default_color("Color5")
    event_category = "Flow"
    event_sorting_index = 12






func get_shortcode() -> String:
    return "wait_input"

func get_shortcode_parameters() -> Dictionary:
    return {

        "hide_text": {"property": "hide_textbox", "default": true}, 
    }


func build_event_editor() -> void :
    add_header_label("Wait for input")
    add_body_edit("hide_textbox", ValueType.BOOL, {"left_text": "Hide text box:"})
