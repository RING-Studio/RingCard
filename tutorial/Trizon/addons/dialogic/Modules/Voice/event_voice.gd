@tool
class_name DialogicVoiceEvent
extends DialogicEvent







var file_path: = "":
    set(value):
        if file_path != value:
            file_path = value
            ui_update_needed.emit()

var volume: float = 0

var audio_bus: = "Master"






func _execute() -> void :


    if (dialogic.Inputs.auto_skip.enabled
    and dialogic.Inputs.auto_skip.skip_voice):
        finish()
        return

    dialogic.Voice.set_file(file_path)
    dialogic.Voice.set_volume(volume)
    dialogic.Voice.set_bus(audio_bus)
    finish()







func _init() -> void :
    event_name = "Voice"
    set_default_color("Color7")
    event_category = "Audio"
    event_sorting_index = 5






func get_shortcode() -> String:
    return "voice"


func get_shortcode_parameters() -> Dictionary:
    return {

        "path": {"property": "file_path", "default": ""}, 
        "volume": {"property": "volume", "default": 0}, 
        "bus": {"property": "audio_bus", "default": "Master"}
    }






func build_event_editor() -> void :
    add_header_edit("file_path", ValueType.FILE, {
            "left_text": "Set", 
            "right_text": "as the next voice audio", 
            "file_filter": "*.mp3, *.ogg, *.wav", 
            "placeholder": "Select file", 
            "editor_icon": ["AudioStreamPlayer", "EditorIcons"]})
    add_header_edit("file_path", ValueType.AUDIO_PREVIEW)
    add_body_edit("volume", ValueType.NUMBER, {"left_text": "Volume:", "mode": 2}, "!file_path.is_empty()")
    add_body_edit("audio_bus", ValueType.SINGLELINE_TEXT, {"left_text": "Audio Bus:"}, "!file_path.is_empty()")
