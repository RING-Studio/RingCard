extends DialogicSubsystem



signal switched_timeline(info: Dictionary)
signal jumped_to_label(info: Dictionary)
signal returned_from_jump(info: Dictionary)
signal passed_label(info: Dictionary)





func clear_game_state(_clear_flag: = DialogicGameHandler.ClearFlags.FULL_CLEAR) -> void :
    dialogic.current_state_info["jump_stack"] = []
    dialogic.current_state_info.erase("last_label")


func load_game_state(_load_flag: = LoadFlags.FULL_LOAD) -> void :
    if not "jump_stack" in dialogic.current_state_info:
        dialogic.current_state_info["jump_stack"] = []







func jump_to_label(label: String) -> void :
    if label.is_empty():
        dialogic.current_event_idx = 0
        jumped_to_label.emit({"timeline": dialogic.current_timeline, "label": "TOP"})
        return

    var idx: int = -1
    while true:
        idx += 1
        var event: Variant = dialogic.current_timeline.get_event(idx)
        if not event:
            idx = dialogic.current_event_idx
            break
        if event is DialogicLabelEvent and event.name == label:
            break
    dialogic.current_event_idx = idx - 1
    jumped_to_label.emit({"timeline": dialogic.current_timeline, "label": label})


func push_to_jump_stack() -> void :
    dialogic.current_state_info["jump_stack"].push_back({"timeline": dialogic.current_timeline, "index": dialogic.current_event_idx, "label": dialogic.current_timeline_events[dialogic.current_event_idx].label_name})


func resume_from_last_jump() -> void :
    var sub_timeline: DialogicTimeline = dialogic.current_timeline
    var stack_info: Dictionary = dialogic.current_state_info["jump_stack"].pop_back()
    dialogic.start_timeline(stack_info.timeline, stack_info.index + 1)
    returned_from_jump.emit({"sub_timeline": sub_timeline, "label": stack_info.label})


func is_jump_stack_empty() -> bool:
    return len(dialogic.current_state_info["jump_stack"]) < 1







func _ready() -> void :
    passed_label.connect(_on_passed_label)


func _on_passed_label(info: Dictionary) -> void :
    dialogic.current_state_info["last_label"] = info



func get_last_label_identifier() -> String:
    if not dialogic.current_state_info.has("last_label"):
        return ""

    return dialogic.current_state_info["last_label"].identifier



func get_last_label_name() -> String:
    if not dialogic.current_state_info.has("last_label"):
        return ""

    return dialogic.current_state_info["last_label"].display_name
