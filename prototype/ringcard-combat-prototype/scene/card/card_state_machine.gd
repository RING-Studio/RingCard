extends Node
class_name CardStateMachine

@export var init_state: CardState

var current_state: CardState
var states = {}


func _ready() -> void:
	for child in get_children():
		if child is CardState:
			states[child.state] = child
			child.transition_requested.connect(_on_transition_requested)
			
	await owner.ready
	init_state.enter()
	current_state = init_state


func _on_transition_requested(from: CardState, to: CardState.StateName):
	if current_state != from:
		print_debug("卡牌状态不符", current_state, from)
		return
		
	var new_state: CardState = states[to]
	if !new_state:
		print_debug("卡牌新状态不存在", current_state, from)
		return
	
	current_state.exit()
	current_state = new_state
	new_state.enter()
	

func _on_card_gui_input(event: InputEvent) -> void:
	if !current_state:
		print_debug("当前无状态", current_state)
	else:
		current_state.on_gui_input(event)


func _on_card_mouse_entered() -> void:
	if !current_state:
		print_debug("当前无状态", current_state)
	else:
		current_state.on_mouse_entered()


func _on_card_mouse_exited() -> void:
	if !current_state:
		print_debug("当前无状态", current_state)
	else:
		current_state.on_mouse_exited()
