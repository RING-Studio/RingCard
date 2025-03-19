@tool
class_name DialogicNode_PortraitContainer
extends Control



enum PositionModes{
    POSITION, 
    SPEAKER, 
    }

@export var mode: = PositionModes.POSITION

@export_subgroup("Mode: Position")

@export var container_ids: PackedStringArray = ["1"]


@export_subgroup("Mode: Speaker")


@export var portrait_prefix: = ""

@export_subgroup("Portrait Placement")
enum SizeModes{
    KEEP, 
    FIT_STRETCH, 
    FIT_IGNORE_SCALE, 
    FIT_SCALE_HEIGHT
    }

@export var size_mode: SizeModes = SizeModes.FIT_SCALE_HEIGHT:
    set(mode):
        size_mode = mode
        _update_debug_portrait_transform()


@export var mirrored: = false:
    set(mirror):
        mirrored = mirror
        _update_debug_portrait_scene()


@export_group("Origin", "origin")
enum OriginAnchors{TOP_LEFT, TOP_CENTER, TOP_RIGHT, LEFT_MIDDLE, CENTER, RIGHT_MIDDLE, BOTTOM_LEFT, BOTTOM_CENTER, BOTTOM_RIGHT}

@export var origin_anchor: OriginAnchors = OriginAnchors.BOTTOM_CENTER:
    set(anchor):
        origin_anchor = anchor
        _update_debug_origin()


@export var origin_offset: = Vector2():
    set(offset):
        origin_offset = offset
        _update_debug_origin()

enum PivotModes{AT_ORIGIN, PERCENTAGE, PIXELS}


@export var pivot_mode: PivotModes = PivotModes.AT_ORIGIN

@export var pivot_value: = Vector2()

@export_group("Debug", "debug")

@export var debug_character: DialogicCharacter = null:
    set(character):
        debug_character = character
        _update_debug_portrait_scene()
@export var debug_character_portrait: = "":
    set(portrait):
        debug_character_portrait = portrait
        _update_debug_portrait_scene()

var debug_character_holder_node: Node2D = null
var debug_character_scene_node: Node = null
var debug_origin: Sprite2D = null
var default_portrait_scene: String = DialogicUtil.get_module_path("Character").path_join("default_portrait.tscn")

var default_debug_character: = load(DialogicUtil.get_module_path("Character").path_join("preview_character.tres"))

var ignore_resize: = false


func _ready() -> void :
    match mode:
        PositionModes.POSITION:
            add_to_group("dialogic_portrait_con_position")
        PositionModes.SPEAKER:
            add_to_group("dialogic_portrait_con_speaker")

    if Engine.is_editor_hint():
        resized.connect(_update_debug_origin)

        if !ProjectSettings.get_setting("dialogic/portraits/default_portrait", "").is_empty():
            default_portrait_scene = ProjectSettings.get_setting("dialogic/portraits/default_portrait", "")

        debug_origin = Sprite2D.new()
        add_child(debug_origin)
        debug_origin.texture = load("res://addons/dialogic/Editor/Images/Dropdown/default.svg")

        _update_debug_origin()
        _update_debug_portrait_scene()
    else:
        resized.connect(update_portrait_transforms)






func update_portrait_transforms() -> void :
    if ignore_resize:
        return

    match pivot_mode:
        PivotModes.AT_ORIGIN:
            pivot_offset = _get_origin_position()
        PivotModes.PERCENTAGE:
            pivot_offset = size * pivot_value
        PivotModes.PIXELS:
            pivot_offset = pivot_value

    for child in get_children():
        DialogicUtil.autoload().Portraits._update_character_transform(child)



func get_local_portrait_transform(portrait_rect: Rect2, character_scale: = 1.0) -> Rect2:
    var transform: = Rect2()
    transform.position = _get_origin_position()


    if size_mode == SizeModes.KEEP:
        transform.size = Vector2(1, 1) * character_scale


    elif size_mode == SizeModes.FIT_IGNORE_SCALE:
        if size.x / size.y < portrait_rect.size.x / portrait_rect.size.y:
            transform.size = Vector2(1, 1) * size.x / portrait_rect.size.x
        else:
            transform.size = Vector2(1, 1) * size.y / portrait_rect.size.y


    elif size_mode == SizeModes.FIT_STRETCH:
        transform.size = size / portrait_rect.size


    elif size_mode == SizeModes.FIT_SCALE_HEIGHT:
        transform.size = Vector2(1, 1) * size.y / portrait_rect.size.y * character_scale

    return transform



func _get_origin_position(rect_size = null) -> Vector2:
    if rect_size == null:
        rect_size = size
    return rect_size * Vector2(origin_anchor % 3 / 2.0, floor(origin_anchor / 3.0) / 2.0) + origin_offset


func is_container(id: Variant) -> bool:
    return str(id) in container_ids














func _update_debug_portrait_scene() -> void :
    if !Engine.is_editor_hint():
        return
    if is_instance_valid(debug_character_holder_node):
        for child in get_children():
            if child != debug_origin:
                child.free()


    var character: = _get_debug_character()
    if not character is DialogicCharacter or character.portraits.is_empty():
        return


    var debug_portrait: = debug_character_portrait
    if debug_portrait.is_empty():
        debug_portrait = character.default_portrait
    if mode == PositionModes.SPEAKER and !portrait_prefix.is_empty():
        if portrait_prefix + debug_portrait in character.portraits:
            debug_portrait = portrait_prefix + debug_portrait
    if not debug_portrait in character.portraits:
        debug_portrait = character.default_portrait

    var portrait_info: Dictionary = character.get_portrait_info(debug_portrait)


    var portrait_scene_path: String = portrait_info.get("scene", default_portrait_scene)
    if portrait_scene_path.is_empty():
        portrait_scene_path = default_portrait_scene

    debug_character_scene_node = load(portrait_scene_path).instantiate()

    if !is_instance_valid(debug_character_scene_node):
        return


    DialogicUtil.apply_scene_export_overrides(debug_character_scene_node, character.portraits[debug_portrait].get("export_overrides", {}))
    debug_character_scene_node._update_portrait(character, debug_portrait)


    if !is_instance_valid(debug_character_holder_node):
        debug_character_holder_node = Node2D.new()
        add_child(debug_character_holder_node)


    debug_character_holder_node.add_child(debug_character_scene_node)
    move_child(debug_character_holder_node, 0)
    debug_character_scene_node._set_mirror(character.mirror != mirrored != portrait_info.get("mirror", false))

    _update_debug_portrait_transform()




func _update_debug_portrait_transform() -> void :
    if !Engine.is_editor_hint() or !is_instance_valid(debug_character_scene_node) or !is_instance_valid(debug_origin):
        return
    var character: = _get_debug_character()
    var portrait_info: = character.get_portrait_info(debug_character_portrait)
    var transform: = get_local_portrait_transform(debug_character_scene_node._get_covered_rect(), character.scale * portrait_info.get("scale", 1))
    debug_character_holder_node.position = transform.position
    debug_character_scene_node.position = portrait_info.get("offset", Vector2()) + character.offset

    debug_character_holder_node.scale = transform.size



func _update_debug_origin() -> void :
    if !Engine.is_editor_hint() or !is_instance_valid(debug_origin):
        return
    debug_origin.position = _get_origin_position()
    _update_debug_portrait_transform()




func _get_debug_character() -> DialogicCharacter:
    return debug_character if debug_character != null else default_debug_character
