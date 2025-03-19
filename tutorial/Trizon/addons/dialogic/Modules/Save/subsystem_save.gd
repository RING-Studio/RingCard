extends DialogicSubsystem















signal saved(info: Dictionary)



const SAVE_SLOTS_DIR: = "user://dialogic/saves/"


const AUTO_SAVE_SETTINGS: = "dialogic/save/autosave"


const AUTO_SAVE_MODE_SETTINGS: = "dialogic/save/autosave_mode"


const AUTO_SAVE_TIME_SETTINGS: = "dialogic/save/autosave_delay"


enum ThumbnailMode{NONE, TAKE_AND_STORE, STORE_ONLY}
var latest_thumbnail: Image = null





enum AutoSaveMode{

    ON_TIMELINE_JUMPS = 0, 

    ON_TIMER = 1, 

    ON_TEXT_EVENT = 2
}





var autosave_enabled: = false:
    set(enabled):
        autosave_enabled = enabled

        if enabled:
            autosave_timer.start()
        else:
            autosave_timer.stop()




var autosave_mode: = AutoSaveMode.ON_TIMELINE_JUMPS




var autosave_time: = 60:
    set(timer_time):
        autosave_time = timer_time
        autosave_timer.wait_time = timer_time






func clear_game_state(_clear_flag: = DialogicGameHandler.ClearFlags.FULL_CLEAR) -> void :
    _make_sure_slot_dir_exists()



func pause() -> void :
    autosave_timer.paused = true



func resume() -> void :
    autosave_timer.paused = false












func save(slot_name: = "", is_autosave: = false, thumbnail_mode: = ThumbnailMode.TAKE_AND_STORE, slot_info: = {}) -> Error:

    if is_autosave and !autosave_enabled:
        return OK

    if slot_name.is_empty():
        slot_name = get_default_slot()

    set_latest_slot(slot_name)

    var save_error: = save_file(slot_name, "state.txt", dialogic.get_full_state())

    if save_error:
        return save_error

    if thumbnail_mode == ThumbnailMode.TAKE_AND_STORE:
        take_thumbnail()
        save_slot_thumbnail(slot_name)
    elif thumbnail_mode == ThumbnailMode.STORE_ONLY:
        save_slot_thumbnail(slot_name)

    if slot_info:
        set_slot_info(slot_name, slot_info)

    saved.emit({"slot_name": slot_name, "is_autosave": is_autosave})
    print("[Dialogic] Saved to slot \"" + slot_name + "\".")
    return OK






func load(slot_name: = "") -> Error:
    if slot_name.is_empty(): slot_name = get_default_slot()

    if !has_slot(slot_name):
        printerr("[Dialogic Error] Tried loading from invalid save slot '" + slot_name + "'.")
        return ERR_FILE_NOT_FOUND

    var set_latest_error: = set_latest_slot(slot_name)
    if set_latest_error:
        push_error("[Dialogic Error]: Failed to store latest slot to global info. Error %d '%s'" % [set_latest_error, error_string(set_latest_error)])

    var state: Dictionary = load_file(slot_name, "state.txt", {})
    dialogic.load_full_state(state)

    if state.is_empty():
        return FAILED
    else:
        return OK










func save_file(slot_name: String, file_name: String, data: Variant) -> Error:
    if slot_name.is_empty():
        slot_name = get_default_slot()

    if slot_name.is_empty():
        push_error("[Dialogic Error]: No fallback slot name set.")
        return ERR_FILE_NOT_FOUND

    if !has_slot(slot_name):
        add_empty_slot(slot_name)

    var encryption_password: = get_encryption_password()
    var file: FileAccess

    if encryption_password.is_empty():
        file = FileAccess.open(SAVE_SLOTS_DIR.path_join(slot_name).path_join(file_name), FileAccess.WRITE)
    else:
        file = FileAccess.open_encrypted_with_pass(SAVE_SLOTS_DIR.path_join(slot_name).path_join(file_name), FileAccess.WRITE, encryption_password)

    if file:
        file.store_var(data)
        return OK
    else:
        var error: = FileAccess.get_open_error()
        push_error("[Dialogic Error]: Could not save slot to file. Error: %d '%s'" % [error, error_string(error)])
        return error






