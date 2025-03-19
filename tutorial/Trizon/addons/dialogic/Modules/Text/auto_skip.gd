class_name DialogicAutoSkip
extends RefCounted







signal toggled(is_enabled: bool)





var enabled: = false: set = _set_enabled



var disable_on_user_input: = true



var disable_on_unread_text: = false




var enable_on_visited: = false


var skip_voice: = true



var time_per_event: float = 0.1



func _init() -> void :
    time_per_event = ProjectSettings.get_setting("dialogic/text/autoskip_time_per_event", time_per_event)

    if DialogicUtil.autoload().has_subsystem("History") and not DialogicUtil.autoload().History.visited_event.is_connected(_handle_seen_event):
        DialogicUtil.autoload().History.visited_event.connect(_handle_seen_event)
        DialogicUtil.autoload().History.unvisited_event.connect(_handle_unseen_event)




func _set_enabled(is_enabled: bool) -> void :
    var previous_enabled: = enabled
    enabled = is_enabled

    if enabled != previous_enabled:
        toggled.emit(enabled)


func _handle_seen_event() -> void :


    if not enabled and enable_on_visited:
        enabled = true


func _handle_unseen_event() -> void :
    if not enabled:
        return

    if disable_on_unread_text:
        enabled = false
