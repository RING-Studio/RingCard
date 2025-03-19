extends TextureRect
signal node_clicked
@export var connected_with: Array = []
@export var map_event: Dictionary = {"passed": false, "name": "", "hidden": false}
@export var reachable: bool = false
var tween: Tween
var tween2: Tween

func _ready():
    material.set_shader_parameter("randomizer", randf() * 3.14)
    pivot_offset = size / 2

func update():
    var passed = map_event.passed
    if passed:
        modulate = Color(0.4, 0.4, 0.4)
        if tween != null: tween.kill()
        if tween2 != null: tween2.kill()
        tween = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
        tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.5)
    else:
        modulate = Color(1, 1, 1)
        if map_event["eroded"]:
            modulate = Color(0.7, 0.1, 0.7)
        if connected_with.any(func(n): return n.map_event.passed):
            reachable = true
            map_event["hidden"] = false
        else: reachable = false
        if reachable:
            start_tween()
        else:
            if tween != null:
                tween.kill()
                tween = null
            if tween2 != null:
                tween2.kill()
                tween2 = null
            tween = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
            tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.5)
    if map_event["hidden"] and !map_event["passed"]: texture = load("res://UI/secret.png")
    elif ResourceLoader.exists("res://UI/" + map_event.name + ".png"):
        texture = load("res://UI/" + map_event.name + ".png")
    else: if !map_event["name"].match ("signal_*"): texture = load("res://UI/secret.png")

func start_tween():
    if tween2 == null:
        if tween != null: tween.kill()
        tween2 = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT).set_loops()
        tween2.tween_property(self, "scale", Vector2(1.25, 1.25), 0.65 + randf() * 0.1)
        tween2.tween_property(self, "scale", Vector2(1.0, 1.0), 0.65 + randf() * 0.1)

func _on_gui_input(event):
    if map_event.passed or !reachable or get_parent().read_only: return
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
        if map_event.name != "boss":
            map_event.passed = true
            if tween != null: tween.kill()
            tween = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
            tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.5)
        if map_event["name"].match ("signal_*"):
            get_parent().erode_rnd(self)
            get_parent().update_all()
        else: get_parent().deal_map_event(self)
        node_clicked.emit()

func _on_mouse_entered():
    var info = ""
    if Global.ui.has(map_event["name"]):
        info += Global.ui[map_event["name"]]
        if "tribute_index" in map_event: info += "\n" + tr("TRIBUTE" + str(map_event["tribute_index"]))
        if map_event["name"] == "normal_fight" or map_event["name"] == "elite":
            info += "\n" + Global.ui["strength"] + ": " + str(map_event.intensity)
    else: info += Global.ui["encounter"]
    if map_event["eroded"]:
        if Global.ui["eroded"].has(map_event.name):
            info += "\n" + Global.ui["eroded"]["eroded_text"] + ": " + Global.ui["eroded"][map_event.name]
        else: info += "\n" + Global.ui["eroded"]["eroded_text"] + ": " + Global.ui["eroded"]["encounter"]
    if map_event.hidden and !map_event.passed: info = "???"
    if map_event.name.match ("signal_*"): info = tr("PLOTPOPUP")
    if map_event.name == "door": info = tr("NEXTAREA")
    Popups.pop_at(global_position + size + Vector2(8.0, 8.0), info)

func _on_mouse_exited():
    Popups.unpop()

func erode():
    map_event["eroded"] = true
    if map_event.name == "elite" or map_event.name == "normal_fight":
        map_event.intensity += int(map_event.intensity / 2 + 0.5)
    elif map_event.name == "boss":
        map_event.wave += 1
