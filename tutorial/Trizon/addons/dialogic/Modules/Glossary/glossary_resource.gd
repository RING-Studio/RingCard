@tool


class_name DialogicGlossary
extends Resource







@export var entries: = {}


@export var enabled: bool = true


const RESOURCE_NAME: = "Glossary"


const NAME_PROPERTY: = "name"

const ALTERNATIVE_PROPERTY: = "alternatives"

const TITLE_PROPERTY: = "title"

const TEXT_PROPERTY: = "text"

const EXTRA_PROPERTY: = "extra"


const TRANSLATION_PROPERTY: = "_translation_id"

const REGEX_OPTION_PROPERTY: = "regex_options"


const PRIVATE_PROPERTY_PREFIX: = "_"



@export var _translation_id: = ""





@export var _translation_keys: = {}








func remove_entry(entry_key: String) -> bool:
    var entry: Dictionary = get_entry(entry_key)

    if entry.is_empty():
        return false

    var aliases: Array = entry.get(ALTERNATIVE_PROPERTY, [])

    for alias: String in aliases:
        _remove_entry_alias(alias)

    entries.erase(entry_key)

    return true









func _remove_entry_alias(entry_key: String) -> bool:
    var value: Variant = entries.get(entry_key, null)

    if value == null or value is Dictionary:
        return false

    entries.erase(entry_key)

    return true












func replace_entry_key(old_entry_key: String, new_entry_key: String) -> void :
    var entry: = get_entry(old_entry_key)

    if entry == null:
        return

    entry.name = new_entry_key

    entries.erase(old_entry_key)
    entries[new_entry_key] = entry





func get_entry(entry_key: String) -> Dictionary:
    var entry: Variant = entries.get(entry_key, {})


    if entry is String:
        entry = entries.get(entry, {})

    return entry







func _add_entry_key_alias(entry_key: String, alias: String) -> bool:
    var entry: = get_entry(entry_key)
    var alias_entry: = get_entry(alias)

    if not entry.is_empty() and alias_entry.is_empty():
        entries[alias] = entry_key
        return true

    return false




func try_add_entry(entry: Dictionary) -> bool:
    var entry_key: String = entry[NAME_PROPERTY]

    if entries.has(entry_key):
        return false

    entries[entry_key] = entry

    for alternative: String in entry.get(ALTERNATIVE_PROPERTY, []):
        entries[alternative.strip_edges()] = entry_key

    return true





func _get_word_options(entry_key: String) -> Array:
    var word_options: Array = []

    var translation_enabled: bool = ProjectSettings.get_setting("dialogic/translation/enabled", false)

    if not translation_enabled:
        word_options.append(entry_key)

        for alternative: String in get_entry(entry_key).get(ALTERNATIVE_PROPERTY, []):
            word_options.append(alternative.strip_edges())

        return word_options

    var translation_entry_key_id: String = get_property_translation_key(entry_key, NAME_PROPERTY)

    if translation_entry_key_id.is_empty():
        return []

    var translated_entry_key: = tr(translation_entry_key_id)

    if not translated_entry_key == translation_entry_key_id:
        word_options.append(translated_entry_key)

    var translation_alternatives_id: String = get_property_translation_key(entry_key, ALTERNATIVE_PROPERTY)
    var translated_alternatives_str: = tr(translation_alternatives_id)

    if not translated_alternatives_str == translation_alternatives_id:
        var translated_alternatives: = translated_alternatives_str.split(",")

        for alternative: String in translated_alternatives:
            word_options.append(alternative.strip_edges())

    return word_options









func get_set_regex_option(entry_key: String) -> String:
    var entry: Dictionary = get_entry(entry_key)

    var regex_options: Dictionary = entry.get(REGEX_OPTION_PROPERTY, {})

    if regex_options.is_empty():
        entry[REGEX_OPTION_PROPERTY] = regex_options

    var locale_key: String = TranslationServer.get_locale()
    var regex_option: String = regex_options.get(locale_key, "")

    if not regex_option.is_empty():
        return regex_option

    var word_options: Array = _get_word_options(entry_key)
    regex_option = "|".join(word_options)

    regex_options[locale_key] = regex_option

    return regex_option





func add_translation_id() -> String:
    _translation_id = DialogicUtil.get_next_translation_id()
    return _translation_id



func remove_translation_id() -> void :
    _translation_id = ""



func remove_entry_translation_ids() -> void :
    for entry: Variant in entries.values():


        if entry is String:
            continue

        if entry.has(TRANSLATION_PROPERTY):
            entry[TRANSLATION_PROPERTY] = ""



func clear_translation_keys() -> void :
    const RESOURCE_NAME_KEY: = RESOURCE_NAME + "/"

    for translation_key: String in entries.keys():

        if translation_key.begins_with(RESOURCE_NAME_KEY):
            entries.erase(translation_key)

    _translation_keys.clear()









func get_property_translation_key(entry_key: String, property: String) -> String:
    var entry: = get_entry(entry_key)

    if entry == null:
        return ""

    var entry_translation_key: String = entry.get(TRANSLATION_PROPERTY, "")

    if entry_translation_key.is_empty() or _translation_id.is_empty():
        return ""

    var glossary_csv_key: = (RESOURCE_NAME
        .path_join(_translation_id)
        .path_join(entry_translation_key)
        .path_join(property))

    return glossary_csv_key






func _get_glossary_translation_id_prefix() -> String:
    return (
        DialogicGlossary.RESOURCE_NAME
            .path_join(_translation_id)
    )








func _get_glossary_translation_key(entry_translation_id: String, property: String) -> String:
    return (
        DialogicGlossary.RESOURCE_NAME
            .path_join(_translation_id)
            .path_join(entry_translation_id)
            .path_join(property)
    )




func get_set_glossary_entry_translation_id(entry_key: String) -> String:
    var glossary_entry: Dictionary = get_entry(entry_key)
    var entry_translation_id: = ""

    var glossary_translation_id: String = glossary_entry.get(TRANSLATION_PROPERTY, "")

    if glossary_translation_id.is_empty():
        entry_translation_id = DialogicUtil.get_next_translation_id()
        glossary_entry[TRANSLATION_PROPERTY] = entry_translation_id

    else:
        entry_translation_id = glossary_entry[TRANSLATION_PROPERTY]

    return entry_translation_id




func get_set_glossary_translation_id() -> String:
    if _translation_id == null or _translation_id.is_empty():
        add_translation_id()

    return _translation_id
