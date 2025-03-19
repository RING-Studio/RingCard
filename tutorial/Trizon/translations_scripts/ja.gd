extends Node
@export var card_name: Dictionary = {
    "": "任意", 
    "!Fusion!": "融合", 
    "!Relic!": "+1遺物", 

    "fire": "火", 
    "Letter": "手紙", 

    "Kaiju": "障害物", 
    "Vampire": "吸血鬼", 
    "Rain": "雨", 
    "SHELL": "貝", 
    "Trex": "竜", 
    "Sigma": "虫", 
    "Igloo": "イグルー", 
    "Shelter": "拾い屋", 
    "Ironer": "カニ", 
    "fire_Gate": "太陽", 
    "ScapeGoat": "身代わり", 
    "Gold_Fish": "金魚", 
    "Asher": "ロウソク", 
    "Unican": "ユニカン", 
    "chimera": "キメラ", 
    "chimera2": "キメラ", 
    "Aggres": "アリス", 
    "Truce": "休戦", 

    "fire_Cremation": "火葬", 
    "undead_army": "蘇生", 
    "body_sell": "再利用", 
    "Antispell": "塔", 
    "Symbiont": "草", 
    "Cell": "ヤンデレ", 
    "Ostrich": "ダチョウ", 
    "Abyss": "深淵", 
    "Demon": "悪魔", 
    "antimatter": "反物質", 
    "fire_bird": "不死鳥", 
    "Stillbirth": "死産", 
    "poke_ball": "逮捕", 
    "icy_slayer": "ケルピー", 
    "BAIT": "餌", 

    "Reborner1": "番人", 
    "Reborner2": "牢獄", 
    "Freezer1": "アイス", 
    "Freezer2": "破氷船", 
    "Shooter1": "二丁銃", 
    "Shooter2": "手榴弾", 
    "Ash": "灰", 
    "silver1": "銀衛", 
    "silver2": "銀衛II", 
    "silver3": "銀衛III", 
    "zooer1": "巫女", 
    "zooer2": "巫女II", 
    "zooer3": "巫女III", 
    "War1": "司祭", 
    "War2": "司祭II", 
    "War3": "司祭III", 
    "bandage": "回復", 
    "refire": "クロワッサン", 
    "stone_army": "幽霊", 
    "meat": "肉", 
    "coward": "臆病者", 
    "mushroom": "キノコ", 
    "old_sheep": "宅急便", 
    "meat_wall": "肉塊", 
    "walking_coin": "農民", 
    "wolf": "猫", 
    "fairy": "蝶", 
    "present": "ギフト", 
    "hunter": "狩人", 
    "alien": "コイン", 
    "healer": "赤星", 
    "fire_BUG": "蛍", 
    "campfire": "焚火", 
    "fire_ball": "火球", 
    "fire_soul": "赤狐", 
    "fire_twin": "双子", 

    "attack": "出撃", 
    "retreat": "撤退", 

    "Fate": "雷", 
    "fatality": "正月", 
    "mobius_snake": "彼岸花", 

    "snowball": "雪球", 
    "blizzard": "吹雪", 
    "ice_coin": "アイス", 
    "winter_swim": "泳ぐ", 
    "penguin": "ペンギン", 
    "snow_monster": "隠者", 
    "snowman": "雪だるま", 
    "Sealed_ice": "氷琥珀", 
    "ice_Curse": "風邪", 
    "ice_Ground": "極地", 

    "Zombie": "社員", 
    "Sea_Star": "ヒトデ", 
    "berserk": "格闘家", 
    "pinata": "ピニャータ", 
    "torture": "拷問", 
    "Wise": "知識", 
    "bloody_coin": "収穫", 
    "Magic_spring": "麺", 
    "Bird": "鳥", 
    "fodder": "餌", 
    "raid": "襲撃", 

    "fox": "狐", 
    "bear": "熊", 
    "goat": "カマキリ", 
    "lion": "顔", 
    "bat": "蝙蝠", 
    "slime": "スライム", 
    "beast": "泥", 
    "fire_element": "炎", 
    "water_element": "水", 
    "wind_element": "曇", 
    "earth_element": "土", 
    "goblin": "ゴブリン", 
    "living_armor": "ゴーレム", 
    "orge": "牛", 
    "hipo": "カバ", 
    "elephant": "象", 
    "thief": "蛇", 
    "iceberg": "霊", 
    "shadow": "影", 
    "card_eater": "カチャ", 
    "Masochism": "樹", 
    "nest": "巣"
}

