@tool
extends Label


func _ready() -> void :


    if owner.get_parent() is SubViewport:
        return
    label_settings = LabelSettings.new()
    label_settings.font = get_theme_font("doc_italic", "EditorFonts")
    label_settings.font_size = get_theme_font_size("font_size", "Label")
    label_settings.font_color = get_theme_color("accent_color", "Editor")
