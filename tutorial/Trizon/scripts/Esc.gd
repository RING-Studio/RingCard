extends ColorRect
@onready var card1 = $Card1
@onready var card2 = $Card2
@onready var global = $"/root/Global"
var tween_spawn1: Tween
var tween_spawn2: Tween
var alpha_tween: Tween

func _enter_tree():
    Global.esc = self

func _on_settings_pressed():
    Music.sound_random_UI()
    var arr = [$VSync, $FullScreen, $AudioPanel, $PitchChange, $Camerapanning, $Screenshake]
    for setting in arr:
        setting.visible = !setting.visible

func update():
    if Global.start_menu.visible:
        disable_button($new_game)
        disable_button($BackToTitle)
    else:
        enable_button($new_game)
        enable_button($BackToTitle)
    if Global.story_mode:
        disable_button($new_game)
    card1.burn_tween_kill()
    card2.burn_tween_kill()
    card1.material.set_shader_parameter("dissolve_value", 0.0)
    card2.material.set_shader_parameter("dissolve_value", 0.0)
    card1.card_icon.material.set_shader_parameter("dissolve_value", 0.0)
    card2.card_icon.material.set_shader_parameter("dissolve_value", 0.0)
    card1.card_data = Global.random_card_data(null, null, [], null, randi() % 1050)
    card2.card_data = Global.random_card_data(null, null, [card1.card_data["name"]], null, randi() % 1050)
    if alpha_tween != null: alpha_tween.kill()
    alpha_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
    alpha_tween.tween_property(material, "shader_parameter/alpha", 1.0, 0.4)
    card1.reset_burn_texture()
    card2.reset_burn_texture()
    card1.play_burn(true, Tween.EASE_OUT, Tween.TRANS_QUART, 0.4, false)
    await get_tree().create_timer(0.1).timeout
    if card2 != null: card2.play_burn(true, Tween.EASE_OUT, Tween.TRANS_QUART, 0.4, false)


func disable_button(button: Control):
    button.mouse_filter = Control.MOUSE_FILTER_IGNORE
    button.modulate = Color.DIM_GRAY
func enable_button(button: Control):
    button.mouse_filter = Control.MOUSE_FILTER_STOP
    button.modulate = Color.WHITE

func _input(event):
    if event is InputEventKey and !event.echo and Input.is_action_pressed("Esc"):
        toggle()

func toggle():
    if Dialogic.current_timeline != null or Global.resolving != 0: return
    if Global.card_detail_view.visible:
        Global.card_detail_view.close()
    if !visible:
        update()
        get_tree().paused = true
    else:
        material.set_shader_parameter("alpha", 0.0)
        if alpha_tween != null: alpha_tween.kill()
        get_tree().paused = false
    visible = !visible

func _on_continue_pressed():
    Music.sound_random_UI()
    self.visible = false
    get_tree().paused = false

func _on_exit_pressed():
    get_tree().quit()

func _on_new_game_pressed():
    Music.sound_random_UI()
    self.visible = false
    get_tree().paused = false
    Global.gameover.show_summary()












func _on_back_to_title_pressed():
    Music.sound_random_UI()
    self.visible = false
    get_tree().paused = false
    await Global.load.blur()
    Global.back_to_title()

func _on_full_screen_toggled(toggled_on):
    Music.sound_random_UI()
    if toggled_on:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
        Global.settings.fullscreen = true
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
        Global.settings.fullscreen = false
    Global.save_settings()

func _on_v_sync_toggled(toggled_on):
    Music.sound_random_UI()
    if toggled_on:
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
        Global.settings.vsync = true
    else:
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
        Global.settings.vsync = false
    Global.save_settings()

func _on_allcards_pressed():
    Global.toplayerui.toggle_deck_view(Global.all_cards_pools)

func _on_pitch_change_toggled(toggled_on):
    Music.sound_random_UI()
    if toggled_on:
        Global.settings.pitchchange = true
    else:
        Global.settings.pitchchange = false
    Global.save_settings()

func _on_camerapanning_toggled(toggled_on):
    Music.sound_random_UI()
    if toggled_on:
        Global.settings.camerapanning = true
    else:
        Global.settings.camerapanning = false
    Global.save_settings()

func _on_screenshake_toggled(toggled_on):
    Music.sound_random_UI()
    if toggled_on:
        Global.settings.screenshake = true
    else:
        Global.settings.screenshake = false
    Global.save_settings()

func _ready():
    if Global.settings.fullscreen: $FullScreen.set_pressed_no_signal(true)
    else: $FullScreen.set_pressed_no_signal(false)
    if Global.settings.screenshake: $Screenshake.set_pressed_no_signal(true)
    else: $Screenshake.set_pressed_no_signal(false)
    if Global.settings.camerapanning: $Camerapanning.set_pressed_no_signal(true)
    else: $Camerapanning.set_pressed_no_signal(false)
    if Global.settings.pitchchange: $PitchChange.set_pressed_no_signal(true)
    else: $PitchChange.set_pressed_no_signal(false)
    if Global.settings.vsync: $VSync.set_pressed_no_signal(true)
    else: $VSync.set_pressed_no_signal(false)
