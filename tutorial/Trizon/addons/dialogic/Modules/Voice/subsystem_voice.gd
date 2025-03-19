extends DialogicSubsystem












signal voiceline_started(info: Dictionary)









signal voiceline_finished(info: Dictionary)









signal voiceline_stopped(info: Dictionary)



var current_audio_file: String


var voice_player: = AudioStreamPlayer.new()





func pause() -> void :
    voice_player.stream_paused = true



func resume() -> void :
    voice_player.stream_paused = false







func _ready() -> void :
    add_child(voice_player)
    voice_player.finished.connect(_on_voice_finished)




func is_voiced(index: int) -> bool:
    if index > 0 and dialogic.current_timeline_events[index] is DialogicTextEvent:
        if dialogic.current_timeline_events[index - 1] is DialogicVoiceEvent:
            return true

    return false




func play_voice() -> void :
    voice_player.play()
    voiceline_started.emit({"file": current_audio_file})





func set_file(path: String) -> void :
    if current_audio_file == path:
        return

    current_audio_file = path
    var audio: AudioStream = load(path)
    voice_player.stream = audio



func set_volume(value: float) -> void :
    voice_player.volume_db = value



func set_bus(bus_name: String) -> void :
    voice_player.bus = bus_name



func stop_audio() -> void :
    if voice_player.playing:
        voiceline_stopped.emit({"file": current_audio_file, "remaining_time": get_remaining_time()})

    voice_player.stop()




func _on_voice_finished() -> void :
    voiceline_finished.emit({"file": current_audio_file, "remaining_time": get_remaining_time()})





func get_remaining_time() -> float:
    if not voice_player or not voice_player.playing:
        return 0.0

    var stream_length: = voice_player.stream.get_length()
    var playback_position: = voice_player.get_playback_position()
    var remaining_seconds: = stream_length - playback_position

    return remaining_seconds



func is_running() -> bool:
    return get_remaining_time() > 0.0
