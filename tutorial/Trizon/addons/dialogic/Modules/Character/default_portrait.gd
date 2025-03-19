@tool
extends DialogicPortrait




@export_group("Main")
@export_file var image: = ""



func _update_portrait(passed_character: DialogicCharacter, passed_portrait: String) -> void :
    apply_character_and_portrait(passed_character, passed_portrait)

    apply_texture($Portrait, image)