@export var effect_spec: Dictionary = {
    "gain_food_atk_hp": "その生物の攻撃力と体力を得る", 
    "KAIJU": "このカードは相手の場にしか出せない", 
    "all_to_hand": "このカードを手札に加える", 
    "gy_to_hand_not_in_deck": "デッキに含まれない墓地のカードすべてを手札に戻す", 
    "rainbow": "虹彩", 
    "draw_all_cost": "各コストごとにカードを1枚ずつ引く", 
    "refresh_deck": "墓地にある、デッキに属するカードをすべて山札に戻す", 
    "tune_atk_hp": "攻撃力と体力が、2つのうち高い方になる", 
    "EVENT": "（イベント選択肢のみで、このカードを選んでもデッキに加わらない）", 
    "freeze_landed_enemy": "その生物を凍結する", 
    "self_lose_protect": "この生物は保護を失う", 
    "resist_freeze": "このカードは凍結しない", 
    "gold": "金色", 
    "const_atk_or_hp+": "ランダムに永久で攻撃力または体力を1得る", 
    "guard": "プレイヤーの代わりに戦闘ダメージを受ける", 
    "WET": "濡れている（一度だけ、このカードは焼却されない）", 
    "cast_on_all_grids": "プレイ時の効果が全マスに適用される", 
    "cannot_hit_player": "プレイヤーを攻撃しない", 
    "infinite_protect": "この生物は保護を無限に重ねられる", 
    "allies_random_protect": "ランダムな味方1体を保護する（次のダメージを0にする）", 
    "easy_draw": "デッキからこのカードを引く確率が2倍になる", 
    "new_turn": "即座に新ターン開始（戦闘をスキップ）", 
    "burn_hands_damage_all_enemies": "このカードの左側の手札すべてを燃やし、その枚数分のダメージを全敵に与える", 
    "self_protect": "この生物を保護する（次のダメージを0にする）", 
    "give_protect": "このマスの生物を保護する（次のダメージを0にする）", 
    "protect": "保護状態（次のダメージが0になる）", 
    "super_grid_to_hand": "このマス内のボス以外の生物を手札に戻す", 
    "atk=hp": "このカードの攻撃力は体力と同じ", 
    "meta_hp": "このカードの体力は回復しない（ラウンド終了後も変わらない）", 
    "fusion_not_consume": "キマイラ以外の、融合している全ての生物を召喚する", 
    "next_pick_fusion": "次のカード選択時に1度融合できる", 
    "full_copy": "このカードのコピーを1枚手札に加える", 
    "cost=allies": "この生物の費用はフィールド上の生物の数に等しい", 
    "atk=allies": "この生物の攻撃力はフィールド上の生物の数に等しい", 
    "draw=atk": "この生物の攻撃力1につきカード1枚を引く", 
    "delete_burn_rightmost": "手札の一番右のカードを燃やし、デッキから永久に削除する", 
    "pick_chance_-1": "カード選択のチャンスを1回失う", 
    "ban_turn": "今ターン、カードを一切プレイできなくなる", 
    "move_right": "このマスの生物を右へ1マス移動する（空のマスのみ）", 
    "hand_to_deck": "このカードを山札にシャッフルする（この呪文は燃やされない）", 
    "burn_rightmost": "手札の右端のカードを燃やす", 
    "itself_revive_to_hand": "このカードが墓地から手札に復活する", 
    "itself_revive_to_field": "このカードが墓地から場に復活する", 
    "itself_revive_to_deck": "このカードが墓地から山札に戻される", 
    "spell_copy_forever": "倒された生物のコピーを1枚、デッキに永久に加える", 
    "spell_burn": "このカードを燃やす", 
    "not_spell_burn": "このカードを燃やす", 
    "refire": "手札の全カードを燃やし、同じ枚数のカードを引く", 
    "consumable": "このカードをデッキから永久に削除する", 
    "self_harm": "自分自身に攻撃力と同等のダメージを与える", 
    "flip": "味方の生物の攻撃力と体力を入れ替える", 
    "itself_draw": "山札からこのカードを引く", 
    "auto_retreat": "敵を倒すと自動で手札に戻る", 
    "attack": "この生物が即座に攻撃する", 
    "draw": "カードを1枚引く", 
    "spell_attack": "このマスの生物が即座に攻撃する", 
    "aoe_targets": "攻撃するたびに、左右の敵をそれぞれ追加で攻撃する", 
    "grid_to_hand": "このマスの味方の生物を手札に戻す", 
    "vampire": "攻撃力と同等の体力を得る", 
    "permanent_hp+": "永久に体力を1増加する", 
    "permanent_atk+": "永久に攻撃力を1増加する", 
    "front": "このカードの正面の敵を攻撃する", 
    "left": "このカードの左前方の敵を攻撃する", 
    "right": "このカードの右前方の敵を攻撃する", 
    "random": "ランダムなカードを1枚手札に加える", 
    "card_reward": "カード選択のチャンスを1回得る", 
    "healer": "場にあるこのカードとその味方は、このカードの攻撃力と同じ体力を得る", 
    "freeze_in_front": "このカードの正面の敵を凍結する", 
    "freeze": "凍結状態にする（攻撃不可、各ターン開始時に解除される）", 
    "unfreeze": "凍結を解除する", 
    "enemies_freeze": "全ての敵を凍結する", 
    "all_freeze": "全ての生物を凍結する", 
    "freeze_random_enemy": "ランダムな敵を1体凍結する", 
    "freeze_random_creature": "ランダムな生物を1体凍結する", 
    "mirror": "そのコピーを手札に加える", 
    "num_of_freeze_draw": "場に凍結した生物が1体につきカードを1枚引く", 
    "add_*": [
        "1枚の", 
        "を手札に加える"
    ], 
    "damage_*": [
        "", 
        "点のダメージを与える"
    ], 
    "self_damage_*": [
        "このカード自身に", 
        "点のダメージを与える"
    ], 
    "all_damage_*": [
        "各マスの生物に", 
        "点のダメージを与える"
    ], 
    "all_enemies_damage_*": [
        "全ての敵に", 
        "点のダメージを与える"
    ], 
    "enemy_rnd_damage_*": [
        "ランダムな敵に", 
        "点のダメージを与える"
    ], 
    "deck_add_random": "この戦闘中のみ、山札にランダムなカードを1枚追加する", 
    "deck_add_*": [
        "山札に", 
        "を1枚追加する（この戦闘のみ）"
    ], 
    "constant_deck_add_*": [
        "デッキに", 
        "を1枚追加する（永久）"
    ], 
    "hp_*": [
        "体力を", 
        "点得る"
    ], 
    "atk_*": [
        "攻撃力を", 
        "点得る"
    ], 
    "both_atk_hp_*": [
        "攻撃力と体力を", 
        "点得る"
    ], 
    "spell_atk_*": [
        "このマスの生物が", 
        "点の攻撃力を得る"
    ], 
    "spell_hp_*": [
        "このマスの生物が", 
        "点の体力を得る"
    ], 
    "cost_*": [
        "費用 ", 
        ""
    ], 
    "LP*": [
        "プレイヤー血量 ", 
        ""
    ], 
    "draw_all_*": [
        "山札からすべての", 
        "を引く"
    ], 
    "draw_*": [
        "山札から", 
        "を1枚引く"
    ], 
    "revive_all_*": [
        "墓地のすべての", 
        "を手札に戻す"
    ], 
    "revive_*": [
        "墓地の1枚の", 
        "を手札に戻す"
    ], 
    "summon_random_*": [
        "費用が", 
        "のランダムな生物を召喚する"
    ], 
    "summon_*": [
        "", 
        "を召喚する"
    ], 
    "gy_to_field_*": [
        "墓地の", 
        "を場に復活させる"
    ], 
    "boost_*": [
        "この生物は効果を得る：呪文ダメージが", 
        "点増加する"
    ], 
    "kill_one_*": [
        "場の", 
        "を1体破壊する"
    ], 
    "kill_all_*": [
        "場のすべての", 
        "を破壊する"
    ], 
    "random_hand_cost_*": [
        "手札のランダムなカードの費用が", 
        ""
    ], 
    "fill_and_add_remains_*": [
        "5体の", 
        "を召喚し、余りを手札に加える"
    ], 
    "give": [
        "", 
        "の生物は効果を得る："
    ], 
    "spell_add_accord_allies_*": [
        "あなたの場にある生物1体につき、", 
        "を手札に加える"
    ], 
    "allies_atk_hp_*": [
        "場にあるこのカードとその味方は", 
        "点の攻撃力と体力を得る"
    ], 
    "turn_atk_*": [
        "このカードの攻撃力が", 
        "になる"
    ], 
    "double_cast_*": [
        "", 
        "の呪文が2回発動する"
    ], 
    "hands_cost_*": [
        "手札のすべての費用", 
        ""
    ], 
    "all_atk_*": [
        "場にあるすべての生物の攻撃力が", 
        ""
    ], 
    "front_damage_*": [
        "このカードの正面の生物に", 
        "点のダメージを与える"
    ]
}

