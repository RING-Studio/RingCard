extends Node
@export var text_resource: Node
var card_scene = preload("res://scenes/card.tscn")
var card_pool: Array = []
@export var shake_strength = 0.0
var rng
var rng_seed
var rng_state
@export var story_mode: bool
signal all_resolved
@export var settings: Dictionary = {
    "language": "zh_CN", 
    "bgm_volume": 0.1, 
    "SFX_volume": 0.1, 
    "vsync": true, 
    "fullscreen": true, 
    "screenshake": true, 
    "camerapanning": true, 
    "pitchchange": true, 
}
@export var meta_progress: Dictionary = {
    "new_progress": true, 
    "map_cleared": 0, 
    "highest_streak": 0, 
    "total_death": 0, 
    "node_passed": 0, 
    "fusion_met": 0, 
    "battle_won": 0, 
    "boss_killed": 0, 
    "plot_interval": 0, 
    "tutorial_cleared": false, 
    "chimera_hp": 333, 
    "tag": [], 
    "unlocked_basic_pick_pool": [


        "Igloo", 
        "ScapeGoat", 
        "Ironer", 

        "walking_coin", 
        "Gold_Fish", 
        "mushroom", 
        "fire_BUG", 
        "present", 
        "wolf", 
        "fire_Gate", 
        "fodder", 
        "campfire", 
        "meat_wall", 
        "penguin", 
        "snowman", 
        "Shelter", 
        "fairy", 
        "snow_monster", 

        "berserk", 
        "snowball", 
        "fire_ball", 
        "Letter", 
        "attack", 
        "retreat", 
        "undead_army", 

        ], 
    "unlocked_best_pick_pool": ["antimatter", "old_sheep", "blizzard"], 
}
@export var new_game: bool = true
@export var resolving: int = 0
@export var pick_chances: int = 1
@export var draw_each_turn: int = 2
@export var win_reward: int = 0
@export var draw_start: int = 4
@export var id: int = 0
@export var LP: int = 50
@export var max_LP: int = 50
@export var streak: int = 0
@export var streaks_for_2xHP: int = 40
@export var streaks_for_1more_cost: int = 2
@export var next_pick_fusion: bool = false
@export var next_pick_shiny: bool = false
@export var deck_code: Array
@export var deck_to_draw: Array
@export var constant_deck: Array
@export var graveyard: Array = []
@export var loot_cards: Array = []
@export var relics: Array = []
@export var relic_progress: int = 0
@export var card_detail_view: Control
@export var toplayerui: Control
@export var three_cards: Control
@export var current_battle: Control
@export var current_map: Control
@export var pick_from_deck: Control
@export var start_menu: TextureRect
@export var esc: ColorRect
@export var load: CanvasLayer
@export var unlock_view: ColorRect
@export var deck_view: Control
@export var reveal: Control
@export var gameover: Control
@export var fusion_view: Control
@export var card_prototypes_origin: Dictionary = {
    "Rain": {"name": "Rain", "type": "spell", "atk": 0, "hp": 0, "cost": 0, "constant": ["WET"], }, 
    "mushroom": {"name": "mushroom", "type": "mob", "atk": 0, "hp": 1, "cost": 0, "declare_attack": ["front"], 
        "draw_phase": ["add_mushroom"]}, 
    "hunter": {"name": "hunter", "type": "mob", "atk": 6, "hp": 2, "cost": 2, "declare_attack": ["front"], 
        "get_kill": ["grid_to_hand"]}, 
    "mobius_snake": {"name": "mobius_snake", "type": "mob", "atk": 1, "hp": 3, "cost": 1, "declare_attack": ["front"], 
        "after_eat": ["gain_food_atk_hp"]}, 
    "ScapeGoat": {"name": "ScapeGoat", "type": "mob", "atk": 1, "hp": 9, "cost": 1, 
        "declare_attack": ["front"], "constant": ["guard"]}, 
    "Truce": {"name": "Truce", "type": "spell", "atk": 0, "hp": 0, "cost": 1, \
"spell_used": ["all_freeze", "ban_turn"]}, 
    "Igloo": {"name": "Igloo", "type": "mob", "atk": 0, "hp": 7, "cost": 0, 
        "declare_attack": ["front"], "get_freezed": ["self_protect"]}, 
    "fire_bird": {"name": "fire_bird", "type": "mob", "atk": 6, "hp": 4, "cost": 3, "declare_attack": ["front"], 
        "gy_end_phase": ["itself_revive_to_field"]}, 
    "Ironer": {"name": "Ironer", "type": "mob", "atk": 0, "hp": 6, "cost": 0, 
        "declare_attack": ["front"], "constant": ["protect"]}, 
    "Shelter": {"name": "Shelter", "type": "mob", "atk": 4, "hp": 5, "cost": 2, 
        "declare_attack": ["front"], "end_phase": ["random"]}, 
    "Gold_Fish": {"name": "Gold_Fish", "type": "spell", "atk": 0, "hp": 0, "cost": 0, 
        "constant": ["easy_draw"], "enter_hand": ["summon_random_0"]}, 
    "present": {"name": "present", "type": "mob", "atk": 0, "hp": 3, "cost": 0, "declare_attack": ["front"], 
        "after_death": ["random"]}, 
    "Symbiont": {"name": "Symbiont", "type": "mob", "atk": 3, "hp": 3, "cost": 3, "declare_attack": ["front"], 
        "landed": ["summon_Symbiont"], }, 
    "fodder": {"name": "fodder", "type": "mob", "atk": 5, "hp": 4, "cost": 1, "declare_attack": ["front"], \
"after_spell": ["attack", "not_spell_burn"]}, 
    "ice_coin": {"name": "ice_coin", "type": "spell", "atk": 0, "hp": 0, "cost": 0, 
        "spell_used": ["num_of_freeze_draw"]}, 

    "Vampire": {"name": "Vampire", "type": "mob", "atk": 5, "hp": 7, "cost": 2, "declare_attack": ["front"], \
"get_kill": ["LP+3"]}, 

    "body_sell": {"name": "body_sell", "type": "spell", "atk": 0, "hp": 0, "cost": 0, \
"spell_used": ["give grids after_death:draw"]}, 
    "Sea_Star": {"name": "Sea_Star", "type": "mob", "atk": 0, "hp": 5, "cost": 0, "declare_attack": ["front"], 
        "hurt": ["summon_Sea_Star"]}, 
    "bloody_coin": {"name": "bloody_coin", "type": "spell", "atk": 0, "hp": 0, "cost": 0, 
        "spell_used": ["all_damage_3"], "get_kill": ["draw"]}, 
    "Letter": {"name": "Letter", "type": "spell", "atk": 0, "hp": 0, "cost": 0, "spell_used": ["draw"]}, 
    "walking_coin": {"name": "walking_coin", "type": "mob", "atk": 0, "hp": 2, "cost": 0, "declare_attack": ["front"], 
        "end_phase": ["draw"]}, 
    "Trex": {"name": "Trex", "type": "mob", "atk": 9, "hp": 5, "cost": 3, "declare_attack": ["front"], 
        "landed": ["attack"]}, 


    "Kaiju": {"name": "Kaiju", "type": "mob", "atk": 0, "hp": 1, "cost": 0, "declare_attack": ["front"], 
        "constant": ["KAIJU"], "enter_hand": ["draw"]}, 

    "fatality": {"name": "fatality", "type": "spell", "atk": 0, "hp": 0, "cost": 1, 
        "spell_used": ["new_turn"]}, 
    "Sealed_ice": {"name": "Sealed_ice", "type": "mob", "atk": 1, "hp": 6, "cost": 1, "declare_attack": ["front"], 
        "any_unfrozen": ["random"]}, 
    "pinata": {"name": "pinata", "type": "mob", "atk": 0, "hp": 8, "cost": 1, "declare_attack": ["front"], 
        "hurt": ["random"]}, 
    "Stillbirth": {"name": "Stillbirth", "type": "spell", "atk": 0, "hp": 0, "cost": 0, 
        "pre_battle": ["not_spell_burn"]}, 
    "wolf": {"name": "wolf", "type": "mob", "atk": 2, "hp": 1, "cost": 0, "declare_attack": ["front"], 
        "get_kill": ["random"]}, 
    "stone_army": {"name": "stone_army", "type": "mob", "atk": 5, "hp": 5, "cost": 5, "declare_attack": ["front"], 
        "in_hand_any_death": ["cost_-1"]}, 
    "Demon": {"name": "Demon", "type": "mob", "atk": 4, "hp": 3, "cost": 0, "declare_attack": ["front"], 
        "after_death": ["burn_rightmost"]}, 
    "blizzard": {"name": "blizzard", "type": "spell", "atk": 0, "hp": 0, "cost": 0, 
        "spell_used": ["enemies_freeze"]}, 
    "Wise": {"name": "Wise", "type": "spell", "atk": 0, "hp": 0, "cost": 1, 
        "be_burnt": ["draw_all_cost"]}, 
    "winter_swim": {"name": "winter_swim", "type": "spell", "atk": 0, "hp": 0, "cost": 0, 
        "spell_used": ["spell_atk_4", "unfreeze"]}, 
    "penguin": {"name": "penguin", "type": "mob", "atk": 1, "hp": 8, "cost": 1, "declare_attack": ["front"], 
        "any_freezed": ["both_atk_hp_1"]}, 
    "snow_monster": {"name": "snow_monster", "type": "mob", "atk": 4, "hp": 10, "cost": 2, "declare_attack": ["front"], 
        "hurt": ["freeze_random_enemy"]}, 
    "snowman": {"name": "snowman", "type": "mob", "atk": 3, "hp": 7, "cost": 1, "declare_attack": ["front"], 
        "landed": ["freeze"], "get_freezed": ["add_snowball"]}, 
    "fire_ball": {"name": "fire_ball", "type": "spell", "atk": 0, "hp": 0, "cost": 0, 
        "spell_used": ["damage_4"], "be_burnt": ["deck_add_fire_ball"]}, 
    "fire_Gate": {"name": "fire_Gate", "type": "spell", "atk": 0, "hp": 0, "cost": 1, 
        "be_burnt": ["summon_*fire*"]}, 
    "fire_BUG": {"name": "fire_BUG", "type": "mob", "atk": 0, "hp": 4, "cost": 0, "declare_attack": ["front"], 
        "after_death": ["draw_*fire*"]}, 
    "antimatter": {"name": "antimatter", "type": "spell", "atk": 0, "hp": 0, "cost": -1, "deck_to_hand": ["draw"]}, 
    "Bird": {"name": "Bird", "type": "mob", "atk": 3, "hp": 1, "cost": 0, "declare_attack": ["front"], 
        "end_phase": ["move_right"]}, 
    "Cell": {"name": "Cell", "type": "mob", "atk": 0, "hp": 5, "cost": 0, "declare_attack": ["front"], 
        "changed_LP_ALWAYS": ["all_to_hand"]}, 
    "raid": {"name": "raid", "type": "spell", "atk": 0, "hp": 0, "cost": 1, \
"spell_used": ["summon_fodder", "summon_fodder", "summon_fodder"]}, 
    "campfire": {"name": "campfire", "type": "mob", "atk": 0, "hp": 4, "cost": 1, "declare_attack": ["front"], 
        "any_fire_instantiated": ["draw"]}, 
    "ice_Curse": {"name": "ice_Curse", "type": "spell", "atk": 0, "hp": 0, "cost": 1, 
        "gy_any_freeze": ["enemy_rnd_damage_4"]}, 
    "ice_Ground": {"name": "ice_Ground", "type": "mob", "atk": 0, "hp": 11, "cost": 1, "declare_attack": ["front"], 
        "landed": ["freeze"], "unfrozen": ["freeze", "boost_2"]}, 

    "undead_army": {"name": "undead_army", "type": "spell", "atk": 0, "hp": 0, "cost": 0, \
"spell_used": ["gy_to_field_*"]}, 

    "meat": {"name": "meat", "type": "mob", "atk": 0, "hp": 5, "cost": 0, "declare_attack": ["front"]}, 
    "meat_wall": {"name": "meat_wall", "type": "mob", "atk": 0, "hp": 9, "cost": 1, "declare_attack": ["front"], 
        "end_phase": ["summon_meat"]}, 
    "old_sheep": {"name": "old_sheep", "type": "mob", "atk": 1, "hp": 2, "cost": 0, "declare_attack": ["front"], 
        "pre_battle": ["itself_draw"], }, 




    "fairy": {"name": "fairy", "type": "mob", "atk": 3, "hp": 2, "cost": 1, "declare_attack": ["front"], 
        "after_spell": ["atk_1"]}, 


    "attack": {"name": "attack", "type": "spell", "atk": 0, "hp": 0, "cost": 0, 
        "spell_used": ["spell_attack"], }, 
    "retreat": {"name": "retreat", "type": "spell", "atk": 0, "hp": 0, "cost": 0, 
        "spell_used": ["grid_to_hand"], }, 








    "fire_Cremation": {"name": "fire_Cremation", "type": "spell", "atk": 0, "hp": 0, "cost": 0, \
"spell_used": ["give my_grids after_death:add_fire_ball"]}, 

    "fire_soul": {"name": "fire_soul", "type": "mob", "atk": 4, "hp": 1, "cost": 1, "declare_attack": ["front"], 
        "after_attack": ["revive_*fire_ball*"]}, 
    "fire_twin": {"name": "fire_twin", "type": "mob", "atk": 4, "hp": 4, "cost": 2, "declare_attack": ["front"], 
        "constant": ["double_cast_*fire_ball*"]}, 
    "Zombie": {"name": "Zombie", "type": "mob", "atk": 3, "hp": 6, "cost": 2, "declare_attack": ["front"], 
        "end_phase": ["not_spell_burn", "itself_revive_to_field"]}, 











    "coward": {"name": "coward", "type": "mob", "atk": 4, "hp": 8, "cost": 0, "declare_attack": ["front"], 
        "landed": ["freeze"], "hurt": ["grid_to_hand"]}, 
    "snowball": {"name": "snowball", "type": "spell", "atk": 0, "hp": 0, "cost": 0, 
        "spell_used": ["freeze"]}, 


    "berserk": {"name": "berserk", "type": "mob", "atk": 5, "hp": 12, "cost": 3, "declare_attack": ["front"], 
        "hurt": ["attack"]}, 

    "torture": {"name": "torture", "type": "spell", "atk": 0, "hp": 0, "cost": 0, 
        "spell_used": ["damage_1", "damage_1", "damage_1", "damage_1", ], }, 








    "Abyss": {"name": "Abyss", "type": "spell", "atk": 0, "hp": 0, "cost": 1, 
        "gy_draw_phase": ["summon_*"]}, 
    "Ostrich": {"name": "Ostrich", "type": "mob", "atk": 1, "hp": 5, "cost": 1, "declare_attack": ["front"], 
        "hurt": ["move_right"]}, 
    "fox": {"name": "fox", "type": "mob", "atk": 3, "hp": 3, "cost": 1, "declare_attack": ["front"]}, 
    "slime": {"name": "slime", "type": "mob", "atk": 2, "hp": 5, "cost": 1, "declare_attack": ["front"]}, 
    "shadow": {"name": "shadow", "type": "mob", "atk": 1, "hp": 3, "cost": 1, "declare_attack": ["front"], 
        "any_death": ["atk_2"]}, 
    "alien": {"name": "alien", "type": "mob", "atk": 6, "hp": 5, "cost": 1, "declare_attack": ["front"], 
        "after_death": ["draw", "draw"]}, 
    "card_eater": {"name": "card_eater", "type": "mob", "atk": 3, "hp": 1, "cost": 1, "declare_attack": ["front"], 
        "any_drawn": ["hp_1"]}, 
    "beast": {"name": "beast", "type": "mob", "atk": 5, "hp": 1, "cost": 1, "declare_attack": ["front"]}, 
    "wind_element": {"name": "wind_element", "type": "mob", "atk": 2, "hp": 3, "cost": 1, "declare_attack": ["front"], 
        "any_attack": ["hp_1"]}, 
    "water_element": {"name": "water_element", "type": "mob", "atk": 2, "hp": 4, "cost": 1, "declare_attack": ["front"], 
        "constant": ["WET"]}, 
    "fire_element": {"name": "fire_element", "type": "mob", "atk": 2, "hp": 6, "cost": 2, "declare_attack": ["left", "front", "right"]}, 
    "earth_element": {"name": "earth_element", "type": "mob", "atk": 2, "hp": 3, "cost": 1, "declare_attack": ["front"], 
        "after_death": ["allies_random_protect"]}, 
    "Masochism": {"name": "Masochism", "type": "mob", "atk": 3, "hp": 4, "cost": 1, "declare_attack": ["front"], 
        "hurt": ["both_atk_hp_+1"], }, 
    "bear": {"name": "bear", "type": "mob", "atk": 6, "hp": 6, "cost": 2, "declare_attack": ["front"]}, 
    "goat": {"name": "goat", "type": "mob", "atk": 2, "hp": 8, "cost": 2, "declare_attack": ["front", "front"]}, 
    "bat": {"name": "bat", "type": "mob", "atk": 4, "hp": 3, "cost": 2, "declare_attack": ["front"], 
        "after_attack": ["hp_+3"]}, 
    "goblin": {"name": "goblin", "type": "mob", "atk": 4, "hp": 8, "cost": 2, "declare_attack": ["front"]}, 
    "Sigma": {"name": "Sigma", "type": "mob", "atk": 3, "hp": 5, "cost": 2, "declare_attack": ["front"], 
        "fatal_hurt": ["hp_+2"]}, 
    "Antispell": {"name": "Antispell", "type": "mob", "atk": 2, "hp": 9, "cost": 2, "declare_attack": ["front"], 
        "spell_boost": -1}, 
    "lion": {"name": "lion", "type": "mob", "atk": 9, "hp": 9, "cost": 3, "declare_attack": ["front"], "landed": ["freeze"]}, 
    "living_armor": {"name": "living_armor", "type": "mob", "atk": 1, "hp": 10, "cost": 3, "declare_attack": ["front"], 
        "constant": ["protect"], "lose_protect": ["atk_+3"]}, 
    "nest": {"name": "nest", "type": "mob", "atk": 0, "hp": 10, "cost": 3, "declare_attack": ["front"], 
        "hurt": ["summon_random_1"]}, 
    "Asher": {"name": "Asher", "type": "mob", "atk": 5, "hp": 6, "cost": 3, "declare_attack": ["front"], 
        "after_death": ["deck_add_Ash", "deck_add_Ash", "deck_add_Ash"]}, 
    "orge": {"name": "orge", "type": "mob", "atk": 6, "hp": 10, "cost": 4, "declare_attack": ["front"], 
        "after_death": ["enemy_rnd_damage_10"]}, 
    "healer": {"name": "healer", "type": "mob", "atk": 2, "hp": 8, "cost": 4, "declare_attack": ["front"], 
        "hurt": ["allies_atk_hp_1"]}, 
    "hipo": {"name": "hipo", "type": "mob", "atk": 0, "hp": 22, "cost": 5, "declare_attack": ["front"], 
        "draw_phase": ["atk_3"]}, 
    "elephant": {"name": "elephant", "type": "mob", "atk": 6, "hp": 16, "cost": 6, "declare_attack": ["front"], 
        "draw_phase": ["hp_3"]}, 
    "thief": {"name": "thief", "type": "mob", "atk": 3, "hp": 8, "cost": 3, "declare_attack": ["front"], 
        "end_phase": ["attack"]}, 
    "iceberg": {"name": "iceberg", "type": "mob", "atk": 4, "hp": 7, "cost": 2, "declare_attack": ["front"], 
        "after_attack": ["freeze_random_enemy"]}, 
    "icy_slayer": {"name": "icy_slayer", "type": "mob", "atk": 5, "hp": 12, "cost": 5, "declare_attack": ["front"], 
        "draw_phase": ["freeze_in_front"]}, 
    "BAIT": {"name": "BAIT", "type": "mob", "atk": 3, "hp": 3, "cost": 7, "declare_attack": ["front"], 
        "after_death": ["summon_random_3", "summon_random_3"]}, 



    "Unican": {"name": "Unican", "type": "spell", "atk": 0, "hp": 0, "cost": 0, \
"constant": ["gold"], "pre_battle": ["itself_draw"], "be_burnt": ["next_pick_fusion"]}, 
    "chimera2": {"name": "chimera2", "type": "mob", "atk": 3, "hp": 3, "cost": 1, "declare_attack": ["front"], 
        "after_death": ["fusion_not_consume"]}, 
    "chimera": {"name": "chimera", "type": "mob", "atk": 333, "hp": 333, "cost": 33, "declare_attack": ["front"], 
        "constant": ["atk=hp", "meta_hp"], "any_death": ["summon_random_1"]}, 
    "Aggres": {"name": "Aggres", "type": "mob", "atk": 13, "hp": 66, "cost": 66, "declare_attack": ["front"]}, 











































    "Ash": {"name": "Ash", "type": "spell", "atk": 0, "hp": 0, "cost": 1, 
        "enter_hand": ["not_spell_burn", ]}, 
    "silver1": {"name": "silver1", "type": "mob", "atk": 3, "hp": 25, "cost": 14, "declare_attack": ["front"], 
        "after_spell": ["deck_add_Ash"], "draw_phase": ["summon_random_1"], "after_death": ["summon_silver2"]}, 
    "silver2": {"name": "silver2", "type": "mob", "atk": 4, "hp": 25, "cost": 7, "declare_attack": ["front"], 
        "landed": ["attack"], "any_death": ["deck_add_Ash"], "after_death": ["summon_silver3"]}, 
    "silver3": {"name": "silver3", "type": "mob", "atk": 5, "hp": 25, "cost": 7, "declare_attack": ["left", "front", "right"], 
        "landed": ["attack"], "after_spell": ["hp_5"]}, 

    "zooer1": {"name": "zooer1", "type": "mob", "atk": 1, "hp": 25, "cost": 14, "declare_attack": ["front"], 
        "draw_phase": ["summon_random_1", "summon_random_1"], "after_death": ["summon_zooer2"]}, 
    "zooer2": {"name": "zooer2", "type": "mob", "atk": 2, "hp": 25, "cost": 7, "declare_attack": ["front"], 
        "landed": ["summon_random_2", "summon_random_2"], "after_spell": ["summon_random_2"], "after_death": ["summon_zooer3"]}, 
    "zooer3": {"name": "zooer3", "type": "mob", "atk": 3, "hp": 25, "cost": 7, "declare_attack": ["front"], 
        "landed": ["summon_random_3", "summon_random_3"], "end_phase": ["summon_random_3"]}, 

    "War1": {"name": "War1", "type": "mob", "atk": 3, "hp": 25, "cost": 14, "declare_attack": ["front"], 
        "any_drawn": ["vampire"], "after_death": ["summon_War2"]}, 
    "War2": {"name": "War2", "type": "mob", "atk": 3, "hp": 25, "cost": 7, "declare_attack": ["front"], 
        "landed": ["summon_random_3"], "after_attack": ["allies_atk_hp_1"], "after_death": ["summon_War3"]}, 
    "War3": {"name": "War3", "type": "mob", "atk": 3, "hp": 25, "cost": 7, "declare_attack": ["front"], 
        "landed": ["summon_shadow", "summon_shadow", "summon_shadow"], "after_spell": ["summon_shadow"]}, 






















    "Shooter1": {"name": "Shooter1", "type": "mob", "atk": 2, "hp": 20, "cost": 7, "declare_attack": ["front", "front"], 
        "after_attack": ["enemy_rnd_damage_2"], "after_death": ["summon_Shooter2"]}, 
    "Shooter2": {"name": "Shooter2", "type": "mob", "atk": 4, "hp": 20, "cost": 5, "declare_attack": ["front"], 
        "after_attack": ["all_enemies_damage_4"]}, 

    "Freezer1": {"name": "Freezer1", "type": "mob", "atk": 3, "hp": 20, "cost": 7, "declare_attack": ["front"], 
        "draw_phase": ["freeze_random_enemy", "freeze_random_enemy"], "after_death": ["summon_Freezer2"]}, 
    "Freezer2": {"name": "Freezer2", "type": "mob", "atk": 3, "hp": 20, "cost": 5, "declare_attack": ["front"], 
        "landed": ["enemies_freeze"], "any_freezed": ["atk_+3"]}, 

    "Reborner1": {"name": "Reborner1", "type": "mob", "atk": 3, "hp": 10, "cost": 7, "declare_attack": ["front"], 
        "landed": ["summon_Reborner2"], "after_death": ["allies_atk_hp_10"]}, 
    "Reborner2": {"name": "Reborner2", "type": "mob", "atk": 0, "hp": 15, "cost": 5, "declare_attack": ["front"], 
        "after_death": ["summon_random_3", "summon_random_3", "summon_random_3"]}, 








    "bandage": {"name": "bandage", "type": "spell", "atk": 0, "hp": 0, "cost": 0, 
        "spell_used": ["LP+15", "consumable"], "pre_battle": ["itself_draw"]}, 
    "refire": {"name": "refire", "type": "spell", "atk": 0, "hp": 0, "cost": 0, 
        "spell_used": ["refire", "consumable"], "pre_battle": ["itself_draw"]}, 
    "poke_ball": {"name": "poke_ball", "type": "spell", "atk": 0, "hp": 0, "cost": 0, 
        "spell_used": ["damage_3", "consumable"], "get_kill": ["spell_copy_forever"], }, 


    "Magic_spring": {"name": "Magic_spring", "type": "mob", "atk": 0, "hp": 1, "cost": 0, "declare_attack": ["front"], 
        "spell_boost": 5, "after_spell": ["consumable"]}, 
    "Fate": {"name": "Fate", "type": "spell", "atk": 0, "hp": 0, "cost": 0, 
        "spell_used": ["damage_7", "consumable"], "get_kill": ["enemy_rnd_damage_7"]}, 

}






