func load_file(slot_name: String, file_name: String, default: Variant) -> Variant:
    if slot_name.is_empty(): slot_name = get_default_slot()

    var path: = get_slot_path(slot_name).path_join(file_name)
    if FileAccess.file_exists(path):
        var encryption_password: = get_encryption_password()
        var file: FileAccess

        if encryption_password.is_empty():
            file = FileAccess.open(path, FileAccess.READ)
        else:
            file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, encryption_password)

        if file:
            return file.get_var()
        else:
            push_error(FileAccess.get_open_error())
    return default





func set_global_info(key: String, value: Variant) -> Error:
    var global_info: = ConfigFile.new()
    var encryption_password: = get_encryption_password()

    if encryption_password.is_empty():
        var load_error: = global_info.load(SAVE_SLOTS_DIR.path_join("global_info.txt"))
        if load_error:
            printerr("[Dialogic Error]: Couldn't access global saved info file.")
            return load_error

        else:
            global_info.set_value("main", key, value)
            return global_info.save(SAVE_SLOTS_DIR.path_join("global_info.txt"))

    else:
        var load_error: = global_info.load_encrypted_pass(SAVE_SLOTS_DIR.path_join("global_info.txt"), encryption_password)
        if load_error:
            printerr("[Dialogic Error]: Couldn't access global saved info file.")
            return load_error

        else:
            global_info.set_value("main", key, value)
            return global_info.save_encrypted_pass(SAVE_SLOTS_DIR.path_join("global_info.txt"), encryption_password)




func get_global_info(key: String, default: Variant) -> Variant:
    var global_info: = ConfigFile.new()
    var encryption_password: = get_encryption_password()

    if encryption_password.is_empty():

        if global_info.load(SAVE_SLOTS_DIR.path_join("global_info.txt")) == OK:
            return global_info.get_value("main", key, default)

        printerr("[Dialogic Error]: Couldn't access global saved info file.")

    elif global_info.load_encrypted_pass(SAVE_SLOTS_DIR.path_join("global_info.txt"), encryption_password) == OK:
        return global_info.get_value("main", key, default)

    return default




func get_encryption_password() -> String:
    if OS.is_debug_build() and ProjectSettings.get_setting("dialogic/save/encryption_on_exports_only", true):
        return ""
    return ProjectSettings.get_setting("dialogic/save/encryption_password", "")








func get_slot_names() -> Array[String]:
    var save_folders: Array[String] = []

    if DirAccess.dir_exists_absolute(SAVE_SLOTS_DIR):
        var directory: = DirAccess.open(SAVE_SLOTS_DIR)
        var _list_dir: = directory.list_dir_begin()
        var file_name: = directory.get_next()

        while not file_name.is_empty():

            if directory.current_is_dir() and not file_name.begins_with("."):
                save_folders.append(file_name)

            file_name = directory.get_next()

        return save_folders

    return []



func has_slot(slot_name: String) -> bool:
    if slot_name.is_empty():
        slot_name = get_default_slot()

    return slot_name in get_slot_names()



func delete_slot(slot_name: String) -> Error:
    var path: = SAVE_SLOTS_DIR.path_join(slot_name)

    if DirAccess.dir_exists_absolute(path):
        var directory: = DirAccess.open(path)
        if not directory:
            return DirAccess.get_open_error()
        var _list_dir: = directory.list_dir_begin()
        var file_name: = directory.get_next()

        while not file_name.is_empty():
            var remove_error: = directory.remove(file_name)
            if remove_error:
                push_warning("[Dialogic Error]: Encountered error while removing '%s': %d	%s" % [path.path_join(file_name), remove_error, error_string(remove_error)])
            file_name = directory.get_next()


        return directory.remove(SAVE_SLOTS_DIR.path_join(slot_name))

    push_warning("[Dialogic Warning]: Save slot '%s' has already been deleted." % path)
    return OK



func add_empty_slot(slot_name: String) -> Error:
    if DirAccess.dir_exists_absolute(SAVE_SLOTS_DIR):
        var directory: = DirAccess.open(SAVE_SLOTS_DIR)
        if directory:
            return directory.make_dir(slot_name)
        return DirAccess.get_open_error()

    push_error("[Dialogic Error]: Path to '%s' does not exist." % SAVE_SLOTS_DIR)
    return ERR_FILE_BAD_PATH



func reset_slot(slot_name: = "") -> Error:
    if slot_name.is_empty():
        slot_name = get_default_slot()

    return save_file(slot_name, "state.txt", {})



func get_slot_path(slot_name: String) -> String:
    return SAVE_SLOTS_DIR.path_join(slot_name)



