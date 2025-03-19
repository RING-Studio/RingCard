@tool
extends Resource
class_name DialogicStyle





@export var name: = "Style":
    get:
        if name.is_empty():
            return "Unkown Style"
        return name

@export var inherits: DialogicStyle = null


@export var layer_list: Array[String] = []

@export var layer_info: = {
    "": DialogicStyleLayer.new()
}




func _init(_name: = "") -> void :
    if not _name.is_empty():
        name = _name








func get_layer_count() -> int:
    return layer_list.size()




func get_layer_index(id: String) -> int:
    return layer_list.find(id)



func has_layer(id: String) -> bool:
    return id in layer_info or id == ""



func has_layer_index(index: int) -> bool:
    return index < layer_list.size()



func get_layer_id_at_index(index: int) -> String:
    if index == -1:
        return ""
    if has_layer_index(index):
        return layer_list[index]
    return ""


func get_layer_info(id: String) -> Dictionary:
    var info: = {"id": id, "path": "", "overrides": {}}

    if has_layer(id):
        var layer_resource: DialogicStyleLayer = layer_info[id]

        if layer_resource.scene != null:
            info.path = layer_resource.scene.resource_path
        elif id == "":
            info.path = DialogicUtil.get_default_layout_base().resource_path

        info.overrides = layer_resource.overrides.duplicate()

    return info









func get_new_layer_id() -> String:
    var i: = 16
    while String.num_int64(i, 16) in layer_info:
        i += 1
    return String.num_int64(i, 16)




func add_layer(scene: String, overrides: Dictionary = {}, id: = "##") -> String:
    if id == "##":
        id = get_new_layer_id()
    layer_info[id] = DialogicStyleLayer.new(scene, overrides)
    layer_list.append(id)
    changed.emit()
    return id




func delete_layer(id: String) -> void :
    if not has_layer(id) or id == "":
        return

    layer_info.erase(id)
    layer_list.erase(id)

    changed.emit()



func move_layer(from_index: int, to_index: int) -> void :
    if not has_layer_index(from_index) or not has_layer_index(to_index - 1):
        return

    var id: = layer_list.pop_at(from_index)
    layer_list.insert(to_index, id)

    changed.emit()



func set_layer_scene(layer_id: String, scene: String) -> void :
    if not has_layer(layer_id):
        return

    layer_info[layer_id].scene = load(scene)
    changed.emit()


func set_layer_overrides(layer_id: String, overrides: Dictionary) -> void :
    if not has_layer(layer_id):
        return

    layer_info[layer_id].overrides = overrides
    changed.emit()



func set_layer_setting(layer_id: String, setting: String, value: Variant) -> void :
    if not has_layer(layer_id):
        return

    layer_info[layer_id].overrides[setting] = value
    changed.emit()



func remove_layer_setting(layer_id: String, setting: String) -> void :
    if not has_layer(layer_id):
        return

    layer_info[layer_id].overrides.erase(setting)
    changed.emit()










func inherits_anything() -> bool:
    return inherits != null



func get_inheritance_root() -> DialogicStyle:
    if not inherits_anything():
        return self

    var style: DialogicStyle = self
    while style.inherits_anything():
        style = style.inherits

    return style



func merge_layer_infos(layer_info: Dictionary, ancestor_info: Dictionary) -> Dictionary:
    var combined: = layer_info.duplicate(true)

    combined.path = ancestor_info.path
    combined.overrides.merge(ancestor_info.overrides)

    return combined




func get_layer_inherited_info(id: String, inherited_only: = false) -> Dictionary:
    var style: = self
    var info: = {"id": id, "path": "", "overrides": {}}

    if not inherited_only:
        info = get_layer_info(id)

    while style.inherits_anything():
        style = style.inherits
        info = merge_layer_infos(info, style.get_layer_info(id))

    return info



func get_layer_inherited_list() -> Array:
    var list: = layer_list

    if inherits_anything():
        list = get_inheritance_root().layer_list

    return list




func realize_inheritance() -> void :
    layer_list = get_layer_inherited_list()

    var new_layer_info: = {}
    for id in layer_info:
        var info: = get_layer_inherited_info(id)
        new_layer_info[id] = DialogicStyleLayer.new(info.get("path", ""), info.get("overrides", {}))

    layer_info = new_layer_info
    inherits = null
    changed.emit()





func clone() -> DialogicStyle:
    var style: = DialogicStyle.new()
    style.name = name
    style.inherits = inherits

    var base_info: = get_layer_info("")
    set_layer_scene("", base_info.path)
    set_layer_overrides("", base_info.overrides)

    for id in layer_list:
        var info: = get_layer_info(id)
        style.add_layer(info.path, info.overrides, id)

    return style



func prepare() -> void :
    for id in layer_info:
        if layer_info[id].scene:
            ResourceLoader.load_threaded_request(layer_info[id].scene.resource_path)






@export var base_scene: PackedScene = null

@export var base_overrides: = {}

@export var layers: Array[DialogicStyleLayer] = []

func update_from_pre_alpha16() -> void :
    if not layers.is_empty():
        var idx: = 0
        for layer in layers:
            var id: = "##"
            if inherits_anything():
                id = get_layer_inherited_list()[idx]
            if layer.scene:
                add_layer(layer.scene.resource_path, layer.overrides, id)
            else:
                add_layer("", layer.overrides, id)
            idx += 1
        layers.clear()

    if not base_scene == null:
        set_layer_scene("", base_scene.resource_path)
        base_scene = null
    if not base_overrides.is_empty():
        set_layer_overrides("", base_overrides)
        base_overrides.clear()
