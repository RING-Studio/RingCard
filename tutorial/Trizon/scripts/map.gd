extends Control
var sample_node_scene = preload("res://scenes/sample_node.tscn")
var sample_node
var sample_dot
var global
var refresh_button
var blur_tween: Tween
@export var read_only: bool = true
@export var location_matrix: Array[Array]
var rng
@export var map_info: Dictionary = {}
var terra_list = ["tNONE", "tLONG", "tWIDE", ]
var biome_list = ["bNONE", "bFIRE", "bICE", "bHURT", "bERODE", "bGOOD", "bSAFE", ]
var pos_list: Array[Rect2] = []

func passed_node_count(percentage: bool = true):
    var count: int = 0
    var all_node_num: int = 0
    for col in location_matrix:
        for node in col:
            all_node_num += 1
            if node.map_event["passed"] == true: count += 1
    if percentage: return float(count) / all_node_num
    else: return count

func has_biome(biome_name): return map_info.biome.has(biome_name)
func close():
    if blur_tween != null: blur_tween.kill()
    blur_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
    blur_tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.2)
    blur_tween.parallel().tween_property($BlurBg.material, "shader_parameter/alpha", 0.0, 0.2)
    blur_tween.tween_property(self, "visible", false, 0.0)
    mouse_filter = MOUSE_FILTER_IGNORE
    read_only = true
    Global.toplayerui.toggle_map_button(true)

func open():
    if blur_tween != null: blur_tween.kill()
    blur_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
    visible = true
    blur_tween.tween_property(self, "modulate", Color.WHITE, 0.2)
    blur_tween.parallel().tween_property($BlurBg.material, "shader_parameter/alpha", 1.0, 0.2)
    mouse_filter = MOUSE_FILTER_PASS
    Global.toplayerui.toggle_map_button(false)

func _enter_tree():
    global = $"/root/Global"
    sample_node = $SampleNode
    sample_dot = $SampleDot
    refresh_button = $RefreshMap
    global.current_map = self
    rng = RandomNumberGenerator.new()

func initialize():

    global.current_map = self
    rng.seed = int(load_map_info().rng_seed)
    var map_depth = 7
    var max_width = 5
    var average_width = max_width * 0.7
    generate_map(map_depth, average_width, max_width)
    draw_map()
    insert_map_event()
    load_map_event()
    update_all()
    if !location_matrix.any(func(column): return column.any(func(node): return node.map_event.passed)):
        location_matrix[0].map(func(n): n.reachable = true)
        location_matrix[0].map(func(n): n.start_tween())
    show_refresh()

func mandatory_pick():
    Global.switch_to_scene(null)
    show_refresh()
    read_only = false
    open()
    Global.play_plot_at_openning_map()

func erode_rnd(except):
    for col in location_matrix:
        var have_not_pass = col.filter(func(node): return !node.map_event["passed"] and !node.map_event["eroded"])
        if !have_not_pass.is_empty():
            var node = have_not_pass[rng.randi() % have_not_pass.size()]
            if node != except:
                node.erode()
                return

func deal_map_event(node):
    if Global.meta_progress.tutorial_cleared:
        Global.meta_progress.node_passed += 1
        Global.meta_progress.plot_interval += 1
    map_info["passed_node"] += 1
    erode_rnd(node)
    update_all()
    show_refresh()
    match node.map_event["name"]:
        "normal_fight": fight_dealer(node)
        "elite": fight_dealer(node)
        "boss": fight_dealer(node)
        "fusion": fusion_event(node)
        "door": _on_refresh_map_pressed()
        "heal":
            heal_event(node)
            Global.play_plot_at_openning_map()
        "swap": swap_event(node)
        "item":
            item_event(node)
            Global.play_plot_at_openning_map()
        "camp":
            close()
            if node.map_event.eroded: Global.gain_max_LP(5)
            Global.three_cards.refresh_all_camp_event()
            Global.switch_to_scene(Global.three_cards)
            if Global.has_relic("HUMBIRD"):
                Global.shine_relic("HUMBIRD")
                Global.pick_chances += 2
        "tribute":
            close()
            Global.pick_from_deck.refresh("tribute", node.map_event.eroded, node.map_event["tribute_index"])
            await Global.switch_to_scene(Global.pick_from_deck)
        "chimera": Global.current_battle.chimera_fight()
        _: encounter_dealer(node)