func get_default_slot() -> String:
    return ProjectSettings.get_setting("dialogic/save/default_slot", "Default")



func get_latest_slot() -> String:
    var latest_slot: = ""

    if Engine.get_main_loop().has_meta("dialogic_latest_saved_slot"):
        latest_slot = Engine.get_main_loop().get_meta("dialogic_latest_saved_slot", "")

    else:
        latest_slot = get_global_info("latest_save_slot", "")
        Engine.get_main_loop().set_meta("dialogic_latest_saved_slot", latest_slot)


    if !has_slot(latest_slot):
        return ""

    return latest_slot


func set_latest_slot(slot_name: String) -> Error:
    Engine.get_main_loop().set_meta("dialogic_latest_saved_slot", slot_name)
    return set_global_info("latest_save_slot", slot_name)


func _make_sure_slot_dir_exists() -> Error:
    if not DirAccess.dir_exists_absolute(SAVE_SLOTS_DIR):
        var make_dir_result: = DirAccess.make_dir_recursive_absolute(SAVE_SLOTS_DIR)
        if make_dir_result:
            return make_dir_result

    var global_info_path: = SAVE_SLOTS_DIR.path_join("global_info.txt")

    if not FileAccess.file_exists(global_info_path):
        var config: = ConfigFile.new()
        var password: = get_encryption_password()

        if password.is_empty():
            return config.save(global_info_path)

        else:
            return config.save_encrypted_pass(global_info_path, password)

    return OK







func set_slot_info(slot_name: String, info: Dictionary) -> Error:
    if slot_name.is_empty():
        slot_name = get_default_slot()

    return save_file(slot_name, "info.txt", info)


func get_slot_info(slot_name: = "") -> Dictionary:
    if slot_name.is_empty():
        slot_name = get_default_slot()

    return load_file(slot_name, "info.txt", {})














func take_thumbnail() -> void :
    latest_thumbnail = get_viewport().get_texture().get_image()




func save_slot_thumbnail(slot_name: String) -> Error:
    if latest_thumbnail:
        var path: = get_slot_path(slot_name).path_join("thumbnail.png")
        return latest_thumbnail.save_png(path)

    push_warning("[Dialogic Warning]: No thumbnail has been set yet.")
    return OK



func get_slot_thumbnail(slot_name: String) -> ImageTexture:
    if slot_name.is_empty():
        slot_name = get_default_slot()

    var path: = get_slot_path(slot_name).path_join("thumbnail.png")

    if FileAccess.file_exists(path):
        return ImageTexture.create_from_image(Image.load_from_file(path))

    return null







var autosave_timer: = Timer.new()


func _ready() -> void :
    autosave_timer.one_shot = true
    DialogicUtil.update_timer_process_callback(autosave_timer)
    autosave_timer.name = "AutosaveTimer"
    var _result: = autosave_timer.timeout.connect(_on_autosave_timer_timeout)
    add_child(autosave_timer)

    autosave_enabled = ProjectSettings.get_setting(AUTO_SAVE_SETTINGS, autosave_enabled)
    autosave_mode = ProjectSettings.get_setting(AUTO_SAVE_MODE_SETTINGS, autosave_mode)
    autosave_time = ProjectSettings.get_setting(AUTO_SAVE_TIME_SETTINGS, autosave_time)

    _result = dialogic.event_handled.connect(_on_dialogic_event_handled)
    _result = dialogic.timeline_started.connect(_on_start_or_end_autosave)
    _result = dialogic.timeline_ended.connect(_on_start_or_end_autosave)

    if autosave_enabled:
        autosave_timer.start(autosave_time)


func _on_autosave_timer_timeout() -> void :
    if autosave_mode == AutoSaveMode.ON_TIMER:
        perform_autosave()

    autosave_timer.start(autosave_time)


func _on_dialogic_event_handled(event: DialogicEvent) -> void :
    if event is DialogicJumpEvent:

        if autosave_mode == AutoSaveMode.ON_TIMELINE_JUMPS:
            perform_autosave()

    if event is DialogicTextEvent:

        if autosave_mode == AutoSaveMode.ON_TEXT_EVENT:
            perform_autosave()


func _on_start_or_end_autosave() -> void :
    if autosave_mode == AutoSaveMode.ON_TIMELINE_JUMPS:
        perform_autosave()




func perform_autosave() -> Error:
    return save("", true)
