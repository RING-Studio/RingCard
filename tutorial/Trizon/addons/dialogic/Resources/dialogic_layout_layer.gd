@tool
class_name DialogicLayoutLayer
extends Node



@export_group("Layer")
@export_subgroup("Disabled")
@export var disabled: = false



@export_group("Private")
@export var apply_overrides_on_ready: = false

var this_folder: String = get_script().resource_path.get_base_dir()

func _ready() -> void :
    if apply_overrides_on_ready and not Engine.is_editor_hint():
        _apply_export_overrides()




func _apply_export_overrides() -> void :
    pass


func apply_export_overrides() -> void :
    if disabled:
        if "visible" in self:
            set("visible", false)
        process_mode = Node.PROCESS_MODE_DISABLED
    else:
        if "visible" in self:
            set("visible", true)
        process_mode = Node.PROCESS_MODE_INHERIT

    _apply_export_overrides()



func get_global_setting(setting_name: StringName, default: Variant) -> Variant:
    return get_parent().get_global_setting(setting_name, default)
