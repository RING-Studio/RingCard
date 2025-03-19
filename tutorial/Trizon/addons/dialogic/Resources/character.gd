@tool
extends Resource
class_name DialogicCharacter





@export var display_name: = ""
@export var nicknames: = []

@export var color: = Color()
@export var description: = ""

@export var scale: = 1.0
@export var offset: = Vector2()
@export var mirror: = false

@export var default_portrait: = ""
@export var portraits: = {}

@export var custom_info: = {}


enum TranslatedProperties{
    NAME, 
    NICKNAMES, 
}

var _translation_id: = ""


func _to_string() -> String:
    return "[{name}:{id}]".format({"name": get_character_name(), "id": get_instance_id()})



func add_translation_id() -> String:
    _translation_id = DialogicUtil.get_next_translation_id()
    return _translation_id




func get_set_translation_id() -> String:
    if _translation_id == null or _translation_id.is_empty():
        return add_translation_id()
    else:
        return _translation_id



func remove_translation_id() -> void :
    _translation_id = ""





func get_property_translation_key(property: TranslatedProperties) -> String:
    var property_key: = ""

    match property:
        TranslatedProperties.NAME:
            property_key = "name"
        TranslatedProperties.NICKNAMES:
            property_key = "nicknames"

    return "Character".path_join(_translation_id).path_join(property_key)





func _get_property_original_text(property: TranslatedProperties) -> String:
    match property:
        TranslatedProperties.NAME:
            return display_name
        TranslatedProperties.NICKNAMES:
            return ", ".join(nicknames)

    return ""










func _get_property_translated(property: TranslatedProperties) -> String:
    var try_translation: bool = (_translation_id != null
        and not _translation_id.is_empty()
        and ProjectSettings.get_setting("dialogic/translation/enabled", false)
    )

    if try_translation:
        var translation_key: = get_property_translation_key(property)
        var translated_property: = tr(translation_key)



        if translated_property == translation_key:
            return _get_property_original_text(property)

        return translated_property

    else:
        return _get_property_original_text(property)




func get_nicknames_translated() -> Array:
    var translated_nicknames: = _get_property_translated(TranslatedProperties.NICKNAMES)
    return (translated_nicknames.split(", ") as Array)



func get_display_name_translated() -> String:
    return _get_property_translated(TranslatedProperties.NAME)



func get_character_name() -> String:
    var unique_identifier: = DialogicResourceUtil.get_unique_identifier(resource_path)
    if not unique_identifier.is_empty():
        return unique_identifier
    if not resource_path.is_empty():
        return resource_path.get_file().trim_suffix(".dch")
    elif not display_name.is_empty():
        return display_name.validate_node_name()
    else:
        return "UnnamedCharacter"




func get_portrait_info(portrait_name: String) -> Dictionary:
    return portraits.get(portrait_name, portraits.get(default_portrait, {}))
