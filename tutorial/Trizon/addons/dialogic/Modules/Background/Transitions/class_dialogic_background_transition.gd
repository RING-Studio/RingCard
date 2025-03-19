class_name DialogicBackgroundTransition
extends Node


var this_folder: String = get_script().resource_path.get_base_dir()



var prev_scene: Node

var prev_texture: ViewportTexture


var next_scene: Node

var next_texture: ViewportTexture


var time: float


var bg_holder: DialogicNode_BackgroundHolder


signal transition_finished



func _fade() -> void :
    pass


func set_shader(path_to_shader: String = DialogicUtil.get_module_path("Background").path_join("Transitions/default_transition_shader.gdshader")) -> ShaderMaterial:
    if bg_holder:
        if path_to_shader.is_empty():
            bg_holder.material = null
            bg_holder.color = Color.TRANSPARENT
            return null
        bg_holder.material = ShaderMaterial.new()
        bg_holder.material.shader = load(path_to_shader)
        return bg_holder.material
    return null


func tween_shader_progress(_progress_parameter: = "progress") -> PropertyTweener:
    if !bg_holder:
        return

    if !bg_holder.material is ShaderMaterial:
        return

    bg_holder.material.set_shader_parameter("progress", 0.0)
    var tween: = create_tween()
    var tweener: = tween.tween_property(bg_holder, "material:shader_parameter/progress", 1.0, time).from(0.0)
    tween.tween_callback(emit_signal.bind("transition_finished"))
    return tweener