func item_event(node):
    global.add_to_constant_deck(Global.rnd_card_from_pool(global.consumable_pool))
    if node.map_event.eroded: Global.add_to_constant_deck(global.rnd_card_from_pool(global.consumable_pool))


func encounter_dealer(node):
    var encounter_name = node.map_event["name"]
    if node.map_event.eroded: Dialogic.start(encounter_name + "_eroded")
    else: Dialogic.start(encounter_name)

func fight_dealer(node):
    close()
    var map_event = node.map_event
    Global.current_battle.map_event = map_event.duplicate(true)
    await Global.switch_to_scene(Global.current_battle)
    if node.map_event["name"] == "boss":
        Music.transin(true)
        Global.play_plot_at_meet_boss()
        location_matrix[-1][0].map_event = {"name": "door", "passed": false, "hidden": false, "eroded": false}
        location_matrix[-1][0].update()
    var num_of_boss = int(map_event["name"] == "boss")
    global.current_battle.start_battle(map_event.wave, map_event.intensity, num_of_boss)

func fusion_event(node):
    close()
    Global.pick_from_deck.refresh("fusion", node.map_event.eroded)
    await Global.switch_to_scene(Global.pick_from_deck)

func heal_event(node):
    if node.map_event.eroded: global.gain_max_LP(5)
    else: global.add_to_constant_deck(global.card_prototypes.get("bandage").duplicate(true))

func swap_event(node):
    close()
    Global.pick_from_deck.refresh("swap", node.map_event.eroded)
    await Global.switch_to_scene(Global.pick_from_deck)

func generate_map(max_level = 7, average_width = 3.5, max_width = 5):

    pos_list = []
    get_children().map(func(node):
        if ![sample_node, sample_dot, $Mask, $BlurBg, refresh_button].has(node): node.queue_free())
    var rand = rng
    var total_level = int(max_level * average_width)
    var distributed = max_level * 3
    location_matrix = []
    for l in range(max_level):
        location_matrix.append([sample_node_scene.instantiate(), sample_node_scene.instantiate(), sample_node_scene.instantiate()])
    while distributed != total_level:
        distributed += 1
        var new_node = sample_node_scene.instantiate()
        var ok_col = max_level
        if location_matrix[-1].size() >= max_width - 1:
            ok_col = max_level - 1
        var rnd = rand.randi() % ok_col
        while location_matrix[rnd].size() >= max_width: rnd = rand.randi() % ok_col
        location_matrix[rnd].append(new_node)

func init_location(rand = rng):
    var max_width = location_matrix.map(func(col): return col.size())
    max_width.sort()
    max_width = max_width[-1]
    for column in range(location_matrix.size()):
        for node_index in range(location_matrix[column].size()):

            var current_node = location_matrix[column][node_index]
            add_child(current_node)
            var relative_index: float = float(node_index + 0.5) - float(location_matrix[column].size()) / 2.0
            var relative_column: float = float(column + 0.5) - float(location_matrix.size()) / 2.0
            current_node.position = Vector2(
                size.x / 2.0 - current_node.size.x / 2.0 + size.x * relative_column / location_matrix.size(), 
                size.y / 2.0 - current_node.size.y + size.y * relative_index / ((location_matrix[column].size() + max_width) / 2))
            var rnd_offset_range_y = size.y / ((location_matrix[column].size() + max_width) + 8)
            if rand.randi() % 2 == 1: current_node.position.y += rand.randi() % int(rnd_offset_range_y)
            else: current_node.position.y -= rand.randi() % int(rnd_offset_range_y)
            var rnd_offset_range_x = size.x / (2.0 * location_matrix.size() + 10)
            if rand.randi() % 2 == 1: current_node.position.x += rand.randi() % int(rnd_offset_range_x)
            else: current_node.position.x -= rand.randi() % int(rnd_offset_range_x)

