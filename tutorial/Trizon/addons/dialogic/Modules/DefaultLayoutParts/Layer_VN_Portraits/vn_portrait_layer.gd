@tool
extends DialogicLayoutLayer




@export var portrait_size_mode: DialogicNode_PortraitContainer.SizeModes = DialogicNode_PortraitContainer.SizeModes.FIT_SCALE_HEIGHT


func _apply_export_overrides() -> void :

    for child: DialogicNode_PortraitContainer in % Portraits.get_children():
        child.size_mode = portrait_size_mode
        child.update_portrait_transforms()