@export var effect_triggers: Dictionary = {
    "after_eat": "このカードに供物を捧げる時：", 
    "changed_LP_ALWAYS": "このカードがどこにあっても、プレイヤーのライフ変動後：", 
    "changed_LP": "プレイヤーのライフ変動後：", 
    "enter_hand": "このカードが手札に入った後：", 
    "enemy_landed": "任意の敵が場に出た後：", 
    "wave_started": "各波の敵が出現した後：", 
    "after_grid_to_hand": "この生物が手札に戻った後：", 
    "fatal_hurt": "この生物が致命傷を受けた後：", 
    "lose_protect": "この生物が保護を失った後：", 
    "in_hand_draw_phase": "あなたのターン開始時に、このカードが手札にある場合：", 
    "cast_on_freeze": "凍結マスでこの呪文を発動した場合、発動後：", 
    "any_fire_instantiated": "火炎カードが手札に加わった後：", 
    "instantiate": "このカードが手札に入った後：（廃止済み）", 
    "in_hand_after_spell": "任意の呪文発動後に、このカードが手札にある場合：", 
    "in_hand_after_attack": "任意のカードの攻撃完了後に、このカードが手札にある場合：", 
    "per_any_damage": "1ダメージごとに：", 
    "be_burnt": "焼却後：", 
    "cast_when_0_deck": "プレイ後、山札が空の場合：", 
    "gy_draw_phase": "あなたのターン開始時に、このカードが墓地にある場合：", 
    "gy_end_phase": "あなたのターン終了時に、このカードが墓地にある場合：", 
    "gy_any_freeze": "任意の生物が凍結した時に、このカードが墓地にある場合：", 
    "deck_to_hand": "山札からこのカードを引いた後：", 
    "unfrozen": "凍結解除後：", 
    "any_unfrozen": "任意のカードが凍結解除した後：", 
    "any_drawn": "カードを引いた後：", 
    "cast_on_empty_grid": "空のマスでこの呪文を発動した後：", 
    "in_hand_any_freezed": "任意の生物が凍結した時に、このカードが手札にある場合：", 
    "in_hand_any_tribute": "任意の生物が犠牲にされた時に、このカードが手札にある場合：", 
    "in_hand_any_death": "任意の生物が焼却された時に、このカードが手札にある場合：", 
    "in_hand_any_attack": "任意の生物が攻撃した時に、このカードが手札にある場合：", 
    "pre_battle": "各ステージ開始前に、このカードが山札にある場合：", 
    "declare_attack": "この生物が攻撃を宣言した時：", 
    "landed": "場に出た後：", 
    "end_phase": "あなたのターン終了時：", 
    "spell_used": "プレイ時：", 
    "on_damage": "このカードがダメージを与えた時：", 
    "after_attack": "このカードの攻撃後：", 
    "draw_phase": "あなたのターン開始時：", 
    "after_spell": "任意の呪文の発動完了後：", 
    "after_death": "焼却後：", 
    "any_death": "任意の生物が焼却された後：", 
    "get_kill": "このカードが生物を倒した後：", 
    "any_attack": "任意の生物が攻撃した後：", 
    "constant": "", 
    "material": "この生物が以下のカードに犠牲にされた時、そのカードのコストを2減少させる：", 
    "hurt": "この生物がダメージを受け生存した時（0ダメージも含む）：", 
    "get_freezed": "この生物が凍結された後：", 
    "any_freezed": "任意の生物が凍結された後："
}