@export var card_prototypes: Dictionary = card_prototypes_origin.duplicate(true)
@export var basic_pick_pool: Array = []
@export var best_pick_pool: Array = []
@export var consumable_pool: Array = [
    "refire", "Fate", "Magic_spring", 
    "poke_ball", "poke_ball", "poke_ball", ]
@export var enemy_pool: Array = [
    "slime", 
    "alien", 
    "Ostrich", 
    "Masochism", 
    "card_eater", 
    "shadow", 
    "beast", 
    "wind_element", 
    "water_element", 
    "earth_element", 
    "fox", 
    "bear", 
    "Sigma", 
    "fire_element", 
    "bat", 
    "goat", 
    "goblin", 
    "iceberg", 
    "Antispell", 
    "lion", 
    "nest", 
    "living_armor", 
    "Asher", 
    "thief", 
    "hipo", 
    "healer", 
    "orge", 
    "icy_slayer", 
    "elephant", 
    "BAIT", 






]
@export var boss_pool: Array = ["silver1", "zooer1", "War1", "Shooter1", "Freezer1", "Reborner1", ]
@export var shiny_pool: Array = [
    "blizzard", "Arson", "0》1", "ritual", "thyu", "!Fusion!", "Abyss", "antimatter", 
    "Freezer", "Reborner", "Curser", "Stillbirth", "nova_magic", "body_sell", 
    "old_sheep", "silver", "zooer", "War", "Death", "Shooter", "Unican", 
    "chef", "Rain", ]
@export var relics_pool: Array = [
    "SCISSOR", "RASENN", "CYOKO", "HUMBIRD", "BROCOLI", "STEINGATE", 
    "PPOINT", "REDPIG", "SAGA", "KORO", "SHENZHEN", "SYAMIKO", 
    ]




















