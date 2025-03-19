extends Node
class_name DialogicBackground







var viewport_container: SubViewportContainer

var viewport: SubViewport





func _update_background(_argument: String, _time: float) -> void :
    pass




func _should_do_background_update(_argument: String) -> bool:
    return false




func _custom_fade_in(_time: float) -> bool:
    return false




func _custom_fade_out(_time: float) -> bool:
    return false
