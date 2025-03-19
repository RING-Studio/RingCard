extends Control
var pick_view
var good1
var good2
var good3
var good4
var good5
var global
var current_trade
@export var goods_library: Dictionary = {








    "wealthy": {"name": "wealthy", "pay": "?", "num": 2}, 
    "old_sheep": {"name": "old_sheep", "pay": "?", "num": 2}, 

    "1st_armory": {"name": "1st_armory", "pay": "?", "num": 2}, 
    "Fate": {"name": "Fate", "pay": "?", "num": 2}, 
    "0》1": {"name": "0》1", "pay": "?", "num": 2}, 
    "blizzard": {"name": "blizzard", "pay": "?", "num": 2}, 
    "Arson": {"name": "Arson", "pay": "?", "num": 2}, 
    "mirror": {"name": "mirror", "pay": "?", "num": 2}, 
    "fatality": {"name": "fatality", "pay": "?", "num": 2}, 
    "aether_i": {"name": "aether_i", "pay": "?", "num": 2}, 
    "ritual": {"name": "ritual", "pay": "?", "num": 3}, 
}

func _ready():
    global = get_node("/root/Global")
    good1 = get_node("Card")
    good2 = get_node("Card2")
    good3 = get_node("Card3")
    good4 = get_node("Card4")
    good5 = get_node("Card5")
    get_node("Card").clicked.connect(good_clicked)
    get_node("Card2").clicked.connect(good_clicked)
    get_node("Card3").clicked.connect(good_clicked)
    get_node("Card4").clicked.connect(good_clicked)
    get_node("Card5").clicked.connect(good_clicked)
    pick_view = get_parent().get_node("PickFromDeck")
    pick_view.trade_done.connect(take_off)


func refresh():
    for good in [good1, good2, good3, good4, good5]:
        good.visible = true
        good.good = goods_library.get(goods_library.keys().pop_at(randi() % goods_library.size())).duplicate(true)
        if str(good.good["pay"]) == "?": good.good["pay"] = randi() % 3
        if global.card_prototypes.has(good.good["name"]):
            good.card_data = global.card_prototypes.get(good.good["name"]).duplicate(true)

func good_clicked(card):
    card.z_index = 0
    current_trade = card
    pick_view.refresh()
    pick_view.max_selecting = card.good["num"]
    if card.good["pay"] is int:
        pick_view.event_text.text = "Pay " + str(card.good["num"]) + " card(s) in your deck that cost " + str(card.good["pay"])
    else:
        pick_view.event_text.text = "Pay " + str(card.good["num"]) + " any card(s) in your deck"
    pick_view.good = card.good
    pick_view.visible = true

func take_off():
    current_trade.visible = false
    global.deck_to_draw = global.constant_deck
    if current_trade.good.get("name") in global.card_prototypes.keys():
        current_trade.card_data.merge({"id": global.id}, true)
        global.id += 1
        global.constant_deck.append(current_trade.card_data.duplicate(true))
    current_trade = null
    global.deck_to_draw = global.constant_deck.duplicate(true)
    global.save()

func _on_back_pressed():
    if global.pick_chances == 0:
        var to_field = create_tween().set_trans(Tween.TRANS_QUART)
        to_field.tween_property(global.current_battle, "position", Vector2(0, 0), 0.5)
        global.deck_to_draw = global.constant_deck.duplicate(true)
        await to_field.finished
        global.current_battle.start_battle()
    else:
        var to_field = create_tween().set_trans(Tween.TRANS_QUART)
        to_field.tween_property(global.current_battle, "position", Vector2(0, 1080), 0.5)
        global.deck_to_draw = global.constant_deck.duplicate(true)