@export var all_pick_pools: Array
@export var all_cards_pools: Array
@export var rainbow_cards: Array = []
var rainbow_dict: Dictionary = {
    "meat": {"name": "meat", "type": "mob", "atk": 1, "hp": 5, "cost": 0, "declare_attack": ["front"], 
        "constant": ["rainbow", "WET"]}, 
    "fodder": {"name": "fodder", "type": "mob", "atk": 6, "hp": 4, "cost": 1, "declare_attack": ["front"], \
"constant": ["rainbow", "WET"], "after_spell": ["attack", "not_spell_burn"]}, 
    "penguin": {"name": "penguin", "type": "mob", "atk": 2, "hp": 8, "cost": 1, "declare_attack": ["front"], 
        "constant": ["rainbow"], "any_freezed": ["allies_atk_hp_1"]}, 
    "Symbiont": {"name": "Symbiont", "type": "mob", "atk": 4, "hp": 3, "cost": 2, "declare_attack": ["front"], 
        "constant": ["rainbow", "WET"], "landed": ["summon_Symbiont"], }, 
    "Sealed_ice": {"name": "Sealed_ice", "type": "mob", "atk": 2, "hp": 6, "cost": 1, "declare_attack": ["front"], 
        "constant": ["rainbow"], "any_freezed": ["random"]}, 
    "pinata": {"name": "pinata", "type": "mob", "atk": 1, "hp": 8, "cost": 1, "declare_attack": ["front"], 
        "constant": ["rainbow", "protect"], "hurt": ["random"]}, 
    "present": {"name": "present", "type": "mob", "atk": 1, "hp": 3, "cost": 0, "declare_attack": ["front"], 
        "constant": ["rainbow"], "after_death": ["random", "random"]}, 
    "wolf": {"name": "wolf", "type": "mob", "atk": 3, "hp": 1, "cost": 0, "declare_attack": ["front"], 
        "constant": ["rainbow"], "get_kill": ["random", "random"]}, 
    "fairy": {"name": "fairy", "type": "mob", "atk": 4, "hp": 2, "cost": 1, "declare_attack": ["front"], 
        "constant": ["rainbow"], "after_spell": ["both_atk_hp_1", "both_atk_hp_1"]}, 
}

func change_lang(lang):
    text_resource = get_node("/root/" + lang)
    TranslationServer.set_locale(lang)
    card_name = text_resource.card_name
    descriptions = text_resource.descriptions
    effect_spec = text_resource.effect_spec
    effect_triggers = text_resource.effect_triggers
    ui = text_resource.ui
    settings.language = lang
    save_settings()

func instantiate_deck(code):
    for _card in code:
        add_to_constant_deck(card_prototypes[_card])

func graveyard_append(card):
    if card == null: return
    var card_data = card
    if card is not Dictionary:
        card_data = card.card_data
        current_battle.move_trail(card.global_position + card.size * card.scale / 2)
    graveyard.append(card_data)

func spell_dispose_helper(card):
    if card.visible: await get_tree().create_timer(1.5).timeout
    if card != null and !all_resolved.is_connected(card.back_to_pool):
        all_resolved.connect(card.back_to_pool)

func append_protect(grid, card):
    if card == null: return false
    var card_data = card
    if card is Button: card_data = card.card_data
    if ("constant" not in card_data or "protect" not in card_data["constant"] or "infinite_protect" in card_data["constant"]):
        card_data.merge({"constant": []})
        card_data["constant"].append("protect")
        if card is Button: card.pop("+" + tr("PROTECT"))
        await do_effect(grid, card, "gain_protect")
        return true
    else: return false

func grid_to_hand(grid):
    if grid == null or grid.contain == null: return
    var is_fire = grid.contain.card_data["name"].match ("*fire*")
    var retreated_c = grid.contain
    grid.contain.play_unfreeze()
    grid.contain.add_to_group("in_hand")
    grid.contain.movable = true
    grid.contain = null
    current_battle.back_to_hand()
    await grid.unfreeze()
    await do_effect(grid, retreated_c, "enter_hand")
    await do_effect(grid, retreated_c, "after_grid_to_hand")
    if is_fire:
        for g in get_tree().get_nodes_in_group("grids"):
            await do_effect(g, g.contain, "any_fire_instantiated")

