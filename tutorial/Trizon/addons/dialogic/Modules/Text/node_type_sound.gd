@tool
class_name DialogicNode_TypeSounds
extends AudioStreamPlayer





@export var enabled: = true
enum Modes{INTERRUPT, OVERLAP, AWAIT}

@export var mode: = Modes.INTERRUPT

@export var sounds: Array[AudioStream] = []

@export var end_sound: AudioStream

@export var play_every_character: = 1

@export_range(0, 3, 0.01) var pitch_variance: = 0.0

@export_range(0, 10, 0.01) var volume_variance: = 0.0

@export var ignore_characters: String = " .,"

var characters_since_last_sound: int = 0
var base_pitch: float = pitch_scale
var base_volume: float = volume_db
var RNG: = RandomNumberGenerator.new()

var current_overwrite_data: = {}

func _ready() -> void :

    add_to_group("dialogic_type_sounds")

    if bus == "Master":
        bus = ProjectSettings.get_setting("dialogic/audio/type_sound_bus", "Master")

    if !Engine.is_editor_hint() and get_parent() is DialogicNode_DialogText:
        get_parent().started_revealing_text.connect(_on_started_revealing_text)
        get_parent().continued_revealing_text.connect(_on_continued_revealing_text)
        get_parent().finished_revealing_text.connect(_on_finished_revealing_text)


func _on_started_revealing_text() -> void :
    if !enabled or (get_parent() is DialogicNode_DialogText and !get_parent().enabled):
        return
    characters_since_last_sound = current_overwrite_data.get("skip_characters", play_every_character - 1) + 1


func _on_continued_revealing_text(new_character: String) -> void :
    if !enabled or (get_parent() is DialogicNode_DialogText and !get_parent().enabled):
        return


    if !Engine.is_editor_hint() and DialogicUtil.autoload().Inputs.auto_skip.enabled:
        return


    if !Engine.is_editor_hint() and get_parent() is DialogicNode_DialogText:
        if DialogicUtil.autoload().has_subsystem("Voice") and DialogicUtil.autoload().Voice.is_running():
            return


    if playing and current_overwrite_data.get("mode", mode) == Modes.AWAIT:
        return


    if current_overwrite_data.get("sounds", sounds).size() == 0:
        return


    if new_character in ignore_characters:
        return

    characters_since_last_sound += 1
    if characters_since_last_sound < current_overwrite_data.get("skip_characters", play_every_character - 1) + 1:
        return

    characters_since_last_sound = 0

    var audio_player: AudioStreamPlayer = self
    if current_overwrite_data.get("mode", mode) == Modes.OVERLAP:
        audio_player = AudioStreamPlayer.new()
        audio_player.bus = bus
        add_child(audio_player)
    elif current_overwrite_data.get("mode", mode) == Modes.INTERRUPT:
        stop()


    audio_player.stream = current_overwrite_data.get("sounds", sounds)[RNG.randi_range(0, current_overwrite_data.get("sounds", sounds).size() - 1)]


    audio_player.pitch_scale = max(0, current_overwrite_data.get("pitch_base", base_pitch) + current_overwrite_data.get("pitch_variance", pitch_variance) * RNG.randf_range(-1.0, 1.0))
    audio_player.volume_db = current_overwrite_data.get("volume_base", base_volume) + current_overwrite_data.get("volume_variance", volume_variance) * RNG.randf_range(-1.0, 1.0)


    audio_player.play(0)

    if current_overwrite_data.get("mode", mode) == Modes.OVERLAP:
        audio_player.finished.connect(audio_player.queue_free)


func _on_finished_revealing_text() -> void :

    if !Engine.is_editor_hint() and DialogicUtil.autoload().Inputs.auto_skip.enabled:
        return

    if end_sound != null:
        stream = end_sound
        play()


func load_overwrite(dictionary: Dictionary) -> void :
    current_overwrite_data = dictionary
    if dictionary.has("sound_path"):
        current_overwrite_data["sounds"] = DialogicNode_TypeSounds.load_sounds_from_path(dictionary.sound_path)


static func load_sounds_from_path(path: String) -> Array[AudioStream]:
    if path.get_extension().to_lower() in ["mp3", "wav", "ogg"] and load(path) is AudioStream:
        return [load(path)]
    var _sounds: Array[AudioStream] = []
    for file in DialogicUtil.listdir(path, true, false, true, true):
        if !file.ends_with(".import"):
            continue
        if file.trim_suffix(".import").get_extension().to_lower() in ["mp3", "wav", "ogg"] and ResourceLoader.load(file.trim_suffix(".import")) is AudioStream:
            _sounds.append(ResourceLoader.load(file.trim_suffix(".import")))
    return _sounds




func _get_configuration_warnings() -> PackedStringArray:
    if not get_parent() is DialogicNode_DialogText:
        return ["This should be the child of a DialogText node!"]
    return []
