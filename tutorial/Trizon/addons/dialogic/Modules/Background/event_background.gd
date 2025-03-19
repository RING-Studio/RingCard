@tool
class_name DialogicBackgroundEvent
extends DialogicEvent









var scene: = ""


var argument: = ""

var fade: float = 0.0

var transition: = ""


enum ArgumentTypes{IMAGE, CUSTOM}
var _arg_type: = ArgumentTypes.IMAGE:
    get:
        if argument.begins_with("res://"):
            return ArgumentTypes.IMAGE
        else:
            return _arg_type
    set(value):
        if value == ArgumentTypes.CUSTOM:
            if argument.begins_with("res://"):
                argument = " " + argument
        _arg_type = value

enum SceneTypes{DEFAULT, CUSTOM}
var _scene_type: = SceneTypes.DEFAULT:
    get:
        if scene.is_empty():
            return _scene_type
        else:
            return SceneTypes.CUSTOM
    set(value):
        if value == SceneTypes.DEFAULT:
            scene = ""
        _scene_type = value




func _execute() -> void :
    var final_fade_duration: = fade

    if dialogic.Inputs.auto_skip.enabled:
        var time_per_event: float = dialogic.Inputs.auto_skip.time_per_event
        final_fade_duration = min(fade, time_per_event)

    dialogic.Backgrounds.update_background(scene, argument, final_fade_duration, transition)

    finish()






func _init() -> void :
    event_name = "Background"
    set_default_color("Color8")
    event_category = "Visuals"
    event_sorting_index = 0






func get_shortcode() -> String:
    return "background"


func get_shortcode_parameters() -> Dictionary:
    return {

        "scene": {"property": "scene", "default": ""}, 
        "arg": {"property": "argument", "default": ""}, 
        "fade": {"property": "fade", "default": 0}, 
        "transition": {"property": "transition", "default": "", 
                                    "suggestions": get_transition_suggestions}, 
    }







func build_event_editor() -> void :
    add_header_edit("_scene_type", ValueType.FIXED_OPTIONS, {
        "left_text": "Show", 
        "options": [
            {
                "label": "Background", 
                "value": SceneTypes.DEFAULT, 
                "icon": ["GuiRadioUnchecked", "EditorIcons"]
            }, 
            {
                "label": "Custom Scene", 
                "value": SceneTypes.CUSTOM, 
                "icon": ["PackedScene", "EditorIcons"]
            }
        ]})
    add_header_label("with image", "_scene_type == SceneTypes.DEFAULT")
    add_header_edit("scene", ValueType.FILE, 
            {"file_filter": "*.tscn, *.scn; Scene Files", 
            "placeholder": "Custom scene", 
            "editor_icon": ["PackedScene", "EditorIcons"], 
            }, "_scene_type == SceneTypes.CUSTOM")
    add_header_edit("_arg_type", ValueType.FIXED_OPTIONS, {
        "left_text": "with", 
        "options": [
            {
                "label": "Image", 
                "value": ArgumentTypes.IMAGE, 
                "icon": ["Image", "EditorIcons"]
            }, 
            {
                "label": "Custom Argument", 
                "value": ArgumentTypes.CUSTOM, 
                "icon": ["String", "EditorIcons"]
            }
        ], "symbol_only": true}, "_scene_type == SceneTypes.CUSTOM")
    add_header_edit("argument", ValueType.FILE, 
            {"file_filter": "*.jpg, *.jpeg, *.png, *.webp, *.tga, *svg, *.bmp, *.dds, *.exr, *.hdr; Supported Image Files", 
            "placeholder": "No Image", 
            "editor_icon": ["Image", "EditorIcons"], 
            }, 
            "_arg_type == ArgumentTypes.IMAGE or _scene_type == SceneTypes.DEFAULT")
    add_header_edit("argument", ValueType.SINGLELINE_TEXT, {}, "_arg_type == ArgumentTypes.CUSTOM")

    add_body_edit("transition", ValueType.DYNAMIC_OPTIONS, 
            {"left_text": "Transition:", 
            "empty_text": "Simple Fade", 
            "suggestions_func": get_transition_suggestions, 
            "editor_icon": ["PopupMenu", "EditorIcons"]})
    add_body_edit("fade", ValueType.NUMBER, {"left_text": "Fade time:"})


func get_transition_suggestions(_filter: String = "") -> Dictionary:
    var transitions: = DialogicResourceUtil.list_special_resources("BackgroundTransition")
    var suggestions: = {}
    for i in transitions:
        suggestions[DialogicUtil.pretty_name(i)] = {"value": DialogicUtil.pretty_name(i), "editor_icon": ["PopupMenu", "EditorIcons"]}
    return suggestions
