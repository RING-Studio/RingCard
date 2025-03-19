@tool
class_name DialogicLayoutBase
extends Node





func add_layer(layer: DialogicLayoutLayer) -> Node:
    add_child(layer)
    return layer



func get_layer(index: int) -> Node:
    return get_child(index)



func get_layers() -> Array:
    var layers: = []
    for child in get_children():
        if child is DialogicLayoutLayer:
            layers.append(child)
    return layers





func apply_export_overrides() -> void :
    _apply_export_overrides()
    for child in get_children():
        if child.has_method("_apply_export_overrides"):
            child._apply_export_overrides()




func get_global_setting(setting: StringName, default: Variant) -> Variant:
    if setting in self:
        return get(setting)

    if str(setting).to_lower() in self:
        return get(setting.to_lower())

    if "global_" + str(setting) in self:
        return get("global_" + str(setting))

    return default



func _apply_export_overrides() -> void :
    pass





func _enter_tree() -> void :
    _load_persistent_info(Engine.get_meta("dialogic_persistent_style_info", {}))


func _exit_tree() -> void :
    Engine.set_meta("dialogic_persistent_style_info", _get_persistent_info())



func _get_persistent_info() -> Dictionary:
    return {}



func _load_persistent_info(info: Dictionary) -> void :
    pass
