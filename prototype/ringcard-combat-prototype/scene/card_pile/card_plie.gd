extends CanvasLayer
class_name CardPile

@onready var card_pile_container: HFlowContainer = $ScrollContainer/MarginContainer/CardPileContainer
@onready var return_button: Button = $ReturnButton

var cards: Array[Card] = []

func _ready() -> void:
	return_button.pressed.connect(_on_return_button_pressed)
	clear()

func clear():
	cards.clear()
	card_pile_container.get_children().map(func free(node): node.queue_free())
	
func shuffle_pile():
	cards.shuffle()
	
func add_card(card: Card):
	cards.append(card)
	if card.get_parent():
		card.reparent(card_pile_container)
	else:
		card_pile_container.add_child(card)
	#card.owner.remove_child(card)
	#card_pile_container.add_child(card)
	card.controllable = false
	
func pop_card(card: Card = null) -> Card:
	if cards.size() == 0:
		print("no card in %s" % name)
		return null
	
	if !card:
		card = cards.pop_front()
	else:
		if card not in cards:
			print_debug("卡牌不存在")
			return null
		else:
			card = cards.pop_at(cards.find(card))
	
	card_pile_container.remove_child(card)
	return card
	
func show_pile():
	show()
	
func hide_pile():
	hide()

func _on_return_button_pressed():
	hide_pile()
	Utils.get_battle().hand.show()
