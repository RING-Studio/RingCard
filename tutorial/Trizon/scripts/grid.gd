extends Control

var card: Button
var contain: Button
var id: int = 0
var global
@export var frozen: bool = false
@export var grid_in_front: Control
@export var grid_left: Control
@export var grid_right: Control
var fix: Tween
func freeze():
    if contain != null and !frozen:
        if contain.card_data.get("constant", []).has("resist_freeze"):
            contain.pop(tr("IMMUNE"))
            return
        frozen = true
        Global.resolving += 1
        await contain.play_freeze()
        await global.do_effect(self, contain, "get_freezed")
        for g in get_tree().get_nodes_in_group("grids"):
            await global.do_effect(g, g.contain, "any_freezed")
        for card_in_hand in get_tree().get_nodes_in_group("in_hand"):
            if card_in_hand in get_tree().get_nodes_in_group("in_hand"):
                await global.do_effect(null, card_in_hand, "in_hand_any_freezed")
        for dead_c in global.graveyard: await global.do_effect(null, dead_c, "gy_any_freeze")
        Global.resolving -= 1
func unfreeze():
    if frozen:
        frozen = false
        Global.resolving += 1
        if contain != null:
            await contain.play_unfreeze()
            await global.do_effect(self, contain, "unfrozen")
        for g in get_tree().get_nodes_in_group("grids"):
            await global.do_effect(g, g.contain, "any_unfrozen")
        Global.resolving -= 1

func _ready():
    add_to_group("grids")
    if get_parent().name == "YourField":
        add_to_group("your_grids")
    elif get_parent().name == "MyField":
        add_to_group("my_grids")
    global = get_node("/root/Global")

func suck(c: Button):
    if card != c or global.resolving > 0: return
    if (
    contain == null and 
    card.card_data["type"] == "mob" and 
    card.card_data["cost"] <= 0 and !global.current_battle.banning and 
    (
    (get_parent().name == "MyField" and 
    ("constant" not in card.card_data or "KAIJU" not in card.card_data["constant"]))
    or 
    (get_parent().name == "YourField" and 
    ("constant" in card.card_data and "KAIJU" in card.card_data["constant"]))
    )):

        landed(card)
        return true
    elif (get_parent().name == "MyField" and 
            contain != null and 
            card.card_data["cost"] > 0):

        if contain.card_data.has("material"):
            var matched_names = contain.card_data["material"].filter(
                func(i): return card.card_data["name"].match (i))
            if !matched_names.is_empty(): card.card_data["cost"] -= 1



        card.label_tween("cost")
        card.card_data["cost"] -= 1
        card.eat.emit()
        await Global.do_effect(null, card, "after_eat", self)
        await Global.get_killed(self, contain)
        for card_in_hand in get_tree().get_nodes_in_group("in_hand"):
            if card_in_hand in get_tree().get_nodes_in_group("in_hand"):
                await global.do_effect(null, card_in_hand, "in_hand_any_tribute")
        return true

    elif card.card_data["type"] == "spell" and card.card_data["cost"] <= 0 and !global.current_battle.banning:
        card = Global.current_battle.split_stack(card)
        var data_back_up = card.card_data.duplicate(true)
        await global.do_effect(self, card, "spell_used")
        var can_double_cast = get_tree().get_nodes_in_group("grids"
            ).map(func(g): return g.contain
            ).filter(func(c): return c != null and c.card_data.has("constant")
            ).map(func(c): return c.card_data["constant"])
        for constants in can_double_cast: for constant in constants:
            if constant.match ("double_cast_*") and data_back_up["name"].match (constant.substr(12)):
                var c_back_up = Global.instantiate_from_pool()
                add_child(c_back_up)
                c_back_up.visible = false
                c_back_up.card_data = data_back_up
                await global.do_effect(self, c_back_up, "spell_used")
                break
        return true

    else: return false

func clear_contain():
    if contain == null: return
    contain.back_to_pool()


    contain = null
    frozen = false

func end_fix(): if fix != null: fix.kill()

func landed(c: Button):
    Music.sound("land.wav")
    $LandParticle.restart()
    c.remove_from_group("in_hand")
    c.unglow()
    global.current_battle.move_child(c, 0)
    c.movable = false
    if fix != null: fix.kill()
    fix = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
    fix.tween_property(c, "position", global_position, 0.2)
    contain = c
    c.enter_field.emit()






    if Global.has_relic("SAGA") and self in get_tree().get_nodes_in_group("my_grids") and c.card_data["atk"] == 0:
        Global.shine_relic("SAGA")
        c.card_data["atk"] += 1

    await global.do_effect(self, c, "landed")
    for g in get_tree().get_nodes_in_group("grids"):
        await global.do_effect(g, g.contain, "any_landed")




func _on_grid_hit_box_area_entered(area):
    card = area.get_parent()

func _on_grid_hit_box_area_exited(_area):
    card = null