@export var descriptions: Dictionary = {
    "Success": "Congrat!\n				You have beaten the game in this mode!\n				Click the 'New Game' button on the top right corner to start a new game or continue playing.\n				(This notification will only appear once)"\
\
\
, 
    "Tutorial": "Choose Easy mode to play the game.\n				The initial deck consists of several simple cards to help new players get familiar with the game.\n				(Consequently, there will be only one card reward at the beginning.)"\
\
, 
    "Normal": "Choose normal mode to play the game.\n				No initial deck.\n				You have 12 card rewards at the start."\
\
, 
    "Chaos": "Choose chaos mode to play the game.\n				No initial deck.\n				You have 15 card rewards at the start.\n				! Enemies grow stronger at twice the speed, choose carefully !"\
\
\
, 
    "!Fusion!": "(This is the entry of a event, not a real card)\n				You can pick any two creatures or any two spells in your deck, \n				and combine them into one card!\n				(The created card will have all effects of the two cards)\n				Or you may pick a spell and a creature,\n				In certain recipe, this could create a totally different card."\
\
\
\
\
, 
    "!Trader!": "(This is the entry of a event, not a real card)\n				Enter a shop where 5 rare cards are available for sale.\n				Their price will be 1~3 certain kinds of cards in your deck."\
\
, 
    "zombie": "Very stinky", 
    "start+1": "You additionally draw a card at the start of a battle", 
    "each_turn_draw+1": "You additionally draw a card each turn", 
    "win_reward+1": "You additionally get a card reward after winning a battle", 
    "card_reward+3": "You get 3 card reward", 
    "all_atk+1": "All creatures currently in your deck gain 1 atk permanently", 
    "all_hp+1": "All creatures currently in your deck gain 1 hp permanently", 
    "all_cost-1": "All cards currently in your deck cost 1 less permanently", 
}
@export var ui: Dictionary = {
    "gy_button": "墓地（焼却済カードが入る）", 
    "deck_to_draw_button": "ドローデッキ（この戦闘で未引カード）", 
    "grids": "全て", 
    "my_grids": "味方", 
    "your_grids": "敵", 
    "this_grid": "この枠", 
    "repeat": [
        "、", 
        "回"
    ], 
    "event": "イベント", 
    "boost_mob": [
        "呪文ダメージ+ ", 
        ""
    ], 
    "boost_spell": [
        "このカードのダメージ+ ", 
        ""
    ], 
    "archetype": [
        "", 
        "カード"
    ], 
    "deck": "デッキ", 
    "graveyard": "墓地", 
    "LP": "ライフ", 
    "card_reward": "カード選択", 
    "streak": "ステージ", 
    "fullscreen": "フルスクリーン", 
    "newgame": "新規開始", 
    "endturn": "ターン終了", 
    "help": "チュートリアル", 
    "loot_card": "カードを選んで、コレクションに加える", 
    "collection": "", 
    "choose_loot_card": "カードを1枚選び、このゲームに持ち込む", 
    "fusion": "2枚のカードを選び、合体させる", 
    "swap": "1枚のカードを選び、関連カードに変える", 
    "tribute": "1枚のカードを選び、デッキから除外する", 
    "no_attack_target": "攻撃対象なし", 
    "normal_fight": "敵1波と戦闘", 
    "strength": "敵強度", 
    "heal": "治癒カードを追加", 
    "elite": "敵2波と連戦", 
    "encounter": "奇遇", 
    "boss": "このボスを倒して次層へ", 
    "item": "ランダム消費カードを入手", 
    "camp": "キャンプ", 
    "eroded": {
        "eroded_text": "腐食済", 
        "normal_fight": "敵強度×1.5", 
        "elite": "敵強度×1.5", 
        "heal": "最大体力+5", 
        "fusion": "融合回数+1", 
        "swap": "変換カードの費用半減（切上げ）", 
        "encounter": "？？？", 
        "boss": "ボス数+1", 
        "item": "もう1枚入手", 
        "camp": "最大体力+5", 
        "tribute": "選んだカードは除外されない"
    }
}