func do_effect(grid: Control, card, trigger: String, target_g = null):
    if card == null: return
    var content
    if card is Button: content = card.card_data.get(trigger)
    elif card is Dictionary: content = card.get(trigger)
    if (content == null or content == []) and trigger != "spell_used": return
    var my_only: bool = true
    var cast_on_empty_grid = false
    if grid != null and grid.contain == null: cast_on_empty_grid = true
    var cast_on_freeze = false
    if grid != null: cast_on_freeze = grid.frozen
    var cast_when_0_deck = false
    if deck_to_draw.is_empty(): cast_when_0_deck = true
    if grid != null: my_only = grid.get_parent().name == "MyField"
    var allies_side = "your_grids"
    if my_only: allies_side = "my_grids"
    if trigger == "declare_attack":
        for target_grid_name in content:
            var target_grid
            match target_grid_name:
                "front": target_grid = grid.grid_in_front
                "left": target_grid = grid.grid_in_front.grid_left
                "right": target_grid = grid.grid_in_front.grid_right
            if target_grid != null and card != null:
                await basic_attack(grid, card, target_grid)
        return
    if trigger == "spell_used":
        if resolving > 0: return
        resolving += 1
        var tmmm = get_tree().get_nodes_in_group("in_hand")
        tmmm.sort_custom(func(a, b): return a.get_index() < b.get_index())
        var index_in_hand = 0
        if !tmmm.is_empty(): index_in_hand = card.get_index() - tmmm[0].get_index()
        if content == null:
            burn_spell(card)
            content = []

        var grids_to_cast = [grid]
        if "constant" in card.card_data and "cast_on_all_grids" in card.card_data["constant"]:
            grids_to_cast = get_tree().get_nodes_in_group("grids")
        var original_grid = grid
        for onlyuseonce in grids_to_cast:
            grid = onlyuseonce
            for spell: String in content:
                resolving += 1
                if spell == "spell_attack" and grid.contain != null:
                    burn_spell(card)
                    await do_effect(grid, grid.contain, "declare_attack")
                elif spell == "aoe_targets" and my_only and grid.contain != null:
                    burn_spell(card)
                    grid.contain.card_data.get("declare_attack").append("left")
                    grid.contain.card_data.get("declare_attack").append("right")
                elif spell.match ("hands_cost_*"):
                    burn_spell(card)
                    var amt = spell.substr(11).to_int()
                    for c_hand in get_tree().get_nodes_in_group("in_hand"):
                        c_hand.card_data["cost"] += amt
                elif spell == "next_pick_fusion":
                    burn_spell(card)
                    next_pick_fusion = true
                elif spell == "new_turn":
                    burn_spell(card)
                    await current_battle.start_turn(false)
                elif spell == "give_protect" and grid.contain != null:
                    burn_spell(card)
                    await append_protect(grid, grid.contain)
                elif spell == "draw":
                    burn_spell(card)
                    await current_battle.draw_from_deck()
                elif spell == "grid_to_hand" and grid.contain != null and my_only:
                    burn_spell(card)
                    await grid_to_hand(grid)
                elif spell == "super_grid_to_hand" and grid.contain != null and (
                        !boss_pool.has(grid.contain.card_data["name"]) and 
                        !["chimera", "Aggres"].has(grid.contain.card_data["name"])):
                    burn_spell(card)
                    await grid_to_hand(grid)
                elif spell == "ban_turn":
                    current_battle.ban_turn()
                elif spell == "permanent_hp+" and grid.contain != null and my_only:
                    burn_spell(card)
                    for data in constant_deck:
                        if data["id"] == grid.contain.card_data["id"]:
                            data["hp"] += 1
                    grid.contain.card_data["hp"] += 1
                elif spell == "permanent_atk+" and grid.contain != null and my_only:
                    burn_spell(card)
                    for data in constant_deck:
                        if data["id"] == grid.contain.card_data["id"]:
                            data["atk"] += 1
                    grid.contain.card_data["atk"] += 1
                elif spell.match ("add_*"):
                    burn_spell(card)
                    var add_name = spell.substr(4)
                    var possible_cards = card_prototypes.values().filter(func(data): return data["name"].match (add_name))
                    var actual_add = possible_cards[Randi() % possible_cards.size()].duplicate(true)
                    await current_battle.instantiate_card(actual_add, card.global_position)
                elif spell.match ("deck_add_*"):
                    burn_spell(card)
                    var add_name = spell.substr(9)
                    var possible_cards = card_prototypes.values().filter(func(data): return data["name"].match (add_name))
                    var actual_add = possible_cards[Randi() % possible_cards.size()].duplicate(true)
                    deck_to_draw.append(actual_add)
                elif spell.match ("damage_*") and grid.contain != null:
                    burn_spell(card)
                    await damage(spell.substr(7).to_int(), grid.contain, grid, card, null)
                elif spell.match ("all_damage_*"):
                    burn_spell(card)
                    var d = spell.substr(11).to_int()
                    for g in get_tree().get_nodes_in_group("your_grids"): await damage(d, g.contain, g, card, grid)
                    for g in get_tree().get_nodes_in_group("my_grids"): await damage(d, g.contain, g, card, grid)
                elif spell.match ("all_enemies_damage_*"):
                    burn_spell(card)
                    var d = spell.substr(19).to_int()
                    for g in get_tree().get_nodes_in_group("your_grids"): await damage(d, g.contain, g, card, grid)
                elif spell == "refresh_deck":
                    burn_spell(card)
                    deck_to_draw = constant_deck.duplicate(true)
                elif spell == "card_reward":
                    burn_spell(card)
                    pick_chances += 1
                elif spell == "pick_chance_-1":
                    burn_spell(card)
                    pick_chances -= 1
                elif spell == "vampire" and my_only and grid.contain != null:
                    burn_spell(card)
                    if !grid.contain.card_data.has("on_damage"): grid.contain.card_data.merge({"on_damage": []})
                    grid.contain.card_data["on_damage"].append("vampire")
                elif spell.match ("LP*"):
                    burn_spell(card)
                    await gain_LP(spell.substr(2).to_int())
                elif spell.match ("spell_hp_*") and grid.contain != null:
                    burn_spell(card)
                    grid.contain.card_data["hp"] += spell.substr(8).to_int()

                elif spell.match ("spell_atk_*") and grid.contain != null:
                    burn_spell(card)
                    grid.contain.card_data["atk"] += spell.substr(9).to_int()
                    if grid.contain.card_data["atk"] < 0: grid.contain.card_data["atk"] = 0
                elif spell.match ("cost_*"):
                    burn_spell(card)
                    if card is Dictionary: card["cost"] += spell.substr(5).to_int()
                    else: card.card_data["cost"] += spell.substr(5).to_int()
                elif spell == "freeze" and !grid.frozen and grid.contain != null:
                    burn_spell(card)
                    await grid.freeze()
                elif spell == "unfreeze":
                    burn_spell(card)
                    await grid.unfreeze()
                elif spell == "enemies_freeze":
                    burn_spell(card)
                    for g in get_tree().get_nodes_in_group("your_grids"):
                        await g.freeze()
                elif spell == "all_freeze":
                    burn_spell(card)
                    for g in get_tree().get_nodes_in_group("your_grids"): await g.freeze()
                    for g in get_tree().get_nodes_in_group("my_grids"): await g.freeze()
                elif spell == "num_of_freeze_draw":
                    burn_spell(card)
                    var frozen_grids = get_tree().get_nodes_in_group("grids").filter(func(g): return g.frozen)
                    for i in range(frozen_grids.size()): await current_battle.draw_from_deck()
                elif spell.match ("draw_all_*"):
                    burn_spell(card)
                    var cards = deck_to_draw.filter(func(i): return i.get("name").match (spell.substr(9)))
                    for i in cards:
                        if deck_to_draw.has(i): await current_battle.draw_from_deck(i)
                elif spell.match ("draw_*"):
                    burn_spell(card)
                    await current_battle.draw_from_deck(null, spell.substr(5))
                elif spell.match ("revive_all_*"):
                    burn_spell(card)
                    var cards = graveyard.filter(func(i): return i.get("name").match (spell.substr(11)))
                    for i in cards:
                        await current_battle.instantiate_card(i)

                        graveyard.erase(i)
                elif spell == "auto_retreat" and grid != null and grid.contain != null and my_only:
                    burn_spell(card)
                    if !grid.contain.card_data.has("get_kill"): grid.contain.card_data.merge({"get_kill": []})
                    grid.contain.card_data["get_kill"].append("grid_to_hand")
                elif spell == "mirror" and grid != null and grid.contain != null and my_only:
                    burn_spell(card)
                    await current_battle.instantiate_card(grid.contain.card_data.duplicate(true))
                elif spell == "tune_atk_hp":
                    var card_data = card
                    if card is not Dictionary: card_data = card.card_data
                    if card_data["hp"] > card_data["atk"]:
                        card_data["atk"] = card_data["hp"]
                        if card is not Dictionary: card.label_tween("atk")
                    elif card_data["hp"] < card_data["atk"]:
                        card_data["hp"] = card_data["atk"]
                        if card is not Dictionary: card.label_tween("hp")
                elif spell == "flip" and grid != null and grid.contain != null and my_only:
                    burn_spell(card)
                    var temp = grid.contain.card_data["hp"]
                    grid.contain.card_data["hp"] = grid.contain.card_data["atk"]
                    grid.contain.card_data["atk"] = temp
                    if grid.contain.card_data["hp"] <= 0: get_killed(grid, grid.contain)
                elif spell == "self_harm" and grid != null and grid.contain != null:
                    burn_spell(card)
                    damage(grid.contain.card_data["atk"], grid.contain, grid, grid.contain, grid)
                elif spell == "consumable":
                    burn_spell(card)
                    var this_c = constant_deck.filter(func(i): return i["id"] == card.card_data["id"])
                    if !this_c.is_empty(): constant_deck.erase(this_c[0])
                elif spell == "refire":
                    burn_spell(card)
                    var in_hands = get_tree().get_nodes_in_group("in_hand")
                    var redraw = in_hands.size()
                    for c in in_hands:

                        await burn_card_in_hand(c)
                    for i in range(redraw): await current_battle.draw_from_deck()
                elif spell.match ("summon_*"):
                    burn_spell(card)
                    var summon_name = spell.substr(7)
                    var possible_cards
                    if summon_name == "*": possible_cards = [random_card_data(null, "mob")]
                    elif summon_name.match ("random_*"):
                        var pool
                        var c = summon_name.substr(7)





                        possible_cards = [random_card_data(c, "mob")]
                    else:
                        possible_cards = card_prototypes.values().filter(func(data): return data["name"].match (summon_name) and data["type"] == "mob")
                    var actual_add = possible_cards[Randi() % possible_cards.size()].duplicate(true)
                    if grid != null and my_only and grid.contain == null:
                        await current_battle.set_grid_with(grid, actual_add)
                    else:
                        var rand_grid = random_empty_grids("my_grids")
                        await current_battle.set_grid_with(rand_grid, actual_add)
                elif spell.match ("gy_to_field_*"):
                    burn_spell(card)
                    var cards = graveyard.filter(func(i): return i.get("name").match (spell.substr(12)))
                    cards = cards.filter(func(i): return i.get("type") == "mob")
                    if !cards.is_empty():
                        var removed = cards[Randi() % cards.size()]
                        graveyard.erase(removed)
                        if removed["hp"] <= 0: removed["hp"] = 1
                        var targ_grid = random_empty_grids("my_grids")
                        if grid != null and grid.contain == null and my_only: targ_grid = grid
                        await current_battle.set_grid_with(targ_grid, removed)
                elif spell == "spell_burn":
                    burn_spell(card)
                elif spell == "burn_rightmost":
                    burn_spell(card)
                    var cards = get_tree().get_nodes_in_group("in_hand")
                    cards.sort_custom(func(a, b): return a.get_index() > b.get_index())
                    if !cards.is_empty(): await burn_card_in_hand(cards[0])
                elif spell == "delete_burn_rightmost":
                    burn_spell(card)
                    var cards = get_tree().get_nodes_in_group("in_hand")
                    cards.sort_custom(func(a, b): return a.get_index() > b.get_index())
                    if !cards.is_empty():
                        constant_deck.erase(cards[0].card_data)
                        await burn_card_in_hand(cards[0])
                elif spell == "burn_hands_damage_all_enemies":
                    burn_spell(card)
                    var delete_amount = 0
                    for left in range(index_in_hand):
                        var in_hands = get_tree().get_nodes_in_group("in_hand")
                        in_hands.sort_custom(func(a, b): return a.get_index() < b.get_index())
                        if !in_hands.is_empty():
                            delete_amount += 1
                            await burn_card_in_hand(in_hands[0])
                    for g in get_tree().get_nodes_in_group("your_grids"): await damage(delete_amount, g.contain, g, card, grid)

                elif spell.match ("give *"):
                    burn_spell(card)
                    var string = spell.split(" ")
                    var target_group = string[1]
                    var eff_to_append = string[2].split(":")
                    var trig = eff_to_append[0]
                    var eff = eff_to_append[1]
                    var targets = get_tree().get_nodes_in_group(target_group)
                    if target_group == "this_grid": targets = [grid]
                    for g in targets:
                        if g.contain != null:
                            g.contain.card_data.merge({trig: []})
                            g.contain.card_data[trig].append(eff)
                            g.contain.pop("+" + tr("EFFECT"))
                elif spell == "fill_and_add_remains_fodder":
                    burn_spell(card)
                    var fodder = card_prototypes["fodder"]
                    var empty_grids = []
                    for g in get_tree().get_nodes_in_group("my_grids"):
                        if g.contain == null:
                            empty_grids.append(g)
                    for g in empty_grids:
                        await current_battle.set_grid_with(g, fodder)
                    for n in range(0, 5 - empty_grids.size()):
                        await current_battle.instantiate_card(fodder, card.global_position)
                elif spell.match ("spell_add_accord_allies_*"):
                    burn_spell(card)
                    for i in range(get_tree().get_nodes_in_group("my_grids").filter(func(g): return g.contain != null).size()):
                        await current_battle.instantiate_card(card_prototypes.get(spell.substr(24)), card.global_position)

                resolving -= 1
        grid = original_grid
        if cast_on_empty_grid:
            if !card.is_casted and card.card_data.has("cast_on_empty_grid"): burn_spell(card)
            await do_effect(grid, card, "cast_on_empty_grid")
        if cast_on_freeze: await do_effect(grid, card, "cast_on_freeze")
        if (cast_when_0_deck or deck_to_draw.is_empty()) and card.is_casted:
            await do_effect(grid, card, "cast_when_0_deck")

        if card.is_casted and card.card_data["type"] == "spell":
            if "constant" in card.card_data and "WET" in card.card_data["constant"]:
                card.card_data["constant"].erase("WET")
                card.pop("-" + tr("WET"))
                card.is_casted = false
                for g in get_tree().get_nodes_in_group("grids"): await do_effect(g, g.contain, "after_spell")
                for c in get_tree().get_nodes_in_group("in_hand"):
                    if c in get_tree().get_nodes_in_group("in_hand"):
                        await do_effect(null, c, "in_hand_after_spell")
            else:
                graveyard_append(card)
                await do_effect(null, card.card_data, "be_burnt")
                for g in get_tree().get_nodes_in_group("grids"): await do_effect(g, g.contain, "after_spell")
                for c in get_tree().get_nodes_in_group("in_hand"):
                    if c in get_tree().get_nodes_in_group("in_hand"):
                        await do_effect(null, c, "in_hand_after_spell")

                spell_dispose_helper(card)
        resolving -= 1
        if resolving == 0: all_resolved.emit()
        current_battle.could_die()
        return

    var hidden_effect = false
    if card is Dictionary:
        hidden_effect = true
        current_battle.show_card(card)
    if card is not Dictionary and trigger != "per_any_damage": await card.play_do_effect()
    if unchainable(): return
    for effect in content:
        resolving += 1
        if effect == "self_copy" and my_only:
            var copied_data = card_prototypes[card.card_data["name"]]
            await current_battle.instantiate_card(copied_data)
        elif effect.match ("hands_cost_*"):
            var amt = effect.substr(11).to_int()
            for c_hand in get_tree().get_nodes_in_group("in_hand"):
                c_hand.card_data["cost"] += amt
        elif effect == "all_to_hand":
            if card is not Dictionary and grid != null and grid.contain == card:
                await grid_to_hand(grid)
            elif card is Dictionary:
                var flag = true
                for c in graveyard:
                    if c == card:
                        graveyard.erase(card)
                        await current_battle.instantiate_card(card, Vector2(-200, 1080))
                        flag = false
                        break
                if flag:
                    for c in deck_to_draw:
                        if c == card:
                            await current_battle.draw_from_deck(card)
                            break
        elif effect == "refresh_deck":
            var possible_ids = {}
            for c in constant_deck: possible_ids.merge({c["id"]: c})
            for dead_c in graveyard.duplicate():
                if dead_c["id"] in possible_ids and dead_c["id"] != -1:
                    graveyard.erase(dead_c)
                    deck_to_draw.append(possible_ids[dead_c["id"]].duplicate(true))
        elif effect == "new_turn":
            await current_battle.start_turn(false)
        elif effect == "full_copy" and my_only:
            await current_battle.instantiate_card(card.card_data.duplicate(true), card.global_position)
        elif effect == "draw":
            await current_battle.draw_from_deck()
        elif effect == "rnd_attack" and grid != null and card is not Dictionary:
            var target_grid
            var enemies_side = "my_grids"
            if my_only: enemies_side = "your_grids"
            var enemies = get_tree().get_nodes_in_group(enemies_side).map(func(g): return g.contain).filter(func(c): return c != null)
            if !enemies.is_empty(): target_grid = enemies[Randi() % enemies.size()]
            await basic_attack(grid, card, target_grid)
        elif effect == "gy_to_hand_not_in_deck":
            var candidates = graveyard.duplicate()
            var in_deck_ids: Array = []
            for c in constant_deck:
                in_deck_ids.append(c["id"])
            for candidate in candidates:
                if graveyard.has(candidate) and candidate["id"] == -1 or candidate["id"] not in in_deck_ids:
                    graveyard.erase(candidate)
                    if candidate["type"] == "mob" and candidate["hp"] <= 0: candidate["hp"] = 1
                    await current_battle.instantiate(candidate, Vector2(-200, 1080))
        elif effect == "vampire" and card != null:
            var card_data = card
            if card is Button: card_data = card.card_data
            card_data["hp"] += card_data["atk"]
        elif effect == "next_pick_fusion":
            next_pick_fusion = true
        elif effect == "gain_food_atk_hp":
            if card is Dictionary: return
            var card_data = card.card_data
            if target_g != null and target_g.contain != null:
                card_data["atk"] += target_g.contain.card_data["atk"]
                card_data["hp"] += target_g.contain.card_data["hp"]
                card.label_tween("atk")
                card.label_tween("hp")
        elif effect == "self_protect":
            await append_protect(grid, card)
        elif effect == "self_lose_protect":
            var card_data = card
            if card is not Dictionary: card_data = card.card_data
            card_data["constant"].erase("protect")
            if card is not Dictionary: card.pop("-" + tr("PROTECT"))
            await do_effect(grid, card, "lose_protect")
        elif effect == "allies_random_protect":
            var side = "my_grids"
            if card is Button and !my_only: side = "your_grids"
            for g in get_tree().get_nodes_in_group(side):
                if await append_protect(g, g.contain): break
        elif effect.match ("add_*"):
            var add_name = effect.substr(4)
            var possible_cards = card_prototypes.values().filter(func(data): return data["name"].match (add_name))
            if !possible_cards.is_empty():
                var actual_add = possible_cards[Randi() % possible_cards.size()].duplicate(true)
                if card is Dictionary: await current_battle.instantiate_card(actual_add)
                else: await current_battle.instantiate_card(actual_add, card.global_position)
        elif effect == "grid_to_hand" and grid != null and my_only:
            await grid_to_hand(grid)
        elif effect.match ("self_damage_*") and card != null:
            await damage(effect.substr(12).to_int(), card, grid, card, grid)
        elif effect.match ("all_damage_*") and card != null:
            var d = effect.substr(11).to_int()
            for g in get_tree().get_nodes_in_group("your_grids"): await damage(d, g.contain, g, card, grid)
            for g in get_tree().get_nodes_in_group("my_grids"): await damage(d, g.contain, g, card, grid)
        elif effect.match ("all_enemies_damage_*"):
            var d = effect.substr(19).to_int()
            var side = "your_grids"
            if card is Button and !my_only: side = "my_grids"
            for g in get_tree().get_nodes_in_group(side): await damage(d, g.contain, g, card, grid)
        elif effect.match ("enemy_rnd_damage_*"):
            var d = effect.substr(17).to_int()
            var side = "your_grids"
            if card != null and card is Button and !my_only: side = "my_grids"
            var arr = get_tree().get_nodes_in_group(side).filter(func(g): return g.contain != null and g.contain.card_data["hp"] >= 0)
            if !arr.is_empty():
                var g = arr[Randi() % arr.size()]
                await damage(d, g.contain, g, card, grid)
        elif effect.match ("front_damage_*"):
            var d = effect.substr(13).to_int()
            if grid != null: await damage(d, grid.grid_in_front.contain, grid.grid_in_front, card, grid)
        elif effect.match ("hp_*") and card != null:
            if (card is Dictionary and card["type"] == "mob") or card.card_data["type"] == "mob":
                if card is Dictionary: card["hp"] += effect.substr(3).to_int()
                else:
                    card.card_data["hp"] += effect.substr(3).to_int()
                    card.label_tween("hp")

        elif effect.match ("atk_*"):
            if card is Dictionary:
                card["atk"] += effect.substr(4).to_int()
                if card["atk"] < 0: card["atk"] = 0
            else:
                card.card_data["atk"] += effect.substr(4).to_int()
                card.label_tween("atk")
                if card.card_data["atk"] < 0: card.card_data["atk"] = 0
        elif effect.match ("all_atk_*"):
            for g in get_tree().get_nodes_in_group("grids"):
                if g.contain != null:
                    g.contain.card_data["atk"] += effect.substr(4).to_int()
                    g.contain.label_tween("atk")
                    if g.contain.card_data["atk"] < 0: g.contain.card_data["atk"] = 0
        elif effect == "tune_atk_hp":
            var card_data = card
            if card is not Dictionary: card_data = card.card_data
            if card_data["hp"] > card_data["atk"]:
                card_data["atk"] = card_data["hp"]
                if card is not Dictionary: card.label_tween("atk")
            elif card_data["hp"] < card_data["atk"]:
                card_data["hp"] = card_data["atk"]
                if card is not Dictionary: card.label_tween("hp")
        elif effect.match ("both_atk_hp_*"):
            var amount = effect.substr(12).to_int()
            if card is Dictionary:
                card["atk"] += amount
                if card["atk"] < 0: card["atk"] = 0
                card["hp"] += amount
            else:
                card.card_data["atk"] += amount
                if card.card_data["atk"] < 0: card.card_data["atk"] = 0
                card.label_tween("atk")
                card.card_data["hp"] += amount
                card.label_tween("hp")
        elif effect.match ("cost_*"):
            var card_data = card
            if card is not Dictionary:
                card_data = card.card_data
                card.label_tween("cost")
            card_data["cost"] += effect.substr(5).to_int()

        elif effect.match ("turn_atk_*"):
            var card_data = card
            if card is not Dictionary:
                card_data = card.card_data
                card.label_tween("atk")
            card_data["atk"] = effect.substr(9).to_int()
        elif effect.match ("allies_atk_hp_*"):
            var buff = effect.substr(14).to_int()
            var side = "my_grids"
            if card != null and card is Button and !my_only: side = "your_grids"
            for g in get_tree().get_nodes_in_group(side): if g.contain != null:
                g.contain.card_data["atk"] += buff
                g.contain.card_data["hp"] += buff
                g.contain.label_tween("atk")
                g.contain.label_tween("hp")
        elif effect == "random":
            var rand = random_card_data()
            if card is Dictionary: await current_battle.instantiate_card(rand)
            else: await current_battle.instantiate_card(rand, card.global_position)
        elif effect == "deck_add_random":
            deck_to_draw.append(random_card_data())
        elif effect == "card_reward":
            pick_chances += 1
        elif effect == "attack" and grid != null:
            await do_effect(grid, card, "declare_attack")
        elif effect == "const_atk_or_hp+":
            var card_data = card
            if card is Button: card_data = card.card_data
            var atk_or_hp = ["atk", "hp"][Randi() % 2]
            for data in constant_deck:
                if (data["id"] != -1 and data["id"] == card_data["id"]):
                    data[atk_or_hp] += 1
                    break
            card_data[atk_or_hp] += 1
        elif effect == "permanent_atk+" and card != null:
            var card_data = card
            if card is Button: card_data = card.card_data
            for data in constant_deck:
                if (data["id"] != -1 and data["id"] == card_data["id"]):
                    data["atk"] += 1
            card_data["atk"] += 1
        elif effect == "permanent_hp+" and card != null:
            var card_data = card
            if card is Button: card_data = card.card_data
            for data in constant_deck:
                if (data["id"] != -1 and data["id"] == card_data["id"]):
                    data["hp"] += 1
            card_data["hp"] += 1
        elif effect.match ("spell_atk_*") and grid != null and grid.contain != null:
            grid.contain.card_data["atk"] += effect.substr(10).to_int()
            grid.contain.label_tween("atk")
            if grid.contain.card_data["atk"] < 0: grid.contain.card_data["atk"] = 0
        elif effect == "healer" and card != null:
            var card_data = card
            if card is Button: card_data = card.card_data
            var grids = get_tree().get_nodes_in_group("your_grids")
            if my_only: grids = get_tree().get_nodes_in_group("my_grids")
            for each_grid in grids:
                if each_grid.contain != null:
                    each_grid.contain.label_tween("hp")
                    each_grid.contain.card_data["hp"] += card_data["atk"]
        elif effect == "draw_all_cost":
            var unique_costs = []
            var found_unique_cost = true
            while found_unique_cost:
                found_unique_cost = false
                var candidates = []
                for data in deck_to_draw:
                    if data["cost"] not in unique_costs:
                        candidates.append(data)
                        found_unique_cost = true
                if !candidates.is_empty():
                    var final_draw = candidates[Randi() % candidates.size()]
                    unique_costs.append(final_draw["cost"])
                    await current_battle.draw_from_deck(final_draw)

        elif effect.match ("draw_all_*"):
            var cards = deck_to_draw.filter(func(i): return i.get("name").match (effect.substr(9)))
            for i in cards:
                if deck_to_draw.has(i): await current_battle.draw_from_deck(i)
        elif effect.match ("draw_*"):
            await current_battle.draw_from_deck(null, effect.substr(5))
        elif effect.match ("deck_add_*"):
            var add_name = effect.substr(9)
            var possible_cards = card_prototypes.values().filter(func(data): return data["name"].match (add_name))
            if !possible_cards.is_empty():
                var actual_add = possible_cards[Randi() % possible_cards.size()].duplicate(true)
                deck_to_draw.append(actual_add)
        elif effect.match ("constant_deck_add_*"):
            var add_name = effect.substr(18)
            var possible_cards = card_prototypes.values().filter(func(data): return data["name"].match (add_name))
            var actual_add = possible_cards[Randi() % possible_cards.size()].duplicate(true)
            add_to_constant_deck(actual_add)
            actual_add.merge({"id": id - 1})
            deck_to_draw.append(actual_add)
        elif effect.match ("revive_all_*"):
            var cards = graveyard.filter(func(i): return i.get("name").match (effect.substr(11)))
            for i in cards:
                graveyard.erase(i)
                await current_battle.instantiate_card(i, Vector2(-200, 1080))
        elif effect.match ("revive_*"):
            var cards = graveyard.filter(func(i): return i.get("name").match (effect.substr(7)))
            if !cards.is_empty():
                var removed = cards[Randi() % cards.size()]
                graveyard.erase(removed)
                await current_battle.instantiate_card(removed, Vector2(-200, 1080))
        elif effect == "freeze_landed_enemy" and target_g != null:
            await target_g.freeze()
        elif effect == "freeze" and grid != null:
            await grid.freeze()
        elif effect == "unfreeze" and grid != null:
            await grid.unfreeze()
        elif effect == "freeze_in_front" and grid != null:
            await grid.grid_in_front.freeze()
        elif effect == "freeze_random_enemy":
            var side = "your_grids"
            if card is Button and !my_only: side = "my_grids"
            var arr = get_tree().get_nodes_in_group(side).filter(func(g): return g.contain != null and !g.frozen)
            if !arr.is_empty(): await arr[Randi() % arr.size()].freeze()
        elif effect == "freeze_random_creature":
            var arr = get_tree().get_nodes_in_group("grids").filter(func(g): return g.contain != null and !g.frozen)
            if !arr.is_empty(): await arr[Randi() % arr.size()].freeze()
        elif effect == "num_of_freeze_draw":
            var frozen_grids = get_tree().get_nodes_in_group("grids").filter(func(g): return g.frozen)
            for i in range(frozen_grids.size()): await current_battle.draw_from_deck()
        elif effect == "all_freeze":
            for g in get_tree().get_nodes_in_group("your_grids"): await g.freeze()
            for g in get_tree().get_nodes_in_group("my_grids"): await g.freeze()
        elif effect == "enemies_freeze":
            var side = "your_grids"
            if card is Button and !my_only: side = "my_grids"
            for g in get_tree().get_nodes_in_group(side):
                await g.freeze()
        elif effect == "draw=atk" and card != null:
            var card_data = card
            if card is Button: card_data = card.card_data
            for i in range(card_data["atk"]): await current_battle.draw_from_deck()
        elif effect == "itself_draw":
            if deck_to_draw.has(card):

                card = await current_battle.draw_from_deck(card)
        elif effect.match ("LP*") and card != null:
            await gain_LP(effect.substr(2).to_int())
        elif effect == "spell_burn" and card != null and card is Button and !card.is_dying:
            await burn_card_in_hand(card)
            current_battle.back_to_hand()
        elif effect == "not_spell_burn" and card != null:
            if grid != null and card is Button: await get_killed(grid, card)
            elif grid == null and card is Button: await burn_card_in_hand(card)
            elif card is Dictionary and deck_to_draw.has(card): await burn_card_in_deck(card)
        elif effect == "fusion_not_consume":
            var card_data = card
            if card is not Dictionary: card_data = card.card_data
            var name_arr: Array = card_data["name"].split("/", false)
            name_arr.erase("chimera2")
            for nam in name_arr:
                if card_prototypes.has(nam) and card_prototypes[nam]["type"] == "mob":
                    var side = "your_grids"
                    if my_only: side = "my_grids"
                    var rand_grid = grid
                    if grid == null or grid.contain != null: rand_grid = random_empty_grids(side)
                    await current_battle.set_grid_with(rand_grid, card_prototypes[nam].duplicate(true))
        elif effect.match ("summon_*"):
            var summon_name = effect.substr(7)
            var possible_cards
            if summon_name == "*": possible_cards = [random_card_data(null, "mob")]
            elif summon_name.match ("random_*"):
                var pool
                var c = summon_name.substr(7)
                if !my_only:
                    pool = enemy_pool
                    pool = pool.filter(func(i): return card_prototypes.get(i).get("cost") == c.to_int())
                    possible_cards = [card_prototypes.get(pool[Randi() % pool.size()])]
                else: possible_cards = [random_card_data(c, "mob")]
            else:
                possible_cards = card_prototypes.values().filter(func(data): return data["name"].match (summon_name) and data["type"] == "mob")
            var actual_add = possible_cards[Randi() % possible_cards.size()].duplicate(true)
            if grid != null and grid.contain == null:
                await current_battle.set_grid_with(grid, actual_add)
            else:
                var side = "your_grids"
                if my_only: side = "my_grids"
                var rand_grid = random_empty_grids(side)
                await current_battle.set_grid_with(rand_grid, actual_add)
        elif effect == "itself_revive_to_field":
            var card_data = card
            if card is Button: card_data = card.card_data
            var rand_grid = random_empty_grids("my_grids")
            if rand_grid != null and card_data["type"] == "mob" and graveyard.has(card_data):
                graveyard.erase(card_data)
                if card_data["hp"] <= 0: card_data["hp"] = 1
                if grid == null or grid.contain != null: grid = rand_grid
                var new_self = await current_battle.set_grid_with(grid, card_data)
                card = new_self
        elif effect == "itself_revive_to_hand" and card is Dictionary and graveyard.has(card):
            graveyard.erase(card)
            if card["type"] == "mob" and card["hp"] <= 0: card["hp"] = 1
            await current_battle.instantiate_card(card, Vector2(-200, 1080))

        elif effect == "spell_copy_forever" and target_g != null and target_g.contain != null:
            var data_to_copy = target_g.contain.card_data
            var itself = constant_deck.filter(func(c): return data_to_copy["id"] == c["id"])
            if !itself.is_empty():
                var copy = itself[0].duplicate(true)
                add_to_constant_deck(copy)
                copy.merge({"id": id - 1})
                deck_to_draw.append(copy)
            elif card_prototypes.has(data_to_copy["name"]):
                var copy = card_prototypes.get(data_to_copy["name"]).duplicate(true)
                add_to_constant_deck(copy)
                copy.merge({"id": id - 1})
                deck_to_draw.append(copy)
            else:
                var splited: Array = data_to_copy["name"].split("/", false)
                var datas_to_combine = []
                for n in splited:
                    if card_prototypes.has(n): datas_to_combine.append(card_prototypes.get(n))
                var copy = combine(datas_to_combine)
                add_to_constant_deck(copy)
                copy.merge({"id": id - 1})
                deck_to_draw.append(copy)
        elif effect.match ("gy_to_field_*"):
            var cards = graveyard.filter(func(i): return i.get("name").match (effect.substr(12)))
            cards = cards.filter(func(i): return i.get("type") == "mob")
            if !cards.is_empty():
                var removed = cards[Randi() % cards.size()]
                graveyard.erase(removed)
                if removed["hp"] <= 0: removed["hp"] = 1
                if grid == null or grid.contain != null or (grid.contain != null and !grid.contain.is_dying):
                    var rand_empty_grid = random_empty_grids("my_grids")
                    await current_battle.set_grid_with(rand_empty_grid, removed)
                else:
                    await current_battle.set_grid_with(grid, removed)
        elif effect.match ("boost_*") and card != null:
            var card_data = card
            if card is Button: card_data = card.card_data
            card_data["spell_boost"] += effect.substr(6).to_int()
        elif effect == "burn_rightmost":
            var cards = get_tree().get_nodes_in_group("in_hand")
            cards.sort_custom(func(a, b): return a.get_index() > b.get_index())
            if !cards.is_empty(): await burn_card_in_hand(cards[0])
        elif effect == "itself_revive_to_deck" and card is Dictionary and graveyard.has(card):
            graveyard.erase(card)
            if card["type"] == "mob" and card["hp"] <= 0: card["hp"] = 1
            deck_to_draw.append(card)
        elif effect == "move_right" and (card is Button and grid != null
            and grid.grid_right != null and grid.grid_right.contain == null):
            card.play_unfreeze()
            var t = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
            t.tween_property(card, "position", grid.grid_right.global_position, 0.2)
            await t.finished
            if grid.frozen: grid.grid_right.frozen = true
            grid.frozen = false
            grid.contain = null
            grid.grid_right.contain = card
            grid = grid.grid_right
            await grid.unfreeze()
        elif effect == "ban_turn":
            current_battle.ban_turn()
        elif effect == "consumable":
            var card_data = card
            if not card is Dictionary: card_data = card.card_data
            var this_c = constant_deck.filter(func(i): return i["id"] == card_data["id"])
            if !this_c.is_empty(): constant_deck.erase(this_c[0])
        elif effect.match ("kill_all_*"):
            var string = effect.substr(9)
            for g in get_tree().get_nodes_in_group("grids"):
                if g.contain != null and g.contain.card_data["name"].match (string):
                    await get_killed(g, g.contain)
        elif effect.match ("kill_one_*"):
            var string = effect.substr(9)
            for g in get_tree().get_nodes_in_group("grids"):
                if g.contain != null and g.contain.card_data["name"].match (string):
                    await get_killed(g, g.contain)
                    break
        elif effect == "delete_burn_rightmost":
            var cards = get_tree().get_nodes_in_group("in_hand")
            cards.sort_custom(func(a, b): return a.get_index() > b.get_index())
            constant_deck.erase(cards[0].card_data)
            await burn_card_in_hand(cards[0])
        elif effect.match ("allies_atk_*"):
            for g in get_tree().get_nodes_in_group(allies_side):
                if g.contain != null: g.contain.card_data["atk"] += effect.substr(11).to_int()
        elif effect.match ("random_hand_cost_*"):
            var positive_cost_cards = []
            var hands = get_tree().get_nodes_in_group("in_hand")
            for hand in hands:
                if hand is Dictionary:
                    if hand["cost"] > 0:
                        positive_cost_cards.append(hand)
                else:
                    if card.card_data["cost"] > 0:
                        positive_cost_cards.append(hand)

            var hand_to_change
            var change_amount = effect.substr(17).to_int()
            if positive_cost_cards.size() != 0:
                hand_to_change = positive_cost_cards[Randi() % positive_cost_cards.size()]
            else:
                hand_to_change = hands[Randi() % hands.size()]

            if hand_to_change is Dictionary:
                hand_to_change["cost"] += change_amount
            else:
                hand_to_change.card_data["cost"] += change_amount
        resolving -= 1
    chain_num = 0
    if resolving == 0: all_resolved.emit()
    if hidden_effect: current_battle.stop_showing()
    current_battle.could_die()

