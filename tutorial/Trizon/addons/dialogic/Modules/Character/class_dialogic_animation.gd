class_name DialogicAnimation
extends Node



enum AnimationType{IN = 1, OUT = 2, ACTION = 3, CROSSFADE = 4}

signal finished_once
signal finished


var node: Node


var time: float



var base_position: Vector2

var base_scale: Vector2


var repeats: int



var is_reversed: bool = false


func _ready() -> void :
    finished_once.connect(finished_one_loop)




func animate() -> void :
    pass




func finished_one_loop() -> void :
    repeats -= 1

    if repeats > 0:
        animate()

    else:
        finished.emit()


func pause() -> void :
    if node:
        node.process_mode = Node.PROCESS_MODE_DISABLED


func resume() -> void :
    if node:
        node.process_mode = Node.PROCESS_MODE_INHERIT


func _get_named_variations() -> Dictionary:
    return {}








func get_modulation_property() -> String:
    if node is CanvasGroup:
        return "self_modulate"
    else:
        return "modulate"
