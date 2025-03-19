class_name DialogicNode_StyleLayer
extends Control




@export var layer_name: String = "Default"


func _ready() -> void :
    if layer_name.is_empty():
        layer_name = name
    add_to_group("dialogic_style_layer")