func basic_attack(grid: Control, attacker, target_grid):
    if target_grid == null or grid.frozen or attacker == null or attacker.is_dying:
        return
    if target_grid.contain == null and target_grid.is_in_group("my_grids") and has_relic("WOODCUBE") and current_battle.turn == 2:
        shine_relic("WOODCUBE")
        return
    resolving += 1
    attacker.glow()
    if target_grid.contain == null and target_grid.is_in_group("my_grids") and (
    "constant" not in attacker.card_data or "cannot_hit_player" not in attacker.card_data["constant"]):
        var temp2 = grid.global_position

        var damage_is_guarded = false
        for g in get_tree().get_nodes_in_group("grids"):
            if g.contain != null and "constant" in g.contain.card_data and "guard" in g.contain.card_data["constant"]:
                damage_is_guarded = true
                var target = g.contain
                await current_battle.attack_tween_go(grid, target.global_position - (target.global_position - attacker.global_position) / 2)
                current_battle.attack_tween_back(grid, temp2)
                await damage(attacker.card_data["atk"], g.contain, g, attacker, grid)
                break
        if !damage_is_guarded:
            await current_battle.attack_tween_go(grid, Vector2(grid.global_position.x, current_battle.size.y * 0.55))
            await gain_LP( - attacker.card_data["atk"])

            if has_relic("PAPRIKA"):
                shine_relic("PAPRIKA")
                await current_battle.instantiate_card(random_card_data())
            if has_relic("BROCOLI"):
                var gs = []
                for any_g in get_tree().get_nodes_in_group("your_grids"):
                    if any_g.contain != null and any_g.contain.card_data["atk"] >= 1:
                        gs.append(any_g)
                if !gs.is_empty():
                    shine_relic("BROCOLI")
                    var g = gs[Randi() % gs.size()]
                    g.contain.card_data["atk"] -= 1
                    if g.contain.card_data["atk"] < 0: g.contain.card_data["atk"] = 0

            shake_strength += 30

            current_battle.could_die()
            if grid.contain == attacker: await current_battle.attack_tween_back(grid, temp2)

        for g in get_tree().get_nodes_in_group("grids"): await do_effect(g, g.contain, "any_attack")
        for card_in_hand in get_tree().get_nodes_in_group("in_hand"):
            if card_in_hand in get_tree().get_nodes_in_group("in_hand"):
                await do_effect(null, card_in_hand, "in_hand_any_attack")

        await do_effect(grid, attacker, "after_attack")
        for card_in_hand in get_tree().get_nodes_in_group("in_hand"):
            if card_in_hand in get_tree().get_nodes_in_group("in_hand"):
                await do_effect(null, card_in_hand, "in_hand_after_attack")
    elif target_grid.contain != null:
        var target = target_grid.contain
        var temp2 = grid.global_position
        await current_battle.attack_tween_go(grid, target.global_position - (target.global_position - attacker.global_position) / 2)
        current_battle.attack_tween_back(grid, temp2)
        await damage(attacker.card_data["atk"], target, target_grid, attacker, grid)

        for g in get_tree().get_nodes_in_group("grids"): await do_effect(g, g.contain, "any_attack")
        for card_in_hand in get_tree().get_nodes_in_group("in_hand"):
            if card_in_hand in get_tree().get_nodes_in_group("in_hand"):
                await do_effect(null, card_in_hand, "in_hand_any_attack")
        await do_effect(grid, attacker, "after_attack")
        for card_in_hand in get_tree().get_nodes_in_group("in_hand"):
            if card_in_hand in get_tree().get_nodes_in_group("in_hand"):
                await do_effect(null, card_in_hand, "in_hand_after_attack")
    if attacker != null: attacker.unglow()
    resolving -= 1
    current_battle.could_die()

