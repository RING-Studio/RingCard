extends Control

# 卡牌间距调整
@export var card_spacing := 50.0

@onready var hand_cards: HBoxContainer = $HandCards

func card_played(played_card):
	# 处理卡牌打出后的逻辑
	print("卡牌已打出:", played_card.card_data.card_name)
