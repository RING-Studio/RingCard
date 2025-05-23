@tool
extends Control


var resource: DialogicEndBranchEvent


var parent_node: Control = null
var end_control: Control = null


var indent_size: = 22
var current_indent_level: = 1

var selected: = false

func _ready() -> void :
    $Icon.icon = get_theme_icon("GuiSpinboxUpdown", "EditorIcons")
    $Spacer.custom_minimum_size.x = 90 * DialogicUtil.get_editor_scale()
    visual_deselect()
    parent_node_changed()



func visual_select() -> void :
    modulate = get_theme_color("highlighted_font_color", "Editor")
    selected = true



func visual_deselect() -> void :
    if !parent_node: return
    selected = false
    modulate = parent_node.resource.event_color.lerp(get_theme_color("font_color", "Editor"), 0.3)


func is_selected() -> bool:
    return selected



func highlight() -> void :
    if !parent_node: return
    modulate = parent_node.resource.event_color.lerp(get_theme_color("font_color", "Editor"), 0.6)



func unhighlight() -> void :
    modulate = parent_node.resource.event_color


func update_hidden_events_indicator(hidden_events_count: int = 0) -> void :
    $HiddenEventsLabel.visible = hidden_events_count > 0
    if hidden_events_count == 1:
        $HiddenEventsLabel.text = "[1 event hidden]"
    else:
        $HiddenEventsLabel.text = "[" + str(hidden_events_count) + " events hidden]"



func set_indent(indent: int) -> void :
    $Indent.custom_minimum_size = Vector2(indent_size * indent * DialogicUtil.get_editor_scale(), 0)
    $Indent.visible = indent != 0
    current_indent_level = indent
    queue_redraw()



func parent_node_changed() -> void :
    if parent_node and end_control and end_control.has_method("refresh"):
        end_control.refresh()



func add_end_control(control: Control) -> void :
    if !control:
        return
    add_child(control)
    control.size_flags_vertical = SIZE_SHRINK_CENTER
    if "parent_resource" in control:
        control.parent_resource = parent_node.resource
    if control.has_method("refresh"):
        control.refresh()
    end_control = control