func draw_map():
    var rand = rng
    init_location()
    var boss_node = sample_node_scene.instantiate()
    add_child(boss_node)
    location_matrix.append([boss_node])
    boss_node.position = Vector2(size.x + boss_node.size.x, size.y / 2.0 - boss_node.size.y / 2.0)
    for column in range(location_matrix.size() - 1):
        for node_index in range(location_matrix[column].size()):

            var current_node = location_matrix[column][node_index]
            var candidates = location_matrix[column + 1].filter(func(n): return n.global_position.x > current_node.global_position.x)
            candidates.sort_custom(
                func(a, b): return current_node.global_position.distance_to(a.global_position) < current_node.global_position.distance_to(b.global_position))
            make_path(current_node, candidates[0])

    for column in range(location_matrix.size() - 1):
        for node_index in range(location_matrix[column].size()):
            var current_node = location_matrix[column][node_index]

            if column == location_matrix.size() - 2 and node_index < location_matrix[column].size() - 1:
                make_path(current_node, location_matrix[column][node_index + 1])

            if current_node.connected_with.size() <= 1 or rand.randi() % 3 == 0:
                if node_index == 0 and !location_matrix[column][1].connected_with.has(current_node):
                    make_path(current_node, location_matrix[column][1])
                elif node_index == location_matrix[column].size() - 1 and !location_matrix[column][-2].connected_with.has(current_node):
                    make_path(current_node, location_matrix[column][-2])
            if (node_index != 0 and node_index != location_matrix[column].size() - 1 and 
            !location_matrix[column][node_index + 1].connected_with.has(current_node) and 
            !location_matrix[column][node_index - 1].connected_with.has(current_node) and rand.randi() % 2 == 1):
                if rand.randi() % 2 == 1: make_path(current_node, location_matrix[column][node_index + 1])
                else: make_path(current_node, location_matrix[column][node_index - 1])

func make_path(current_node, candidate):
    var p1 = current_node.position + current_node.size / 2.0
    var p2 = candidate.position + candidate.size / 2.0
    var dis = p1.distance_to(p2)
    var mid_high = Vector2((p1.x + p2.x) / 2.0 + randf() * dis * 0.7 - dis * 0.35, min(p1.y, p2.y))
    var mid_low = Vector2((p1.x + p2.x) / 2.0 + randf() * dis * 0.7 - dis * 0.35, max(p1.y, p2.y))
    var mid = [mid_high, mid_low][randi() % 2]
    if (location_matrix.any(func(column): return column[0] == current_node) and 
        location_matrix.any(func(column): return column[0] == candidate)):
        mid = mid_high
    elif (location_matrix.any(func(column): return column[-1] == current_node) and 
        location_matrix.any(func(column): return column[-1] == candidate)):
        mid = mid_low

    if current_node == location_matrix[-2][0] or current_node == location_matrix[-2][-1]:
        mid = Vector2(p2.x, p1.y)
    var num_of_dots = int(dis / (41.0 + randf() * 3.0))

    for t in range(num_of_dots):
        if t == 0: continue
        var new_dot = sample_dot.duplicate()
        add_child(new_dot)
        move_child(new_dot, 1)
        new_dot.scale = new_dot.scale * (1 + randf() * 0.2)
        new_dot.position = quadratic_bezier(p1, mid, p2, t / float(num_of_dots))
        if !pos_list.any(func(s): return s.has_point(new_dot.position)):
            pos_list.append(Rect2(new_dot.position - Vector2(12, 12), Vector2(24, 24)))
        else:
            new_dot.queue_free()
    current_node.connected_with.append(candidate)
    candidate.connected_with.append(current_node)

func replace_node(node_name, number, rand = rng):
    var candidates = []
    for i in location_matrix: for node in i: if node.map_event["name"] == "normal_fight": candidates.append(node)
    for i in range(number):
        var elite = candidates[rand.randi() % candidates.size()]
        elite.map_event["name"] = node_name
        candidates.erase(elite)







