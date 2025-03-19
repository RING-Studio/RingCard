class_name DialogicGameHandler
extends Node










enum States{
    IDLE, 
    REVEALING_TEXT, 
    ANIMATING, 
    AWAITING_CHOICE, 
    WAITING
    }


enum ClearFlags{
    FULL_CLEAR = 0, 
    KEEP_VARIABLES = 1, 
    TIMELINE_INFO_ONLY = 2
    }


var current_timeline: DialogicTimeline = null

var current_timeline_events: Array = []


var current_event_idx: int = 0


var current_state_info: Dictionary = {}


var current_state: = States.IDLE:
    get:
        return current_state

    set(new_state):
        current_state = new_state
        state_changed.emit(new_state)


signal state_changed(new_state: States)


var paused: = false:
    set(value):
        paused = value

        if paused:

            for subsystem in get_children():

                if subsystem is DialogicSubsystem:
                    (subsystem as DialogicSubsystem).pause()

            dialogic_paused.emit()

        else:
            for subsystem in get_children():

                if subsystem is DialogicSubsystem:
                    (subsystem as DialogicSubsystem).resume()

            dialogic_resumed.emit()


signal dialogic_paused

signal dialogic_resumed




signal timeline_ended


signal timeline_started


signal event_handled(resource: DialogicEvent)


signal signal_event(argument: Variant)

signal text_signal(argument: String)





var Audio: = preload("res://addons/dialogic/Modules/Audio/subsystem_audio.gd").new():
    get: return get_subsystem("Audio")

var Backgrounds: = preload("res://addons/dialogic/Modules/Background/subsystem_backgrounds.gd").new():
    get: return get_subsystem("Backgrounds")

var Portraits: = preload("res://addons/dialogic/Modules/Character/subsystem_portraits.gd").new():
    get: return get_subsystem("Portraits")

var PortraitContainers: = preload("res://addons/dialogic/Modules/Character/subsystem_containers.gd").new():
    get: return get_subsystem("PortraitContainers")

var Choices: = preload("res://addons/dialogic/Modules/Choice/subsystem_choices.gd").new():
    get: return get_subsystem("Choices")

var Expressions: = preload("res://addons/dialogic/Modules/Core/subsystem_expression.gd").new():
    get: return get_subsystem("Expressions")

var Animations: = preload("res://addons/dialogic/Modules/Core/subsystem_animation.gd").new():
    get: return get_subsystem("Animations")

var Inputs: = preload("res://addons/dialogic/Modules/Core/subsystem_input.gd").new():
    get: return get_subsystem("Inputs")

var Glossary: = preload("res://addons/dialogic/Modules/Glossary/subsystem_glossary.gd").new():
    get: return get_subsystem("Glossary")

var History: = preload("res://addons/dialogic/Modules/History/subsystem_history.gd").new():
    get: return get_subsystem("History")

var Jump: = preload("res://addons/dialogic/Modules/Jump/subsystem_jump.gd").new():
    get: return get_subsystem("Jump")

var Save: = preload("res://addons/dialogic/Modules/Save/subsystem_save.gd").new():
    get: return get_subsystem("Save")

var Settings: = preload("res://addons/dialogic/Modules/Settings/subsystem_settings.gd").new():
    get: return get_subsystem("Settings")

var Styles: = preload("res://addons/dialogic/Modules/Style/subsystem_styles.gd").new():
    get: return get_subsystem("Styles")

var Text: = preload("res://addons/dialogic/Modules/Text/subsystem_text.gd").new():
    get: return get_subsystem("Text")

var TextInput: = preload("res://addons/dialogic/Modules/TextInput/subsystem_text_input.gd").new():
    get: return get_subsystem("TextInput")

var VAR: = preload("res://addons/dialogic/Modules/Variable/subsystem_variables.gd").new():
    get: return get_subsystem("VAR")

var Voice: = preload("res://addons/dialogic/Modules/Voice/subsystem_voice.gd").new():
    get: return get_subsystem("Voice")





func _ready() -> void :
    _collect_subsystems()

    clear()








func start(timeline: Variant, label: Variant = "") -> Node:

    if not has_subsystem("Styles"):
        printerr("[Dialogic] You called Dialogic.start() but the Styles subsystem is missing!")
        clear(ClearFlags.KEEP_VARIABLES)
        start_timeline(timeline, label)
        return null


    var scene: Node = null
    if !self.Styles.has_active_layout_node():
        scene = self.Styles.load_style()
    else:
        scene = self.Styles.get_layout_node()
        scene.show()

    if not scene.is_node_ready():
        scene.ready.connect(clear.bind(ClearFlags.KEEP_VARIABLES))
        scene.ready.connect(start_timeline.bind(timeline, label))
    else:
        start_timeline(timeline, label)

    return scene





func start_timeline(timeline: Variant, label_or_idx: Variant = "") -> void :

    if typeof(timeline) == TYPE_STRING:

        if (timeline as String).contains("res://"):
            timeline = load((timeline as String))
        else:
            timeline = DialogicResourceUtil.get_timeline_resource((timeline as String))

    if timeline == null:
        printerr("[Dialogic] There was an error loading this timeline. Check the filename, and the timeline for errors")
        return

    (timeline as DialogicTimeline).process()

    current_timeline = timeline
    current_timeline_events = current_timeline.events
    for event in current_timeline_events:
        event.dialogic = self
    current_event_idx = -1

    if typeof(label_or_idx) == TYPE_STRING:
        if label_or_idx:
            if has_subsystem("Jump"):
                Jump.jump_to_label((label_or_idx as String))
    elif typeof(label_or_idx) == TYPE_INT:
        if label_or_idx > -1:
            current_event_idx = label_or_idx - 1

    timeline_started.emit()
    handle_next_event()




