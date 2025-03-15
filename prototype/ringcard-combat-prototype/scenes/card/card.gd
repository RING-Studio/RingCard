extends Control
class_name Card

@onready var card_state_machine: CardStateMachine = $CardStateMachine

signal reparent_requested(card: Card)

func _ready() -> void:
	for state in card_state_machine.states.values():
		state.card = self