func insert_map_event():
    var rand = rng
    for i in location_matrix: for node in i:
        node.map_event = {"name": "normal_fight", "passed": false, "hidden": false, "eroded": false}

    var num_of_fusion = 2
    for prog in range(num_of_fusion):
        var col = location_matrix[int((prog + 0.6) * (location_matrix.size() - 1) / num_of_fusion)]
        col[rand.randi() % col.size()].map_event["name"] = "fusion"

    var num_of_camp = 2
    for prog in range(num_of_camp):
        var col = location_matrix[int((prog + 0.3) * (location_matrix.size() - 1) / num_of_camp)]
        col[rand.randi() % col.size()].map_event["name"] = "camp"

    var num_of_tribute = 1
    for prog in range(num_of_tribute):
        var col = location_matrix[int((prog + 0.5) * (location_matrix.size() - 1) / num_of_tribute)]
        col[rand.randi() % col.size()].map_event = {
            "name": "tribute", "passed": false, "hidden": false, "eroded": false, "tribute_index": rand.randi() % 7}

    location_matrix[-1][0].map_event = {"name": "boss", "passed": false, "hidden": false, "eroded": false}











    location_matrix[-1][0].map_event = {"name": "boss", "passed": false, "hidden": false, "eroded": false}
    replace_node("elite", 5)













    if map_info.depth == 3 and !Global.tag("win_chimera"):
        location_matrix[-1][0].map_event = {"name": "chimera", "passed": false, "hidden": false, "eroded": false}


    for i in location_matrix: for node in i:
        if node.map_event.name == "normal_fight" or node.map_event.name == "elite" or node.map_event.name == "boss":
            var col = (location_matrix.map(func(column): return column.has(node)).find(true) + 1) / float(location_matrix.size() - 1)

            var intensity = (10 * col + Global.streak) / Global.streaks_for_1more_cost
            var wave = 1
            if node.map_event["name"] == "elite":
                wave += 1
                intensity -= intensity / 4
            if node.map_event["name"] == "boss":
                intensity += intensity / 2
            if intensity <= 1: intensity = 1
            node.map_event.merge({"intensity": int(intensity), "wave": wave})

    update_all()




































var default_info: Dictionary = {
    "rng_seed": Global.rng_seed, 
    "terra": "tNONE", 
    "biome": ["bNONE"], 
    "depth": 1, 
    "enemies_killed": 0, 
    "passed_node": 0, 
    "battle_won": 0, 
    "fusion_time": 0, 
    }

func load_map_info():
    var save_of = "infinity_"
    if Global.story_mode: save_of = "story_"
    var info = {"rng_seed": Global.rng_seed}
    map_info = default_info.duplicate(true)
    map_info["rng_seed"] = Global.rng_seed
    if FileAccess.file_exists("user://" + save_of + "map_info.save"):
        var map_info_file = FileAccess.open("user://" + save_of + "map_info.save", FileAccess.READ)
        var info_dict = map_info_file.get_line()
        var json_tmp = JSON.new()
        json_tmp.parse(info_dict)
        info = json_tmp.get_data()
        if info is Dictionary:
            for item in info.keys():
                if map_info.has(item): map_info[item] = info[item]

    Global.toplayerui.update_reliccol()
    return map_info

func load_map_event():
    var save_of = "infinity_"
    if Global.story_mode: save_of = "story_"
    if not FileAccess.file_exists("user://" + save_of + "map.save"): return
    var map = FileAccess.open("user://" + save_of + "map.save", FileAccess.READ)
    for column in range(location_matrix.size()):
        for node_index in range(location_matrix[column].size()):
            var json_string = map.get_line()
            var json = JSON.new()
            var parse_result = json.parse(json_string)
            if not parse_result == OK:
                print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
                continue
            location_matrix[column][node_index].map_event = json.get_data()

func save_map():
    if !Global.meta_progress.tutorial_cleared: return
    var save_of = "infinity_"
    if Global.story_mode: save_of = "story_"
    if location_matrix.size() == 4: return
    var nodes = []
    location_matrix.map(func(column): nodes.append_array(column))
    var map = FileAccess.open("user://" + save_of + "map.save", FileAccess.WRITE)
    for node in nodes:
        var json_string = JSON.stringify(node.map_event, "", false)
        map.store_line(json_string)

    save_map_info()

func save_map_info():
    if !Global.meta_progress.tutorial_cleared: return
    var save_of = "infinity_"
    if Global.story_mode: save_of = "story_"
    var map_info_file = FileAccess.open("user://" + save_of + "map_info.save", FileAccess.WRITE)
    var json_string = JSON.stringify({
        "rng_seed": str(rng.get_seed()), 

        "terra": map_info.terra, 
        "biome": map_info.biome, 
        "depth": map_info.depth, 
        "enemies_killed": map_info.enemies_killed, 
        "passed_node": map_info.passed_node, 
        "battle_won": map_info.battle_won, 
        "fusion_time": map_info.fusion_time
        }, "", false, true)
    map_info_file.store_line(json_string)