func count_spell_boost():
    var boost = 0
    for g in get_tree().get_nodes_in_group("grids"):
        if g.contain != null: boost += g.contain.card_data["spell_boost"]
    return boost

func damage(damage_amount, target, target_grid, from, from_grid):
    if target == null: return
    if (from is Dictionary and from["type"] == "spell") or (from is Button and from.card_data["type"] == "spell"):
        damage_amount += count_spell_boost()
    if from is Dictionary and from["type"] == "spell": damage_amount += from["spell_boost"]

    if damage_amount < 0: damage_amount = 0
    if target.card_data.has("constant") and target.card_data["constant"].has("protect"):
        damage_amount = 0
        target.card_data["constant"].erase("protect")
        target.pop("-" + tr("PROTECT"))
        await do_effect(target_grid, target, "lose_protect")
    target.card_data["hp"] -= damage_amount
    if target.card_data.has("constant") and target.card_data["constant"].has("meta_hp"):
        meta_progress.chimera_hp = target.card_data["hp"]
        card_prototypes["chimera"]["hp"] = meta_progress.chimera_hp
    for rep in range(damage_amount):
        for c in get_tree().get_nodes_in_group("in_hand"):
            if c in get_tree().get_nodes_in_group("in_hand"):
                await do_effect(null, c, "per_any_damage")
    if target.card_data["hp"] <= 0:
        target.hit(damage_amount)
        if (get_tree().get_nodes_in_group("your_grids").filter(func(g): return g.contain != null).size() == 1 and 
            !get_tree().get_nodes_in_group("your_grids").filter(func(g): return g.contain == target).is_empty()):
            toplayerui.wave(target.global_position + target.size / 2)
        Engine.time_scale = Engine.time_scale / 32.0
        await get_tree().create_timer(0.28, true, false, true).timeout
        Engine.time_scale = Engine.time_scale * 32.0

    else:
        await target.hit(damage_amount)

    if target != null and target.card_data["hp"] <= 0:
        await do_effect(target_grid, target, "fatal_hurt")
        if target != null and target.card_data["hp"] <= 0:
            await do_effect(from_grid, from, "get_kill", target_grid)
        if target != null and target.card_data["hp"] <= 0:
            await get_killed(target_grid, target)
    else:
        await do_effect(target_grid, target, "hurt")


func get_killed(grid, card):
    if card == null or card.is_dying: return
    if "constant" in card.card_data and "WET" in card.card_data["constant"]:
        card.card_data["constant"].erase("WET")
        card.pop("-" + tr("WET"))
        if card.card_data["hp"] <= 0: card.card_data["hp"] = 1
        return
    resolving += 1
    card.is_dying = true
    if grid.contain == card: grid.contain = null
    if grid.is_in_group("my_grids"): graveyard_append(card)
    else: current_map.map_info["enemies_killed"] += 1
    card.play_burn(false, Tween.EASE_OUT, Tween.TRANS_QUART, 0.55, true)
    await get_tree().create_timer(0.1).timeout


    if has_relic("SCISSOR") and grid in get_tree().get_nodes_in_group("your_grids"):
        var g = random_nonempty_grids("my_grids")
        if g:
            shine_relic("SCISSOR")
            g.contain.card_data["atk"] += 2
            g.contain.label_tween("atk")
    if has_relic("SHENZHEN") and grid in get_tree().get_nodes_in_group("my_grids"):
        var g = random_nonempty_grids("my_grids")
        if g:
            shine_relic("SHENZHEN")
            var tg = g.contain
            tg.card_data["atk"] += 1
            tg.card_data["hp"] += 1
            tg.label_tween("atk")
            tg.label_tween("hp")
    await grid.unfreeze()
    await do_effect(grid, card, "after_death")
    await trigger_on_death_effects()
    resolving -= 1

    no_await_kill(card)

func trigger_on_death_effects():
    for g in get_tree().get_nodes_in_group("grids"):
        await do_effect(g, g.contain, "any_death")
    for card_in_hand in get_tree().get_nodes_in_group("in_hand"):
        if card_in_hand in get_tree().get_nodes_in_group("in_hand"):
            await do_effect(null, card_in_hand, "in_hand_any_death")

func no_await_kill(card):
    await get_tree().create_timer(1.21).timeout
    if card != null and card.card_data["type"] == "mob": all_resolved.connect(card.back_to_pool)

func clear_card_in_hand(card: Button):
    if card == null: return
    card.remove_from_group("in_hand")
    card.movable = false
    card.visible = false
    if card != null: all_resolved.connect(card.back_to_pool)

func burn_card_in_hand(card: Button):
    if card == null or card.is_dying: return
    if "constant" in card.card_data and "WET" in card.card_data["constant"]:
        card.card_data["constant"].erase("WET")
        card.pop("-" + tr("WET"))
        return

    card.remove_from_group("in_hand")
    card.movable = false
    card.is_dying = true
    current_battle.back_to_hand()
    graveyard_append(card)
    card.play_burn(false, Tween.EASE_OUT, Tween.TRANS_QUART, 0.5)
    if card.card_data["type"] == "spell": await do_effect(null, card.card_data, "be_burnt")
    elif card.card_data["type"] == "mob":
        await do_effect(null, card.card_data, "after_death")
        await trigger_on_death_effects()
    burn_card_in_hand_helper(card)
    await get_tree().create_timer(0.2).timeout
func burn_card_in_hand_helper(card: Button):
    await get_tree().create_timer(1.2).timeout
    if card != null: all_resolved.connect(card.back_to_pool)

func burn_card_in_deck(data: Dictionary):
    if "constant" in data and "WET" in data["constant"]:
        data["constant"].erase("WET")
        return
    if data in deck_to_draw:
        deck_to_draw.erase(data)
        graveyard_append(data)
        if data["type"] == "spell":
            await do_effect(null, data, "be_burnt")
        elif data["type"] == "mob":
            await do_effect(null, data, "after_death")
            await trigger_on_death_effects()

func save_loot_card():
    var save_loot_cards = FileAccess.open("user://savelootcards.save", FileAccess.WRITE)
    for card in loot_cards:
        var json_string = JSON.stringify(card, "", false)
        save_loot_cards.store_line(json_string)

func save_meta_progress():
    var save_meta = FileAccess.open("user://metaprogress.save", FileAccess.WRITE)
    save_meta.store_line(JSON.stringify(meta_progress, "", false, true))

func save():
    save_meta_progress()

    if !meta_progress.tutorial_cleared or Global.story_mode: return
    current_map.save_map()
    var save_of = "infinity_"
    if story_mode: save_of = "story_"
    new_game = false
    var save_state = FileAccess.open("user://" + save_of + "savestate.save", FileAccess.WRITE)
    var state = {
        "rng_seed": str(rng.get_seed()), 
        "rng_state": str(rng.get_state()), 
        "new_game": false, 
        "streaks_for_2xHP": streaks_for_2xHP, 
        "streaks_for_1more_cost": streaks_for_1more_cost, 
        "LP": LP, 
        "max_LP": max_LP, 
        "relics": relics, 
        "relic_progress": relic_progress, 
        "streak": streak, 
        "pick_chances": pick_chances, 
        "draw_each_turn": draw_each_turn, 
        "draw_start": draw_start, 
        "win_reward": win_reward, 
        "next_pick_fusion": next_pick_fusion, 
        "next_pick_shiny": next_pick_shiny, 
        "id": id, 
        "rainbow_cards": rainbow_cards, 
        }
    save_state.store_line(JSON.stringify(state, "", false, true))
    var save_game = FileAccess.open("user://" + save_of + "savegame.save", FileAccess.WRITE)
    for card in constant_deck:
        var json_string = JSON.stringify(card, "", false)
        save_game.store_line(json_string)

func save_settings():
    var saveset = FileAccess.open("user://savesettings.save", FileAccess.WRITE)
    saveset.store_line(JSON.stringify(settings))

func load_loot_card():
    if FileAccess.file_exists("user://savelootcards.save"):
        var lootcards = FileAccess.open("user://savelootcards.save", FileAccess.READ)
        loot_cards.clear()
        while lootcards.get_position() < lootcards.get_length():
            var json_string = lootcards.get_line()
            var json = JSON.new()
            var parse_result = json.parse(json_string)
            if not parse_result == OK:
                print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
                continue
            var loot_data = json.get_data()
            loot_cards.append(parse_loaded_dict_to_data(loot_data))