func preload_timeline(timeline_resource: Variant) -> Variant:

    if typeof(timeline_resource) == TYPE_STRING:
        timeline_resource = load((timeline_resource as String))
        if timeline_resource == null:
            printerr("[Dialogic] There was an error preloading this timeline. Check the filename, and the timeline for errors")
            return null

    (timeline_resource as DialogicTimeline).process()

    return timeline_resource



func end_timeline() -> void :
    await clear(ClearFlags.TIMELINE_INFO_ONLY)
    _on_timeline_ended()
    timeline_ended.emit()



func handle_next_event(_ignore_argument: Variant = "") -> void :
    handle_event(current_event_idx + 1)




func handle_event(event_index: int) -> void :
    if not current_timeline:
        return

    _cleanup_previous_event()

    if paused:
        await dialogic_resumed

    if event_index >= len(current_timeline_events):
        end_timeline()
        return



    if current_timeline_events[event_index].event_node_ready == false:
        current_timeline_events[event_index]._load_from_string(current_timeline_events[event_index].event_node_as_text)

    current_event_idx = event_index

    if not current_timeline_events[event_index].event_finished.is_connected(handle_next_event):
        current_timeline_events[event_index].event_finished.connect(handle_next_event)

    set_meta("previous_event", current_timeline_events[event_index])

    current_timeline_events[event_index].execute(self)
    event_handled.emit(current_timeline_events[event_index])






func clear(clear_flags: = ClearFlags.FULL_CLEAR) -> void :
    _cleanup_previous_event()

    if !clear_flags & ClearFlags.TIMELINE_INFO_ONLY:
        for subsystem in get_children():
            if subsystem is DialogicSubsystem:
                (subsystem as DialogicSubsystem).clear_game_state(clear_flags)

    var timeline: = current_timeline

    current_timeline = null
    current_event_idx = -1
    current_timeline_events = []
    current_state = States.IDLE


    if timeline:
        await timeline.clean()



func _cleanup_previous_event():
    if has_meta("previous_event") and get_meta("previous_event") is DialogicEvent:
        var event: = get_meta("previous_event") as DialogicEvent
        if event.event_finished.is_connected(handle_next_event):
            event.event_finished.disconnect(handle_next_event)
        event._clear_state()
        remove_meta("previous_event")










func get_full_state() -> Dictionary:
    if current_timeline:
        current_state_info["current_event_idx"] = current_event_idx
        current_state_info["current_timeline"] = current_timeline.resource_path
    else:
        current_state_info["current_event_idx"] = -1
        current_state_info["current_timeline"] = null

    for subsystem in get_children():
        (subsystem as DialogicSubsystem).save_game_state()

    return current_state_info.duplicate(true)





func load_full_state(state_info: Dictionary) -> void :
    clear()
    current_state_info = state_info

    var scene: Node = null
    if has_subsystem("Styles"):
        get_subsystem("Styles").load_game_state()
        scene = self.Styles.get_layout_node()

    var load_subsystems: = func() -> void :
        for subsystem in get_children():
            if subsystem.name == "Styles":
                continue
            (subsystem as DialogicSubsystem).load_game_state()

    if null != scene and not scene.is_node_ready():
        scene.ready.connect(load_subsystems)
    else:
        await get_tree().process_frame
        load_subsystems.call()

    if current_state_info.get("current_timeline", null):
        start_timeline(current_state_info.current_timeline, current_state_info.get("current_event_idx", 0))
    else:
        end_timeline.call_deferred()






func _collect_subsystems() -> void :
    var subsystem_nodes: = [] as Array[DialogicSubsystem]
    for indexer in DialogicUtil.get_indexers():
        for subsystem in indexer._get_subsystems():
            var subsystem_node: = add_subsystem(str(subsystem.name), str(subsystem.script))
            subsystem_nodes.push_back(subsystem_node)

    for subsystem in subsystem_nodes:
        subsystem.post_install()



func has_subsystem(subsystem_name: String) -> bool:
    return has_node(subsystem_name)



func get_subsystem(subsystem_name: String) -> DialogicSubsystem:
    return get_node(subsystem_name)



func add_subsystem(subsystem_name: String, script_path: String) -> DialogicSubsystem:
    var node: Node = Node.new()
    node.name = subsystem_name
    node.set_script(load(script_path))
    node = node as DialogicSubsystem
    node.dialogic = self
    add_child(node)
    return node









func _on_timeline_ended() -> void :
    if self.Styles.has_active_layout_node() and self.Styles.get_layout_node().is_inside_tree():
        match ProjectSettings.get_setting("dialogic/layout/end_behaviour", 0):
            0:
                self.Styles.get_layout_node().get_parent().remove_child(self.Styles.get_layout_node())
                self.Styles.get_layout_node().queue_free()
            1:
                @warning_ignore("unsafe_method_access")
                self.Styles.get_layout_node().hide()


func print_debug_moment() -> void :
    if not current_timeline:
        return

    printerr("	At event ", current_event_idx + 1, " (", current_timeline_events[current_event_idx].event_name, " Event) in timeline \"", DialogicResourceUtil.get_unique_identifier(current_timeline.resource_path), "\" (", current_timeline.resource_path, ").")
    print("\n")
