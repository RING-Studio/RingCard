class_name DialogicPortrait
extends Node




var character: DialogicCharacter

var portrait: String









func _should_do_portrait_update(_character: DialogicCharacter, _portrait: String) -> bool:
    return false








func _update_portrait(_passed_character: DialogicCharacter, _passed_portrait: String) -> void :
    pass












func _get_covered_rect() -> Rect2:
    if has_meta("texture_holder_node") and get_meta("texture_holder_node", null) != null and is_instance_valid(get_meta("texture_holder_node")):
        var node: Node = get_meta("texture_holder_node")
        if node is Sprite2D or node is TextureRect:
            return Rect2(node.position, node.get_rect().size)
    return Rect2()



func _set_mirror(mirror: bool) -> void :
    if has_meta("texture_holder_node") and get_meta("texture_holder_node", null) != null and is_instance_valid(get_meta("texture_holder_node")):
        var node: Node = get_meta("texture_holder_node")
        if node is Sprite2D or node is TextureRect:
            node.flip_h = mirror



func _set_extra_data(_data: String) -> void :
    pass







func _highlight() -> void :
    pass



func _unhighlight() -> void :
    pass







func apply_character_and_portrait(passed_character: DialogicCharacter, passed_portrait: String) -> void :
    if passed_portrait == "" or not passed_portrait in passed_character.portraits.keys():
        passed_portrait = passed_character.default_portrait

    portrait = passed_portrait
    character = passed_character


func apply_texture(node: Node, texture_path: String) -> void :
    if not character or not character.portraits.has(portrait):
        return

    if not "texture" in node:
        return

    node.texture = null

    if not ResourceLoader.exists(texture_path):


        if ResourceLoader.exists(character.portraits[portrait].get("image", "")):
            texture_path = character.portraits[portrait].get("image", "")
        else:
            return

    node.texture = load(texture_path)

    if node is Sprite2D or node is TextureRect:
        if node is Sprite2D:
            node.centered = false
        node.scale = Vector2.ONE
        if node is TextureRect:
            if !is_inside_tree():
                await ready
        node.position = node.get_rect().size * Vector2(-0.5, -1)

    set_meta("texture_holder_node", node)
