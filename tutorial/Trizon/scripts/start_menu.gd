extends TextureRect
var black_tween

func _ready():
    update()

func disappear():
    if black_tween != null: black_tween.kill()
    black_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
    black_tween.tween_method(change_alpha, modulate.a, 0.0, 0.2)
    black_tween.parallel().tween_property($Flow.material, "shader_parameter/alpha", 0.0, 0.2)

    black_tween.tween_property(self, "visible", false, 0.0)

func appear():
    Global.gameover.visible = false
    update()
    if black_tween != null: black_tween.kill()
    black_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
    black_tween.tween_property(self, "visible", true, 0.0)
    black_tween.tween_method(change_alpha, modulate.a, 1.0, 0.2)
    black_tween.parallel().tween_property($Flow.material, "shader_parameter/alpha", 1.0, 0.2)


func change_alpha(v): modulate.a = v

func _on_tutorial_pressed():
    Music.sound_random_UI()

    disappear()
    Global.tutorial_run()

func _on_continue_pressed():
    Music.sound_random_UI()
    disappear()
    Global.infinity_run()

func _enter_tree():
    Global.start_menu = self

func _on_quit_pressed():
    get_tree().quit()

func _on_open_esu_pressed():
    Music.sound_random_UI()
    Global.esc.toggle()

func update():
    if Global.meta_progress.tutorial_cleared:
        enable_button($Continue)
    else:
        disable_button($Continue)
    if FileAccess.file_exists("user://savelootcards.save"):
        enable_button($Collection)
    else:
        disable_button($Collection)

    var option = 0
    match Global.settings.language:
        "zh_CN": option = 0
        "en": option = 1
        "ja": option = 2
    $OptionButton.selected = option

func disable_button(button: Control):
    button.mouse_filter = Control.MOUSE_FILTER_IGNORE
    button.modulate = Color.DIM_GRAY
func enable_button(button: Control):
    button.mouse_filter = Control.MOUSE_FILTER_STOP
    button.modulate = Color.WHITE

func _on_collection_pressed():
    Music.sound_random_UI()
    disappear()
    Global.pick_from_deck.refresh("collection")
    Global.switch_to_scene(Global.pick_from_deck)

func _on_option_button_item_selected(index):
    Music.sound_random_UI()
    await Global.load.blur()
    match index:
        0: Global.change_lang("zh_CN")
        1: Global.change_lang("en")
        2: Global.change_lang("ja")
