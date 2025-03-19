class_name DialogicAutoAdvance
extends RefCounted














signal autoadvance
signal toggled(enabled: bool)

var autoadvance_timer: = Timer.new()

var fixed_delay: float = 1.0
var delay_modifier: float = 1.0

var per_word_delay: float = 0.0
var per_character_delay: float = 0.1

var ignored_characters_enabled: = false
var ignored_characters: = {}

var await_playing_voice: = true

var override_delay_for_current_event: float = -1.0



var _last_enable_state: = false








var enabled_until_next_event: = false:
    set(enabled):
        enabled_until_next_event = enabled
        _try_emit_toggled()






var enabled_forced: = false:
    set(enabled):
        enabled_forced = enabled
        _try_emit_toggled()






var enabled_until_user_input: = false:
    set(enabled):
        enabled_until_user_input = enabled
        _try_emit_toggled()


func _init() -> void :
    DialogicUtil.autoload().Inputs.add_child(autoadvance_timer)
    autoadvance_timer.one_shot = true
    autoadvance_timer.timeout.connect(_on_autoadvance_timer_timeout)
    toggled.connect(_on_toggled)

    enabled_forced = ProjectSettings.get_setting("dialogic/text/autoadvance_enabled", false)
    fixed_delay = ProjectSettings.get_setting("dialogic/text/autoadvance_fixed_delay", 1)
    per_word_delay = ProjectSettings.get_setting("dialogic/text/autoadvance_per_word_delay", 0)
    per_character_delay = ProjectSettings.get_setting("dialogic/text/autoadvance_per_character_delay", 0.1)
    ignored_characters_enabled = ProjectSettings.get_setting("dialogic/text/autoadvance_ignored_characters_enabled", true)
    ignored_characters = ProjectSettings.get_setting("dialogic/text/autoadvance_ignored_characters", {})



func start() -> void :
    if not is_enabled():
        return

    var parsed_text: String = DialogicUtil.autoload().current_state_info["text_parsed"]
    var delay: = _calculate_autoadvance_delay(parsed_text)

    await DialogicUtil.autoload().get_tree().process_frame
    if delay == 0:
        _on_autoadvance_timer_timeout()
    else:
        autoadvance_timer.start(delay)












func _calculate_autoadvance_delay(text: String = "") -> float:
    var delay: = 0.0


    if override_delay_for_current_event >= 0:
        delay = override_delay_for_current_event
    else:

        delay = _calculate_per_word_delay(text) + _calculate_per_character_delay(text)

        delay *= delay_modifier

        delay += fixed_delay

        delay = max(0, delay)


    if await_playing_voice and DialogicUtil.autoload().has_subsystem("Voice") and DialogicUtil.autoload().Voice.is_running():
        delay = max(delay, DialogicUtil.autoload().Voice.get_remaining_time())

    return delay




func _calculate_per_word_delay(text: String) -> float:
    return float(text.split(" ", false).size() * per_word_delay)



func _calculate_per_character_delay(text: String) -> float:
    var calculated_delay: float = 0

    if per_character_delay > 0:

        if ignored_characters_enabled:
            for character in text:
                if character in ignored_characters:
                    continue
                calculated_delay += per_character_delay


        else:
            calculated_delay = text.length() * per_character_delay

    return calculated_delay


func _on_autoadvance_timer_timeout() -> void :
    autoadvance.emit()
    autoadvance_timer.stop()



func _on_toggled(enabled: bool) -> void :


    if (enabled and !is_advancing()
    and DialogicUtil.autoload().current_state == DialogicGameHandler.States.IDLE
    and not DialogicUtil.autoload().current_state_info.get("text", "").is_empty()):
        start()



    elif !enabled and is_advancing():
        DialogicUtil.autoload().Inputs.stop_timers()



func is_advancing() -> bool:
    return !autoadvance_timer.is_stopped()


func get_time_left() -> float:
    return autoadvance_timer.time_left


func get_time() -> float:
    return autoadvance_timer.wait_time









func is_enabled() -> bool:
    return (enabled_until_next_event
        or enabled_until_user_input
        or enabled_forced)




func _try_emit_toggled() -> void :
    var old_autoadvance_state: = _last_enable_state
    _last_enable_state = is_enabled()

    if old_autoadvance_state != _last_enable_state:
        toggled.emit(_last_enable_state)



func _update_autoadvance_delay_modifier(delay_modifier_value: float) -> void :
    delay_modifier = delay_modifier_value





func get_progress() -> float:
    if !is_advancing():
        return -1

    var total_time: float = get_time()
    var time_left: float = get_time_left()
    var progress: float = (total_time - time_left) / total_time

    return progress
