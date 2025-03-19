extends ScrollDamper
class_name CubicScrollDamper




@export_range(0.001, 10000.0, 0.001, "or_greater", "hide_slider")
var friction: = 4.0:
    set(val):
        friction = max(val, 0.001)
        _factor = pow(10.0, friction) - 1.0


var _factor: = 10000.0:
    set(val): _factor = max(val, 1e-12)


func _calculate_velocity_by_time(time: float) -> float:
    if time <= 0.0: return 0.0
    return time * time * time * _factor


func _calculate_time_by_velocity(velocity: float) -> float:
    return pow(abs(velocity) / _factor, 1.0 / 3.0)


func _calculate_offset_by_time(time: float) -> float:
    time = max(time, 0.0)
    return 1.0 / 4.0 * _factor * time * time * time * time


func _calculate_time_by_offset(offset: float) -> float:
    return pow(abs(offset) * 4.0 / _factor, 1.0 / 4.0)
