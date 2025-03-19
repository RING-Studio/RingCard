extends DialogicSubsystem

















signal music_started(info: Dictionary)











signal sound_started(info: Dictionary)


var max_channels: int:
    set(value):
        if max_channels != value:
            max_channels = value
            ProjectSettings.set_setting("dialogic/audio/max_channels", value)
            ProjectSettings.save()
            current_music_player.resize(value)
    get:
        return ProjectSettings.get_setting("dialogic/audio/max_channels", 4)




var base_music_player: = AudioStreamPlayer.new()

var current_music_player: Array[AudioStreamPlayer] = []



var base_sound_player: = AudioStreamPlayer.new()








func clear_game_state(_clear_flag: = DialogicGameHandler.ClearFlags.FULL_CLEAR) -> void :
    for idx in max_channels:
        update_music("", 0.0, "", 0.0, true, idx)
    stop_all_sounds()



func load_game_state(load_flag: = LoadFlags.FULL_LOAD) -> void :
    if load_flag == LoadFlags.ONLY_DNODES:
        return
    var info: Dictionary = dialogic.current_state_info.get("music", {})
    if not info.is_empty() and info.has("path"):
        update_music(info.path, info.volume, info.audio_bus, 0, info.loop, 0)
    else:
        for channel_id in info.keys():
            if info[channel_id].is_empty() or info[channel_id].path.is_empty():
                update_music("", 0.0, "", 0.0, true, channel_id)
            else:
                update_music(info[channel_id].path, info[channel_id].volume, info[channel_id].audio_bus, 0, info[channel_id].loop, channel_id)



func pause() -> void :
    for child in get_children():
        child.stream_paused = true



func resume() -> void :
    for child in get_children():
        child.stream_paused = false


func _on_dialogic_timeline_ended() -> void :
    if not dialogic.Styles.get_layout_node():
        clear_game_state()
    pass






func _ready() -> void :
    dialogic.timeline_ended.connect(_on_dialogic_timeline_ended)

    base_music_player.name = "Music"
    add_child(base_music_player)

    base_sound_player.name = "Sound"
    add_child(base_sound_player)

    current_music_player.resize(max_channels)



func update_music(path: = "", volume: = 0.0, audio_bus: = "", fade_time: = 0.0, loop: = true, channel_id: = 0) -> void :

    if channel_id > max_channels:
        printerr("	Channel ID (%s) higher than Max Music Channels (%s)" % [channel_id, max_channels])
        dialogic.print_debug_moment()
        return

    if not dialogic.current_state_info.has("music"):
        dialogic.current_state_info["music"] = {}

    dialogic.current_state_info["music"][channel_id] = {"path": path, "volume": volume, "audio_bus": audio_bus, "loop": loop, "channel": channel_id}
    music_started.emit(dialogic.current_state_info["music"][channel_id])

    var fader: Tween = null
    if is_instance_valid(current_music_player[channel_id]) and current_music_player[channel_id].playing or !path.is_empty():
        fader = create_tween()

    var prev_node: Node = null
    if is_instance_valid(current_music_player[channel_id]) and current_music_player[channel_id].playing:
        prev_node = current_music_player[channel_id]
        fader.tween_method(interpolate_volume_linearly.bind(prev_node), db_to_linear(prev_node.volume_db), 0.0, fade_time)

    if path:
        current_music_player[channel_id] = base_music_player.duplicate()
        add_child(current_music_player[channel_id])
        current_music_player[channel_id].stream = load(path)
        current_music_player[channel_id].volume_db = volume
        if audio_bus:
            current_music_player[channel_id].bus = audio_bus
        if not current_music_player[channel_id].stream is AudioStreamWAV:
            if "loop" in current_music_player[channel_id].stream:
                current_music_player[channel_id].stream.loop = loop
            elif "loop_mode" in current_music_player[channel_id].stream:
                if loop:
                    current_music_player[channel_id].stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
                else:
                    current_music_player[channel_id].stream.loop_mode = AudioStreamWAV.LOOP_DISABLED

        current_music_player[channel_id].play(0)
        fader.parallel().tween_method(interpolate_volume_linearly.bind(current_music_player[channel_id]), 0.0, db_to_linear(volume), fade_time)

    if prev_node:
        fader.tween_callback(prev_node.queue_free)



func has_music(channel_id: = 0) -> bool:
    return !dialogic.current_state_info.get("music", {}).get(channel_id, {}).get("path", "").is_empty()



func play_sound(path: String, volume: = 0.0, audio_bus: = "", loop: = false) -> void :
    if base_sound_player != null and !path.is_empty():
        sound_started.emit({"path": path, "volume": volume, "audio_bus": audio_bus, "loop": loop})

        var new_sound_node: = base_sound_player.duplicate()
        new_sound_node.name += "Sound"
        new_sound_node.stream = load(path)

        if "loop" in new_sound_node.stream:
            new_sound_node.stream.loop = loop
        elif "loop_mode" in new_sound_node.stream:
            if loop:
                new_sound_node.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
            else:
                new_sound_node.stream.loop_mode = AudioStreamWAV.LOOP_DISABLED

        new_sound_node.volume_db = volume
        if audio_bus:
            new_sound_node.bus = audio_bus

        add_child(new_sound_node)
        new_sound_node.play()
        new_sound_node.finished.connect(new_sound_node.queue_free)



func stop_all_sounds() -> void :
    for node in get_children():
        if node == base_sound_player:
            continue
        if "Sound" in node.name:
            node.queue_free()




func interpolate_volume_linearly(value: float, node: Node) -> void :
    node.volume_db = linear_to_db(value)




func is_music_playing_resource(resource_path: String, channel_id: = 0) -> bool:
    var is_playing_resource: bool = (current_music_player.size() > channel_id
        and is_instance_valid(current_music_player[channel_id])
        and current_music_player[channel_id].is_playing()
        and current_music_player[channel_id].stream.resource_path == resource_path)

    return is_playing_resource
