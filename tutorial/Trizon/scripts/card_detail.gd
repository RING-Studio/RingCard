extends Control
signal quit_check
var alpha_tween: Tween
@export var sample: Button
var template
var global
var effect_box
var update_flag: bool = true
var descriptions
var effect_triggers
var effect_spec
var card_name
var ui
var sample_init_pos
@onready var related_c_arr = [$RelatedCard, $RelatedCard2, $RelatedCard3]
func update_translate():
    var text_resource = Global.text_resource
    descriptions = text_resource.descriptions
    effect_triggers = text_resource.effect_triggers
    effect_spec = text_resource.effect_spec
    card_name = text_resource.card_name
    ui = text_resource.ui

func _enter_tree():
    global = get_node("/root/Global")
    global.card_detail_view = self

func _ready():
    self.visible = false
    sample = get_node("Card")
    sample.glow(0.2, 0.25)
    sample_init_pos = sample.global_position
    effect_box = get_node("ScrollContainer/VBoxContainer")
    template = get_node("Template")
    await get_tree().process_frame
    update_translate()
    var shake_tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE)
    shake_tween.tween_property(sample, "rotation", 0.015, 4.0)
    shake_tween.tween_property(sample, "rotation", -0.015, 4.0)

func _on_gui_input(event):
    if (event is InputEventMouseButton and !event.is_pressed() and 
        (event.button_index == MOUSE_BUTTON_RIGHT or event.button_index == MOUSE_BUTTON_LEFT)):
        close()

var last_scroll = 0
func _on_scroll_container_gui_input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_RIGHT:
            close()
        elif event.button_index == MOUSE_BUTTON_LEFT:
            if event.is_pressed():
                last_scroll = $ScrollContainer.scroll_vertical
            elif last_scroll == $ScrollContainer.scroll_vertical:
                close()








var oldbus
func close():
    Music.bus = oldbus
    $Template.visible = false
    $TemplateEN.visible = false
    self.visible = false
    quit_check.emit(sample)
    material.set_shader_parameter("alpha", 0.0)
    if alpha_tween != null: alpha_tween.kill()
    Engine.time_scale = Engine.time_scale * 2.0

func show_detail(showing: Button):
    oldbus = Music.bus
    Music.reverb()
    var card_data = showing.card_data
    if "constant" in card_data and "gold" in card_data["constant"]: $GodRay.visible = true
    else: $GodRay.visible = false
    if !visible: Engine.time_scale = Engine.time_scale / 2.0
    for related_c in related_c_arr:
        related_c.card_data = {"name": "?", "type": "mob", "atk": 0, "hp": 0, "cost": 0, "id": -1, "spell_boost": 0}
        related_c.visible = false
    if alpha_tween != null: alpha_tween.kill()
    alpha_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
    alpha_tween.tween_property(material, "shader_parameter/alpha", 1.0, 0.15)
    update_translate()
    $archetype.text = ""
    for old_box in effect_box.get_children(false):
        old_box.free()
    self.visible = true

    sample.card_data = card_data

    var archetypes = card_name.keys().filter(func(i): return card_data["name"].match ("*" + i + "*"))
    archetypes.erase("")
    archetypes.erase(card_data["name"])
    for a in archetypes: $archetype.text += card_name[a] + ",  "
    $archetype.text = $archetype.text.substr(0, len($archetype.text) - 3)






    if card_data.has("spell_boost") and card_data["spell_boost"] != 0:
        var description = template.duplicate()
        if card_data["type"] == "mob":
            description.text = ui["boost_mob"][0] + str(card_data["spell_boost"]) + ui["boost_mob"][1]
        elif card_data["type"] == "spell":
            description.text = ui["boost_spell"][0] + str(card_data["spell_boost"]) + ui["boost_spell"][1]
        effect_box.add_child(description)
        description.visible = true

    for trigger in card_data:
        if !(card_data.get(trigger) is Array) or (card_data.get(trigger).is_empty() and trigger != "declare_attack"): continue
        var texts
        if effect_triggers.has(trigger): texts = effect_triggers[trigger] + "\n"
        else: texts = trigger + ": \n"
        for effect in card_data.get(trigger):

            if effect.match ("* *:*"):
                effect = effect.split(" ")
                texts += effect_spec[effect[0]][0] + ui[effect[1]] + effect_spec[effect[0]][1]
                var trig_and_eff = effect[-1].split(":")
                texts += effect_triggers[trig_and_eff[0]]
                effect = trig_and_eff[1]
            var filtered_keys = effect_spec.keys().filter(func(key): return effect.match (key))

            if effect_spec.has(effect) and effect_spec[effect] is String:
                texts += effect_spec[effect] + "\n"
            elif !filtered_keys.is_empty():
                filtered_keys.sort_custom(func(a, b): return len(a) > len(b))
                var spec = effect_spec.get(filtered_keys[0])

                var specific_name = effect.substr(len(filtered_keys[0]) - 1)
                if card_name.has(specific_name):
                    texts += spec[0] + card_name.get(specific_name) + spec[1] + "\n"
                    for related_c in related_c_arr:
                        if (Global.card_prototypes.keys().has(specific_name) and !related_c.visible and 
                            !related_c_arr.any(func(c): return c.card_data == global.card_prototypes.get(specific_name))):
                            related_c.card_data = global.card_prototypes.get(specific_name)
                            related_c.visible = true
                            break
                elif "*" in specific_name:
                    texts += spec[0] + ui["archetype"][0]
                    if card_name.has(specific_name.replace("*", "")):
                        texts += card_name[specific_name.replace("*", "")] + ui["archetype"][1] + spec[1] + "\n"
                    else: texts += specific_name.replace("*", "") + ui["archetype"][1] + spec[1] + "\n"
                else:
                    texts += spec[0] + specific_name + spec[1] + "\n"
            else:
                if card_name.has(effect.replace("*", "")):
                    texts += (ui["archetype"][0] + card_name[effect.replace("*", "")] + 
                                ui["archetype"][1] + "\n")

                else: texts += effect + "\n"

        var slices = texts.split("\n", false)
        var repeated_times = []
        var repeated = 0
        for i in range(slices.size()):
            if repeated == 0 or slices[i - 1] == slices[i]:
                repeated += 1
            else:
                repeated_times.append(repeated)
                repeated = 1
        repeated_times.append(repeated)
        var line = 0
        var texts_new = ""
        for num in repeated_times:
            if num == 1: texts_new += slices[line] + "\n"
            else: texts_new += slices[line] + " " + ui["repeat"][0] + str(num) + ui["repeat"][1] + "\n"
            line += num
        texts = texts_new

        var new_effect = template.duplicate()
        new_effect.text = texts
        if card_data["type"] == "mob" and trigger == "declare_attack" and card_data.get(trigger).is_empty():
            new_effect.text = ui["no_attack_target"]
        elif trigger == "declare_attack" and card_data.get(trigger).is_empty(): continue
        if card_data.get(trigger) != ["front"]:
            effect_box.add_child(new_effect)
        else: new_effect.queue_free()
        new_effect.visible = true
