extends RefCounted
class_name DialogicManualAdvance





const STATE_INFO_KEY: = "manual_advance"

const ENABLED_STATE_KEY: = "enabled"

const DISABLED_UNTIL_NEXT_EVENT_STATE_KEY: = "temp_disabled"







var disabled_until_next_event: = false:
    set(enabled):
        disabled_until_next_event = enabled
        DialogicUtil.autoload().current_state_info[STATE_INFO_KEY][DISABLED_UNTIL_NEXT_EVENT_STATE_KEY] = enabled







var system_enabled: = true:
    set(enabled):
        system_enabled = enabled
        DialogicUtil.autoload().current_state_info[STATE_INFO_KEY][ENABLED_STATE_KEY] = enabled




func _init() -> void :
    if DialogicUtil.autoload().current_state_info.has(STATE_INFO_KEY):
        var state_info: = DialogicUtil.autoload().current_state_info
        var manual_advance: Dictionary = state_info[STATE_INFO_KEY]

        disabled_until_next_event = manual_advance.get(DISABLED_UNTIL_NEXT_EVENT_STATE_KEY, disabled_until_next_event)
        system_enabled = manual_advance.get(ENABLED_STATE_KEY, system_enabled)

    else:
        DialogicUtil.autoload().current_state_info[STATE_INFO_KEY] = {
            ENABLED_STATE_KEY: system_enabled, 
            DISABLED_UNTIL_NEXT_EVENT_STATE_KEY: disabled_until_next_event, 
        }





func is_enabled() -> bool:
    return system_enabled and not disabled_until_next_event
