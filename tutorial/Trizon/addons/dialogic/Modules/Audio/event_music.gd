@tool


class_name DialogicMusicEvent
extends DialogicEvent





var file_path: = "":
    set(value):
        if file_path != value:
            file_path = value
            ui_update_needed.emit()

var channel_id: int = 0

var fade_length: float = 0

var volume: float = 0

var audio_bus: = ""

var loop: = true






func _execute() -> void :
    if not dialogic.Audio.is_music_playing_resource(file_path, channel_id):
        dialogic.Audio.update_music(file_path, volume, audio_bus, fade_length, loop, channel_id)

    finish()





func _init() -> void :
    event_name = "Music"
    set_default_color("Color7")
    event_category = "Audio"
    event_sorting_index = 2


func _get_icon() -> Resource:
    return load(self.get_script().get_path().get_base_dir().path_join("icon_music.png"))





func get_shortcode() -> String:
    return "music"


func get_shortcode_parameters() -> Dictionary:
    return {

        "path": {"property": "file_path", "default": ""}, 
        "channel": {"property": "channel_id", "default": 0}, 
        "fade": {"property": "fade_length", "default": 0}, 
        "volume": {"property": "volume", "default": 0}, 
        "bus": {"property": "audio_bus", "default": "", 
                        "suggestions": get_bus_suggestions}, 
        "loop": {"property": "loop", "default": true}, 
    }






func build_event_editor() -> void :
    add_header_edit("file_path", ValueType.FILE, {
            "left_text": "Play", 
            "file_filter": "*.mp3, *.ogg, *.wav; Supported Audio Files", 
            "placeholder": "No music", 
            "editor_icon": ["AudioStreamPlayer", "EditorIcons"]})
    add_header_edit("channel_id", ValueType.FIXED_OPTIONS, {"left_text": "on:", "options": get_channel_list()})
    add_header_edit("file_path", ValueType.AUDIO_PREVIEW)
    add_body_edit("fade_length", ValueType.NUMBER, {"left_text": "Fade Time:"})
    add_body_edit("volume", ValueType.NUMBER, {"left_text": "Volume:", "mode": 2}, "!file_path.is_empty()")
    add_body_edit("audio_bus", ValueType.SINGLELINE_TEXT, {"left_text": "Audio Bus:"}, "!file_path.is_empty()")
    add_body_edit("loop", ValueType.BOOL, {"left_text": "Loop:"}, "!file_path.is_empty() and not file_path.to_lower().ends_with(\".wav\")")


func get_bus_suggestions() -> Dictionary:
    var bus_name_list: = {}
    for i in range(AudioServer.bus_count):
        bus_name_list[AudioServer.get_bus_name(i)] = {"value": AudioServer.get_bus_name(i)}
    return bus_name_list


func get_channel_list() -> Array:
    var channel_name_list: = []
    for i in ProjectSettings.get_setting("dialogic/audio/max_channels", 4):
        channel_name_list.append({
            "label": "Channel %s" % (i + 1), 
            "value": i, 
        })
    return channel_name_list
