@tool
extends DialogicSettingsPage




func _get_title() -> String:
    return "General"


func _get_priority() -> int:
    return 99

func _ready() -> void :
    var s: = DCSS.inline({
        "padding": 5, 
        "background": Color(0.545098, 0.545098, 0.545098, 0.211765)
    })
    % ExtensionsFolderPicker.resource_icon = get_theme_icon("Folder", "EditorIcons")


    % ExtensionsFolderPicker.value_changed.connect(_on_ExtensionsFolder_value_changed)
    % PhysicsTimerButton.toggled.connect(_on_physics_timer_button_toggled)


    % ResetColorsButton.icon = get_theme_icon("Reload", "EditorIcons")
    % ResetColorsButton.button_up.connect(_on_reset_colors_button)


    % ExtensionCreator.hide()


func _refresh() -> void :
    % PhysicsTimerButton.button_pressed = DialogicUtil.is_physics_timer()
    % LayoutNodeEndBehaviour.select(ProjectSettings.get_setting("dialogic/layout/end_behaviour", 0))
    % ExtensionsFolderPicker.set_value(ProjectSettings.get_setting("dialogic/extensions_folder", "res://addons/dialogic_additions"))

    update_color_palette()

    % SectionList.clear()
    % SectionList.create_item()
    var cached_events: = DialogicResourceUtil.get_event_cache()
    var sections: = []
    var section_order: Array = DialogicUtil.get_editor_setting("event_section_order", ["Main", "Logic", "Flow", "Audio", "Visuals", "Other", "Helper"])
    for ev in cached_events:
        if !ev.event_category in sections:
            sections.append(ev.event_category)
            var item: TreeItem = % SectionList.create_item(null)
            item.set_text(0, ev.event_category)
            item.add_button(0, get_theme_icon("ArrowUp", "EditorIcons"))
            item.add_button(0, get_theme_icon("ArrowDown", "EditorIcons"))
            if ev.event_category in section_order:

                item.move_before(item.get_parent().get_child(min(section_order.find(ev.event_category), item.get_parent().get_child_count() - 1)))

    % SectionList.get_root().get_child(0).set_button_disabled(0, 0, true)
    % SectionList.get_root().get_child(-1).set_button_disabled(0, 1, true)


func _on_section_list_button_clicked(item: TreeItem, column, id, mouse_button_index):
    if id == 0:
        item.move_before(item.get_parent().get_child(item.get_index() - 1))
    else:
        item.move_after(item.get_parent().get_child(item.get_index() + 1))

    for child in % SectionList.get_root().get_children():
        child.set_button_disabled(0, 0, false)
        child.set_button_disabled(0, 1, false)

    % SectionList.get_root().get_child(0).set_button_disabled(0, 0, true)
    % SectionList.get_root().get_child(-1).set_button_disabled(0, 1, true)

    var sections: = []
    for child in % SectionList.get_root().get_children():
        sections.append(child.get_text(0))

    DialogicUtil.set_editor_setting("event_section_order", sections)
    force_event_button_list_reload()


func force_event_button_list_reload() -> void :
    find_parent("EditorsManager").editors["Timeline"].node.get_node("%VisualEditor").load_event_buttons()


func update_color_palette() -> void :

    for child in % Colors.get_children():
        child.queue_free()
    for color in DialogicUtil.get_color_palette():
        var button: = ColorPickerButton.new()
        button.custom_minimum_size = Vector2(50, 50) * DialogicUtil.get_editor_scale()
        % Colors.add_child(button)
        button.color = DialogicUtil.get_color(color)
        button.color_changed.connect(_on_color_change)


func _on_color_change(color: Color) -> void :
    var new_palette: = {}
    for i in % Colors.get_children():
        new_palette["Color" + str(i.get_index() + 1)] = i.color
    DialogicUtil.set_editor_setting("color_palette", new_palette)



func _on_reset_colors_button() -> void :
    DialogicUtil.set_editor_setting("color_palette", null)
    update_color_palette()


func _on_physics_timer_button_toggled(is_toggled: bool) -> void :
    ProjectSettings.set_setting("dialogic/timer/process_in_physics", is_toggled)
    ProjectSettings.save()