func load_game():
    var save_of = "infinity_"
    if story_mode: save_of = "story_"
    if FileAccess.file_exists("user://" + save_of + "savestate.save"):
        var save_state = FileAccess.open("user://" + save_of + "savestate.save", FileAccess.READ)
        var json = JSON.new()
        var parse_result = json.parse(save_state.get_line(), )
        if not parse_result == OK:
            print("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())
        var properties = json.get_data()
        if properties is Dictionary:
            for property in properties.keys():
                set(property, properties[property])
        rng_seed = rng_seed.to_int()
        rng_state = rng_state.to_int()
        rng.set_seed(rng_seed)
        rng.set_state(rng_state)
        for rainbow_c in rainbow_cards:
            card_prototypes[rainbow_c] = rainbow_dict[rainbow_c].duplicate(true)
    load_loot_card()
    if FileAccess.file_exists("user://" + save_of + "savegame.save"):
        var save_game = FileAccess.open("user://" + save_of + "savegame.save", FileAccess.READ)
        while save_game.get_position() < save_game.get_length():
            var json_string = save_game.get_line()

            var json = JSON.new()

            var parse_result = json.parse(json_string)
            if not parse_result == OK:
                print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
                continue

            var card_data = json.get_data()
            constant_deck.append(parse_loaded_dict_to_data(card_data))
    toplayerui.update_relicflag()

func load_meta_progress():
    if FileAccess.file_exists("user://metaprogress.save"):
        var to_load = FileAccess.open("user://metaprogress.save", FileAccess.READ)
        var json = JSON.new()
        json.parse(to_load.get_line())
        var properties = json.get_data()
        if properties is Dictionary:
            for item in properties.keys():
                meta_progress[item] = properties[item]
    card_prototypes["chimera"]["hp"] = meta_progress.chimera_hp
    for n in meta_progress["unlocked_basic_pick_pool"]:
        if n not in card_prototypes: meta_progress["unlocked_basic_pick_pool"].erase(n)
        if n in best_unlock_order: meta_progress["unlocked_basic_pick_pool"].erase(n)
    for n in meta_progress["unlocked_best_pick_pool"]:
        if n not in card_prototypes: meta_progress["unlocked_best_pick_pool"].erase(n)
        if n not in best_unlock_order: meta_progress["unlocked_best_pick_pool"].erase(n)

func burn_spell(card):
    if card is Dictionary or card.is_dying: return
    card.spell_used.emit()
    if "constant" in card.card_data and "WET" in card.card_data["constant"]:
        card.is_casted = true
        return
    card.movable = false
    card.play_burn(false, Tween.EASE_OUT, Tween.TRANS_QUAD, 0.5, true)
    card.is_casted = true
    card.is_dying = true
    card.remove_from_group("in_hand")

func combine(c_datas: Array):
    if c_datas.size() == 1: return c_datas[0]
    var base = {"name": "", "type": "mob", "atk": 0, "hp": 0, "cost": 0, "spell_boost": 0}
    for data in c_datas:

        data.merge({"spell_boost": 0})
        if base["name"] != "" and data["type"] == "mob" and base["type"] == "spell": base = enchant(data, base["name"], true)

        elif base["name"] != "" and data["type"] == "spell" and base["type"] == "mob": base = enchant(base, data["name"], false)
        else:
            base["type"] = data["type"]
            base["name"] += data["name"] + "/"
            base["atk"] += data["atk"]
            base["hp"] += data["hp"]
            base["cost"] += data["cost"]
            base["spell_boost"] += data["spell_boost"]
            for key in data.keys():
                if data.get(key) is Array:
                    if !base.has(key): base.merge({key: []})
                    if (data.get(key).has("front") and 
                        base.has("declare_attack") and base["declare_attack"].has("front")):
                        base["declare_attack"].erase("front")
                    var effects_to_append = data[key].duplicate(true)

                    if key == "constant" or key == "material":
                        effects_to_append = effects_to_append.filter(func(eff): return !base[key].has(eff))
                    base[key].append_array(effects_to_append)
    return base

func add_eff_in(data, eff, reverse: bool = false):
    if eff is not Dictionary: return
    data = data.duplicate(true)
    eff = eff.duplicate(true)
    eff.erase("id")
    for trig in eff:
        if eff.get(trig) is Array:
            data.get_or_add(trig, [])
            if reverse:
                var effects_to_append = data[trig]
                var tmp = eff.get(trig)
                if trig == "constant" or trig == "material":
                    effects_to_append = effects_to_append.filter(func(new_eff): return !eff[trig].has(new_eff))
                tmp.append_array(effects_to_append)
                data[trig] = tmp
            else:
                var effects_to_append = eff[trig]
                if trig == "constant" or trig == "material":
                    effects_to_append = effects_to_append.filter(func(new_eff): return !data[trig].has(new_eff))
                data.get(trig).append_array(effects_to_append)
        elif eff.get(trig) is int:
            data.get_or_add(trig, 0)
            data[trig] += eff.get(trig)
    return data


func enchant(data, conca_spell, reverse: bool = false):
    var list: Array = conca_spell.split("/", false)
    if reverse: list.reverse()
    for spell_name in list:
        if data["type"] != "mob": continue

        elif spell_name == "antimatter": data = add_eff_in(data, {"cost": -1}, reverse)
        elif spell_name == "attack": data = add_eff_in(data, {"after_attack": ["draw"]}, reverse)
        elif spell_name == "retreat": data = add_eff_in(data, {"end_phase": ["grid_to_hand"]}, reverse)

        elif spell_name == "fatality": data = add_eff_in(data, {"cost": 1, "landed": ["new_turn"]}, reverse)
        elif spell_name == "raid": data = add_eff_in(data, {"cost": 1, "landed": ["summon_fodder", "summon_fodder", "summon_fodder"]}, reverse)
        elif spell_name == "body_sell": data = add_eff_in(data, {"any_death": ["draw"]}, reverse)
        elif spell_name == "undead_army": data = add_eff_in(data, {"landed": ["gy_to_field_*"]}, reverse)
        elif spell_name == "fire_Cremation": data = add_eff_in(data, {"after_death": ["add_fire_ball"]}, reverse)
        elif spell_name == "Truce": data = add_eff_in(data, {"landed": ["all_atk_-3"]}, reverse)
        elif spell_name == "fire_Gate": data = add_eff_in(data, {"cost": 1, "after_death": ["summon_*fire*"]}, reverse)
        elif spell_name == "snowball": data = add_eff_in(data, {"landed": ["add_snowball"]}, reverse)
        elif spell_name == "ice_coin": data = add_eff_in(data, {"any_freezed": ["draw"]}, reverse)
        elif spell_name == "torture": data = add_eff_in(data, {"landed": ["self_damage_1", "self_damage_1", "self_damage_1", "self_damage_1"]}, reverse)
        elif spell_name == "Letter": data = add_eff_in(data, {"landed": ["draw"]}, reverse)
        elif spell_name == "Gold_Fish": data = add_eff_in(data, {"constant": ["easy_draw"], "enter_hand": ["summon_random_0"]}, reverse)
        elif spell_name == "fire_ball": data = add_eff_in(data, {"landed": ["add_fire_ball"]}, reverse)
        elif spell_name == "winter_swim": data = add_eff_in(data, {"atk": 4, "landed": ["unfreeze"]}, reverse)

        elif spell_name == "bloody_coin": data = add_eff_in(data, {"landed": ["all_damage_3"], "get_kill": ["draw"]}, reverse)
        elif spell_name == "Wise": data = add_eff_in(data, {"cost": 1, "after_death": ["draw_all_cost"]}, reverse)


        elif spell_name == "ice_Curse": data = add_eff_in(data, {"cost": 1, "any_freezed": ["enemy_rnd_damage_4"]}, reverse)
        elif spell_name == "blizzard": data = add_eff_in(data, {"enemy_landed": ["freeze_landed_enemy"]}, reverse)
        elif spell_name == "Rain": data = add_eff_in(data, {"constant": ["WET"]}, reverse)
        elif spell_name == "Stillbirth": data = add_eff_in(data, {"pre_battle": ["not_spell_burn"]}, reverse)



        elif spell_name == "bandage": data = add_eff_in(data, {"end_phase": ["hp_3"]}, reverse)

        elif spell_name == "Fate": data = add_eff_in(data, {"get_kill": ["enemy_rnd_damage_7"]}, reverse)

        elif spell_name == "refire": data = add_eff_in(data, {"deck_to_hand": ["add_refire"]}, reverse)
        elif spell_name == "poke_ball": data = add_eff_in(data, {"get_kill": ["spell_copy_forever"]}, reverse)
        elif spell_name == "Unican": data = add_eff_in(data, {"constant": ["gold"], "pre_battle": ["add_Unican"]}, reverse)
        elif card_prototypes.has(spell_name): data = add_eff_in(data, {"deck_to_hand": ["add_" + spell_name]}, reverse)

        if reverse: data["name"] = "ENCHANTED_" + spell_name + "/" + data["name"]
        else: data["name"] = data["name"] + "/" + "ENCHANTED_" + spell_name
    return data

func generate_loot_card(card_data):
    return card_data.duplicate(true)























func parse_loaded_dict_to_data(data: Dictionary):
    for item in data: if data[item] is not Array and data[item] is not String: data[item] = int(data[item])
    return data

func random_empty_grids(side):
    var arr = get_tree().get_nodes_in_group(side).filter(func(g): return g.contain == null)
    if !arr.is_empty(): return arr[Randi() % arr.size()]
    else: return null

func random_nonempty_grids(side):
    var g = get_tree().get_nodes_in_group(side).filter(func(x): return x.contain != null)
    if !g.is_empty(): return g[Randi() % g.size()]
    else: return false

func add_to_constant_deck(data):
    var c_data = data.duplicate(true)
    c_data.merge({"id": id}, true)
    id += 1
    constant_deck.append(c_data)
    var tmp_card = Global.instantiate_from_pool()
    tmp_card.card_data.merge(data, true)
    toplayerui.add_child(tmp_card)
    toplayerui.move_child(tmp_card, 2)
    await add_card_tween(tmp_card, Vector2(1505.0 + randf() * 30, 100.0 + randf() * 50), Vector2(1520.0, -200.0))
    tmp_card.back_to_pool()

var recipe = {
    "fire_artifact": ["Arson", "*fire*"], 
    "blood_artifact": ["*artifact", "hurt"], 
    "ice_artifact": ["blizzard", "*freeze*"], 

    "ritual": ["get_kill", "grid_to_hand"], 
    "Fate": ["card_reward", "damage_*"], 
    "future_coin": ["*Letter*", "card_reward"], 
    "last_song": ["*to_field*", "*draw*"], 

    "Arson": ["*fire*", "revive_*fire_ball*"], 
    "blizzard": ["*freeze*", "*snowball*"], 
    "old_sheep": ["pre_battle", "itself_draw", "*meat*"], 
    "0》1": ["*01*", "deck_add_01*"], 

    "fire_Curse": ["*fire*", "*random*", "*damage*"], 
    "ice_Curse": ["*freeze*", "*damage*"], 


    "01_ice": ["*01*", "*freeze*"], 
    "01_fire": ["*01*", "*fire*"], 
    "01_blood": ["*01*", "hurt"], 
    "01_earth": ["*01*", "*revive*"], 
    "penguin": ["*freeze*", "*random*"], 
    "torture": ["damage*", "damage*"], 
    "fire_soul": ["*revive*", "*fire_ball*"], 
    "fire_twin": ["*fire_ball*", "*fire_ball*"], 
    "fire_BUG": ["*fire*", "*meat*"], 

    "Sea_Star": ["hurt", "*meat*"], 
    "meat_wall": ["*meat*", "end_phase"], 

}
func craft(datas):
    var result = "poke_ball"
    var arr_of_features = extract_features(datas)
    for key in recipe:
        if !datas.filter(func(d): return d["name"] == key).is_empty(): continue
        var arr_of_matched = []
        arr_of_matched.resize(datas.size())
        arr_of_matched.fill(false)
        var all_match = true
        for need in recipe.get(key):
            var found: bool = false
            for index in range(arr_of_features.size()):
                var local_found = !arr_of_features[index].filter(func(token): return token.match (need)).is_empty()
                found = found or local_found
                arr_of_matched[index] = arr_of_matched[index] or local_found
            all_match = all_match and found
        if all_match and !arr_of_matched.has(false):
            result = key
            break
    return card_prototypes.get(result).duplicate(true)

var swap_pair = {
    "attack": "retreat", 
    "ice_Curse": "fire_Curse", 
    "fire_artifact": "ice_artifact", 
    "Letter": "body_sell", 
    "snowball": "fire_ball", 
    "Ostrich": "Bird", 
    "fire_BUG": "Igloo", 
    "torture": "winter_swim", 
    "01_fire": "01_ice", 
    "01_earth": "01_blood", 
    "fire_bird": "ice_golem", 
    "Demon": "penguin", 
    "nova_magic": "bloody_coin", 
    "Fate": "future_coin", 
    "meat_wall": "chef", 
    "coward": "berserk", 
    "campfire": "ice_Ground", 
    "fire_twin": "snow_monster", 
    "wolf": "dancer", 
    "goat": "hunter", 
    "Zombie": "stone_army", 
    "present": "pinata", 
    "Symbiont": "mushroom", 
    "fairy": "spirit", 
    "Truce": "fire_Cremation", 

    "nest": "Sea_Star", 
    "fire_soul": "snowman", 
    "Wise": "Emerge", 
    "raid": "fatality", 
    "Cell": "Magic_spring", 
    "Abyss": "undead_army", 
    "walking_coin": "Sealed_ice", 
}
func swap(data):
    var names: Array = data["name"].split("/", false)
    var swaped_datas = []
    for n in names:
        if swap_pair.has(n):
            swaped_datas.append(card_prototypes.get(swap_pair[n]).duplicate(true))
        elif card_prototypes.has(n):
            var new_data = card_prototypes.get(n).duplicate(true)
            var tmp = new_data["hp"]
            new_data["hp"] = new_data["atk"]
            new_data["atk"] = tmp
            if new_data["hp"] == 0 and new_data["type"] == "mob": new_data["hp"] = 1
            swaped_datas.append(new_data)
        elif n.match ("ENCHANTED_*"):
            var cut_name = n.substr(10)
            if card_prototypes.has(cut_name): swaped_datas.append(card_prototypes.get(cut_name))
    var result = data
    if !swaped_datas.is_empty(): result = swaped_datas[0]
    if swaped_datas.size() >= 2: result = combine(swaped_datas)
    return result

func extract_features(datas):
    var arr_of_features = []
    for index in range(datas.size()):
        var data = datas[index]
        var features = []
        var archetypes = card_name.keys().filter(func(i): return data["name"].match ("*" + i + "*"))
        features.append_array(archetypes.filter(func(a): return !features.has(a)))
        for key in data:
            var value = data.get(key)
            if !features.has(key): features.append(key)
            if value is Array:
                features.append_array(value.filter(func(eff): return !features.has(eff)))
        if features.has("aoe_targets"):
            if !features.has("left"): features.append("left")
            if !features.has("right"): features.append("right")
        if features.has("frozen"):
            if !features.has("freeze"): features.append("freeze")
        arr_of_features.append(features)
    return arr_of_features

func random_card_data(cost = null, type = null, exclude = [], must_pool = null, rand = Randi() % (1000 + streak / 2)):
    var pool = []
    if must_pool != null:
        pool = must_pool.duplicate()
        for ex in exclude: pool.erase(ex)
        if cost != null: pool = pool.filter(func(i): return card_prototypes.get(i).get("cost") == cost.to_int())
        if type != null: pool = pool.filter(func(i): return card_prototypes.get(i).get("type") == type)
    if pool.is_empty():
        if rand > (1000 - meta_progress.unlocked_best_pick_pool.size()):
            pool = best_pick_pool.duplicate()
            for ex in exclude: pool.erase(ex)
            if cost != null: pool = pool.filter(func(i): return card_prototypes.get(i).get("cost") == cost.to_int())
            if type != null: pool = pool.filter(func(i): return card_prototypes.get(i).get("type") == type)
        if pool.is_empty():
            pool = basic_pick_pool.duplicate()
            for ex in exclude: pool.erase(ex)
            if cost != null: pool = pool.filter(func(i): return card_prototypes.get(i).get("cost") == cost.to_int())
            if type != null: pool = pool.filter(func(i): return card_prototypes.get(i).get("type") == type)
    if pool.is_empty(): return card_prototypes.get("meat").duplicate(true)
    else: return card_prototypes.get(pool[Randi() % pool.size()]).duplicate(true)

var encounter_list = [
    "blood_for_card", 
    "attack_or_retreat", 
    "heal_or_coin", 
    "pick_item", 
]
func rnd_talk(rnd_num):
    return encounter_list[rnd_num % encounter_list.size()]

@export var card_name: Dictionary
@export var effect_triggers: Dictionary
@export var effect_spec: Dictionary
@export var descriptions: Dictionary
@export var ui: Dictionary
var to_field: Tween
func switch_to_scene(switch_to = null):
    if switch_to == current_battle: Music.master()
    else: Music.reverb()
    resolving += 1
    var arr_of_scenes = [current_battle, three_cards, pick_from_deck]
    if switch_to != null: arr_of_scenes.erase(switch_to)
    if to_field != null: to_field.kill()
    to_field = create_tween().set_trans(Tween.TRANS_QUART)
    for scene in arr_of_scenes:
        to_field.parallel().tween_property(scene, "global_position", Vector2(0.0, -1080.0), 0.5)
    if switch_to != null:
        to_field.parallel().tween_property(switch_to, "global_position", Vector2(0.0, 0.0), 0.5)
    await get_tree().create_timer(0.5).timeout
    resolving -= 1

func Randi(): return rng.randi()
func gain_max_LP(amount):
    max_LP += amount
    if amount > 0: LP += amount
    if LP > max_LP: LP = max_LP
func gain_LP(amount):
    var initial_LP = LP
    if amount + LP > max_LP:
        LP = max_LP
    else:
        LP += amount
    if LP < 0: LP = 0
    if current_battle.in_battle and LP != initial_LP:
        for g in get_tree().get_nodes_in_group("grids"):
            await do_effect(g, g.contain, "changed_LP")
            await do_effect(g, g.contain, "changed_LP_ALWAYS")
        var tmp_arr = []
        tmp_arr.append_array(graveyard)
        tmp_arr.append_array(deck_to_draw)
        for c in tmp_arr:
            if c in graveyard: await do_effect(null, c, "changed_LP_ALWAYS")
            elif c in deck_to_draw: await do_effect(null, c, "changed_LP_ALWAYS")
func one_LP():
    LP = 1
func gain_pick_chance(amount):
    pick_chances += amount

func rnd_archetype(archetype):
    var arr = card_prototypes.values().filter(func(data): return data.get("name").match (archetype))
    return arr[Randi() % arr.size()].duplicate(true)

func rnd_boss_under_strength(power):
    var bosses_available = boss_pool.filter(func(boss): return card_prototypes[boss]["cost"] <= power).map(
        func(n): return card_prototypes[n])
    if !bosses_available.is_empty():
        bosses_available.sort_custom(func(a, b): return a["cost"] < b["cost"])
        bosses_available = bosses_available.filter(func(boss): return boss["cost"] == bosses_available[-1]["cost"])
        return bosses_available[Randi() % bosses_available.size()].duplicate(true)
    else: return rnd_enemy()
func rnd_enemy(pool = enemy_pool):
    return card_prototypes.get(pool[Randi() % pool.size()])

func rnd_enemy_of_cost(cost = 1):
    var pool = []
    for ene in enemy_pool: if card_prototypes.get(ene).cost == cost: pool.append(card_prototypes.get(ene))
    if pool.is_empty():
        var cutted_cost = Randi() % (cost - 1) + 1
        return combine([rnd_enemy_of_cost(cutted_cost), rnd_enemy_of_cost(cost - cutted_cost)])
    else: return pool[Randi() % pool.size()]

func rnd_card_from_pool(pool):
    if pool.is_empty(): return
    return card_prototypes.get(pool[Randi() % pool.size()]).duplicate(true)

func add_card_tween(card, initial_position, goal):
    card.visible = false
    card.global_position = initial_position
    card.mouse_filter = Control.MOUSE_FILTER_IGNORE
    create_tween().tween_property(card, "visible", true, 0.1)
    create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART).tween_property(card, "scale", Vector2(1.0, 1.0), 0.4).from(Vector2(0.2, 0.2))
    var curve_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
    curve_tween.tween_interval(0.5)
    curve_tween.tween_property(card, "global_position", goal, 0.6)
    curve_tween.parallel().tween_property(card, "scale", Vector2(0.4, 0.4), 0.4)
    await curve_tween.finished