func update_all():
    location_matrix.map(func(column): column.map(func(node): node.update()))
    show_refresh()

func quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float):
    var q0 = p0.lerp(p1, t)
    var q1 = p1.lerp(p2, t)
    var r = q0.lerp(q1, t)
    return r

func _on_refresh_map_pressed():
    if read_only: return
    var save_of = "infinity_"
    if Global.story_mode: save_of = "story_"
    DirAccess.remove_absolute("user://" + save_of + "map.save")
    DirAccess.remove_absolute("user://" + save_of + "map_info.save")
    map_info.terra = terra_list.filter(func(t): return t != map_info.terra)[rng.randi() % (terra_list.size() - 1)]
    var available_new_biomes = biome_list.filter(func(b): return !has_biome(b))
    map_info.biome = [available_new_biomes[rng.randi() % available_new_biomes.size()]]
    map_info.depth += 1
    var next_map_seed = rng.randi()
    rng = RandomNumberGenerator.new()
    rng.seed = next_map_seed
    save_map_info()
    Global.streak += int(8)
    initialize()
    Global.meta_progress.map_cleared += 1
    Global.LP = Global.max_LP
    global.save()
    save_map()
    refresh_button.visible = false

func show_refresh():
    return







func generate_draw_tutorial_map():
    pos_list = []
    map_info = default_info.duplicate(true)
    get_children().map(func(node):
        if ![sample_node, sample_dot, $Mask, $BlurBg, refresh_button].has(node): node.queue_free())
    location_matrix = [[sample_node_scene.instantiate()], [sample_node_scene.instantiate()], [sample_node_scene.instantiate()], [sample_node_scene.instantiate()], [sample_node_scene.instantiate()]]
    location_matrix[0][0].map_event = {"name": "signal_", "passed": false, "hidden": false, "eroded": false, }
    location_matrix[1][0].map_event = {"name": "normal_fight", "passed": false, "hidden": false, "eroded": false, "intensity": 1, "wave": 1}
    location_matrix[2][0].map_event = {"name": "normal_fight", "passed": false, "hidden": false, "eroded": false, "intensity": 1, "wave": 1}
    location_matrix[3][0].map_event = {"name": "fusion", "passed": false, "hidden": true, "eroded": false}
    location_matrix[-1][0].map_event = {"name": "elite", "passed": false, "hidden": false, "eroded": false, "intensity": 1, "wave": 2}
    init_location()




    make_path(location_matrix[0][0], location_matrix[1][0])
    make_path(location_matrix[1][0], location_matrix[2][0])
    make_path(location_matrix[2][0], location_matrix[3][0])
    make_path(location_matrix[3][0], location_matrix[-1][0])
    update_all()
    location_matrix[0][0].texture = load("res://UI/normal_fight.png")
    location_matrix[0][0].reachable = true
    location_matrix[0][0].start_tween()
    location_matrix[0][0].node_clicked.connect(Global.current_battle.tutorial_0)
    location_matrix[1][0].node_clicked.connect(tutorial_1)
    location_matrix[2][0].node_clicked.connect(tutorial_2)
    location_matrix[3][0].node_clicked.connect(tutorial_3)

    Global.current_battle.win.connect(tutorial_5)

func tutorial_1():
    Dialogic.start("huse_first_intro")

func tutorial_2():
    Dialogic.start("meet_hunter")

func tutorial_3():
    Dialogic.start("meet_hunter_2")

func tutorial_4():
    pass


func tutorial_5(event):
    if event != location_matrix[-1][0].map_event: return
    Global.pick_chances = 0
    Dialogic.start("tutorial_finish")
    await Dialogic.timeline_ended
    Global.meta_progress.tutorial_cleared = true
    Global.unlock_view.unlock(["Bird", "hunter"])

func _on_gui_input(event):
    if (event is InputEventMouseButton and 
        (event.button_index == MOUSE_BUTTON_RIGHT or event.button_index == MOUSE_BUTTON_LEFT)):
        if read_only: close()
