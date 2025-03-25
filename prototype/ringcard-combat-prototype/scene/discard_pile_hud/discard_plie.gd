extends HFlowContainer
class_name DiscardPile

func _ready() -> void:
	get_children().map(func free(node): node.queue_free())
