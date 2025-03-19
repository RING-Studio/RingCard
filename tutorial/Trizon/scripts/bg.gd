extends CanvasLayer
@onready var global = $"/root/Global"
var shift = 0.0
var last_frame_shake_strength = 0.0
var tween: Tween
@onready var bg_environment = $"/root/GlobalWorldEnvironment"

func _process(delta):
	if bg_environment.mode != "bg": return
	if global.shake_strength > last_frame_shake_strength:
		shift += global.shake_strength - last_frame_shake_strength
		$ColorRect.material.set_shader_parameter("shift", shift)
		bg_environment.environment.glow_strength += 0.2
		if bg_environment.environment.glow_strength > 2: bg_environment.environment.glow_strength = 2
	bg_environment.environment.glow_strength = lerp(bg_environment.environment.glow_strength, 1.2, delta)
	last_frame_shake_strength = global.shake_strength