func instantiate_from_pool():
    if card_pool.is_empty(): card_pool.append(card_scene.instantiate())
    var new_card = card_pool.pop_front()
    new_card.recover()
    return new_card

func _enter_tree():
    load_meta_progress()
    basic_pick_pool = meta_progress.unlocked_basic_pick_pool
    best_pick_pool = meta_progress.unlocked_best_pick_pool
    rng = RandomNumberGenerator.new()
    all_cards_pools = []
    for any in card_prototypes.keys(): all_cards_pools.append(card_prototypes[any])
    for i in card_prototypes.keys():
        card_prototypes.get(i).merge(
            {"name": i, "type": "spell", "atk": 0, "hp": 0, "cost": 0, "id": -1, "spell_boost": 0})
    for i in swap_pair.keys(): swap_pair.merge({swap_pair[i]: i})
    all_pick_pools = basic_pick_pool.duplicate(true)
    all_pick_pools.append_array(best_pick_pool.duplicate(true))
    var style: DialogicStyle = load("res://talk_style.tres")
    style.prepare()

    load_settings()
    change_lang(settings.language)

func load_settings():
    if FileAccess.file_exists("user://savesettings.save"):
        var to_load = FileAccess.open("user://savesettings.save", FileAccess.READ)
        var json = JSON.new()
        json.parse(to_load.get_line())
        var properties = json.get_data()
        if properties is Dictionary:
            for item in properties.keys():
                if settings.has(item):
                    settings[item] = properties[item]

func _ready():
    for i in range(80):
        add_child(instantiate_from_pool())
    await get_tree().process_frame
    for any_c in get_children(): any_c.back_to_pool()
    Music.play_start()
    Dialogic.start("load_timeline")
    await get_tree().process_frame
    Dialogic.end_timeline()
    await get_tree().process_frame
    if settings.fullscreen: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    if settings.vsync: DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
    else: DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)


func tutorial_run():
    pick_chances = 0
    toplayerui.map.generate_draw_tutorial_map()
    story_mode = true
    rng_seed = rng.seed
    rng_state = rng.state
    current_map.mandatory_pick()
    Dialogic.start("tutorial_hello")

func back_to_title():
    load_meta_progress()
    refresh_state()

    current_map.close()
    start_menu.appear()
    current_battle.respawn()

    switch_to_scene()


func infinity_run():

    story_mode = false
    rng = RandomNumberGenerator.new()
    rng_seed = rng.seed
    rng_state = rng.state
    refresh_state()
    load_game()
    current_map.initialize()
    if Global.new_game:
        for code in ["meat", "meat", "meat", "retreat", "Bird"]:
            add_to_constant_deck(card_prototypes.get(code).duplicate(true))
        play_plot_at_starting_game()
        if !loot_cards.is_empty():
            Global.pick_from_deck.refresh("choose_loot_card")
            Global.switch_to_scene(Global.pick_from_deck)
        else: map_or_pick_card()
    else: map_or_pick_card()





func play_plot_at_starting_game():
    if !meta_progress.tutorial_cleared or story_mode: return
    if !tag("run_start_1"):
        new_plot("run_start_1")


    if tag("run_start_1") and Global.new_game and !tag("win_chimera"):
        add_to_constant_deck(card_prototypes.get("hunter"))


    if !tag("run_start_lose_chimera") and tag("meet_chimera") and !tag("win_chimera"):
        new_plot("run_start_lose_chimera")

    if !tag("run_start_act2") and tag("win_chimera"):
        new_plot("run_start_act2")
    elif tag("run_start_act2") and Global.new_game: add_to_constant_deck(card_prototypes.get("Unican"))
    if tag("chimera2_join_party") and Global.new_game: add_to_constant_deck(card_prototypes.get("chimera2"))

func play_plot_at_openning_map():
    if !meta_progress.tutorial_cleared or story_mode: return
    if !tag("win_chimera"): act1()
    else: act2()
func act2(): pass



func act1():
    if current_map.map_info.depth == 1:
        if !tag("hunter_bgtalk") and meta_progress.plot_interval >= 4:
            new_plot("hunter_bgtalk")






    if current_map.map_info.depth == 2:
        if !tag("hunter_bgtalk_2") and meta_progress.plot_interval >= 3:
            new_plot("hunter_bgtalk_2")
    if current_map.map_info.depth == 3:
        if !tag("new_map_Unican_first"):
            new_plot("new_map_Unican_first")
        elif !tag("meet_fire_bird_first") and meta_progress.plot_interval >= 3:
            new_plot("meet_fire_bird_first")







func play_plot_at_meet_boss():
    if !meta_progress.tutorial_cleared or story_mode: return






    if current_map.map_info.depth == 3:
        if !tag("meet_chimera"):
            new_plot("meet_chimera")

func play_plot_at_win_boss():
    if !meta_progress.tutorial_cleared or story_mode: return
    if current_map.map_info.depth == 1:
        if !tag("win_boss_1"):
            await new_plot("win_boss_1")
    if current_map.map_info.depth == 2:
        if !tag("win_boss_2"):
            await new_plot("win_boss_2")
    if current_map.map_info.depth == 3:
        if !tag("win_chimera"):
            if !tag("run_start_lose_chimera"):
                await new_plot("speedrun_chimera")
            await new_plot("win_chimera")

var unlock_order = [
    "mobius_snake", 
    "fire_soul", 
    "Vampire", 
    "torture", 
    "pinata", 
    "fire_Cremation", 
    "winter_swim", 
    "Zombie", 
    "Wise", 
    "Sea_Star", 
    "Demon", 
    "Kaiju", 
    "stone_army", 
    "coward", 

    "bloody_coin", 
    "raid", 
    "fatality", 



    "ice_coin", 
    "Sealed_ice", 


    "Symbiont", 

    "ice_Ground", 
    "fire_twin", 

    "fire_bird", 
    "Cell", 

    "Truce", 
    "ice_Curse", 
    "Trex", 

    "Igloo", 
    "ScapeGoat", 

    "Bird", 
    "walking_coin", 
    "mushroom", 
    "fire_BUG", 
    "present", 
    "wolf", 
    "fairy", 
    "fire_Gate", 
    "Ironer", 
    "fodder", 
    "campfire", 
    "meat_wall", 
    "penguin", 
    "snowman", 
    "Shelter", 

    "snow_monster", 
    "hunter", 
    "berserk", 
    "Gold_Fish", 
    "snowball", 
    "fire_ball", 
    "Letter", 
    "attack", 
    "retreat", 

    ]
var best_unlock_order = [
    "Rain", 
    "body_sell", 
    "antimatter", 
    "Stillbirth", 
    "Abyss", 


    "old_sheep", "blizzard"]
var interval: int = 4
var interval_best: int = 1
func meta_unlock():
    if !meta_progress.tutorial_cleared or story_mode:
        back_to_title()
        return
    var can_unlock_basic = unlock_order.duplicate(true)
    can_unlock_basic.resize(int(meta_progress.node_passed / interval))
    can_unlock_basic = can_unlock_basic.filter(func(c): return c != null)
    var confirmed_unlock = []
    can_unlock_basic = can_unlock_basic.filter(func(c): return !meta_progress.unlocked_basic_pick_pool.has(c))
    if can_unlock_basic.size() > 4: can_unlock_basic.resize(4)
    confirmed_unlock.append_array(can_unlock_basic)

    var can_unlock_best = best_unlock_order.duplicate(true)
    can_unlock_best.resize(int(meta_progress.map_cleared / interval_best))
    can_unlock_best = can_unlock_best.filter(func(c): return c != null)
    can_unlock_best = can_unlock_best.filter(func(c): return !meta_progress.unlocked_best_pick_pool.has(c))
    if !can_unlock_best.is_empty(): confirmed_unlock.append(can_unlock_best[0])

    if confirmed_unlock.is_empty(): back_to_title()
    else: unlock_view.unlock(confirmed_unlock)

func abandon_current_run():
    var save_of = "infinity_"
    if Global.story_mode: save_of = "story_"
    DirAccess.remove_absolute("user://" + save_of + "savegame.save")
    DirAccess.remove_absolute("user://" + save_of + "savestate.save")
    DirAccess.remove_absolute("user://" + save_of + "map.save")
    DirAccess.remove_absolute("user://" + save_of + "map_info.save")
    new_game = true
    meta_unlock()

func refresh_state():
    story_mode = false
    deck_to_draw = []
    graveyard = []
    resolving = 0
    loot_cards = []
    pick_chances = 3
    draw_each_turn = 2
    win_reward = 0
    draw_start = 3
    id = 0
    LP = 50
    max_LP = 50
    streak = 0
    relics = []
    relic_progress = 0
    streaks_for_2xHP = 40
    streaks_for_1more_cost = 2
    next_pick_fusion = false
    constant_deck = []
    toplayerui.update_reliccol()

func tag(tag_name): return meta_progress.tag.has(tag_name)
func tag_add(tag_name): meta_progress.tag.append(tag_name)
func new_plot(tag_name):
    meta_progress.plot_interval = 0
    tag_add(tag_name)
    Dialogic.start(tag_name)
    await Dialogic.timeline_ended
    save_meta_progress()
func same_eff(a, b):
    if a is not Dictionary or b is not Dictionary: return false
    for item in a.keys(): if a[item] is Array and a[item].is_empty(): a.erase(item)
    for item in b.keys(): if b[item] is Array and b[item].is_empty(): b.erase(item)
    var aa: Dictionary = a.duplicate()
    var bb = b.duplicate()
    aa.erase("id")
    bb.erase("id")
    return aa == bb

var relic_bar = [1, 3, 5, 8, 11, 15, 20, 25, 30, 35, 40, 45, 50]
func has_relic(relic_name): return relics.has(relic_name)
func give_relic(relic_name):
    if relic_name:
        relics.append(relic_name)
        toplayerui.update_reliccol()
func shine_relic(relic_name): toplayerui.shine_relic(relic_name)
func relic_current_path():
    for i in range(relic_bar.size() - 1):
        if relic_progress >= relic_bar[i] and relic_progress < relic_bar[i + 1]:
            return [relic_progress - relic_bar[i], relic_bar[i + 1] - relic_bar[i]]
    if relic_progress >= relic_bar[-1]:
        return [relic_progress - relic_bar[-1], 99]
    elif relic_progress < relic_bar[0]:
        return [relic_progress, relic_bar[0]]
    return [0, relic_bar[0]]
func relic_progress_plus(n: int):

    give_relic(get_rnd_uniq_relic())





func get_rnd_uniq_relic():
    var pool = relics_pool.duplicate()
    for holding in relics: pool.erase(holding)
    if !pool.is_empty(): return pool[Randi() % pool.size()]
    else: return false

func map_or_pick_card():
    if pick_chances > 0:
        three_cards.refresh_all()
        await switch_to_scene(three_cards)
    else: current_map.mandatory_pick()

var chain_num: int = 0
func unchainable():
    if chain_num < 100:
        chain_num += 1

        current_battle.show_chain(chain_num)
        return false
    else:

        current_battle.show_chain(chain_num)
        return true