func _on_ExtensionsFolder_value_changed(property: String, value: String) -> void :
    if value == null or value.is_empty():
        value = "res://addons/dialogic_additions"
    ProjectSettings.set_setting("dialogic/extensions_folder", value)
    ProjectSettings.save()


func _on_layout_node_end_behaviour_item_selected(index: int) -> void :
    ProjectSettings.set_setting("dialogic/layout/end_behaviour", index)
    ProjectSettings.save()






func _on_create_extension_button_pressed() -> void :
    % CreateExtensionButton.hide()
    % ExtensionCreator.show()

    % NameEdit.text = ""
    % NameEdit.grab_focus()


func _on_submit_extension_button_pressed() -> void :
    if % NameEdit.text.is_empty():
        return

    var extensions_folder: String = ProjectSettings.get_setting("dialogic/extensions_folder", "res://addons/dialogic_additions")

    extensions_folder = extensions_folder.path_join( % NameEdit.text.to_pascal_case())
    DirAccess.make_dir_recursive_absolute(extensions_folder)
    var mode: int = % ExtensionMode.selected

    var file: FileAccess
    var indexer_content: = "@tool\nextends DialogicIndexer\n\n"
    if mode != 2:
        indexer_content += "func _get_events() -> Array:\n	return [this_folder.path_join('event_"\
+ % NameEdit.text.to_snake_case() + ".gd')]\n\n"
        file = FileAccess.open(extensions_folder.path_join("event_" + % NameEdit.text.to_snake_case() + ".gd"), FileAccess.WRITE)
        file.store_string(


"@tool\nextends DialogicEvent\nclass_name Dialogic"\
\
+ % NameEdit.text.to_pascal_case() + "Event\n\n# Define properties of the event here\n\nfunc _execute() -> void:\n	# This will execute when the event is reached\n	finish() # called to continue with the next event\n\n\n#region INITIALIZE\n################################################################################\n# Set fixed settings of this event\nfunc _init() -> void:\n	event_name = \""\
\
\
\
\
\
\
\
\
\
\
\
\
+ % NameEdit.text.capitalize() + "\"\n	event_category = \"Other\"\n\n\n\n#endregion\n\n#region SAVING/LOADING\n################################################################################\nfunc get_shortcode() -> String:\n	return \""\
\
\
\
\
\
\
\
\
+ % NameEdit.text.to_snake_case() + "\"\n\nfunc get_shortcode_parameters() -> Dictionary:\n	return {\n		#param_name 		: property_info\n		#\"my_parameter\"		: {\"property\": \"property\", \"default\": \"Default\"},\n	}\n\n# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()\n#endregion\n\n\n#region EDITOR REPRESENTATION\n################################################################################\n\nfunc build_event_editor() -> void:\n	pass\n\n#endregion\n"\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
)


    if mode != 0:
        indexer_content += "func _get_subsystems() -> Array:\n	return [{'name':'"\
+ % NameEdit.text.to_pascal_case() + "', 'script':this_folder.path_join('subsystem_" + % NameEdit.text.to_snake_case() + ".gd')}]"
        file = FileAccess.open(extensions_folder.path_join("subsystem_" + % NameEdit.text.to_snake_case() + ".gd"), FileAccess.WRITE)
        file.store_string(


"extends DialogicSubsystem\n\n## Describe the subsystems purpose here.\n\n\n#region STATE\n####################################################################################################\n\nfunc clear_game_state(clear_flag:=Dialogic.ClearFlags.FULL_CLEAR) -> void:\n	pass\n\nfunc load_game_state(load_flag:=LoadFlags.FULL_LOAD) -> void:\n	pass\n\n#endregion\n\n\n#region MAIN METHODS\n####################################################################################################\n\n# Add some useful methods here.\n\n#endregion\n"\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
)
    file = FileAccess.open(extensions_folder.path_join("index.gd"), FileAccess.WRITE)
    file.store_string(indexer_content)

    % ExtensionCreator.hide()
    % CreateExtensionButton.show()

    find_parent("EditorView").plugin_reference.get_editor_interface().get_resource_filesystem().scan_sources()
    force_event_button_list_reload()



func _on_reload_pressed() -> void :
    DialogicUtil._update_autoload_subsystem_access()
