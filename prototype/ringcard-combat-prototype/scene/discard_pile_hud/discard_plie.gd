extends HFlowContainer
class_name CardPile

func _ready() -> void:
	get_children().map(func free(node): node.queue_free())
	pass
	
