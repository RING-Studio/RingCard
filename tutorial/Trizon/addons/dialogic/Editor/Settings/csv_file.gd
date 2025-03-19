class_name DialogicCsvFile
extends RefCounted


var lines: Array[PackedStringArray] = []


var old_lines: Dictionary = {}



var column_count: = 0



var is_new_file: bool = false


var file: FileAccess


var used_file_path: String


var updated_rows: int = 0


var new_rows: int = 0




var add_separator: bool = false

enum PropertyType{
    String = 0, 
    Array = 1, 
    Other = 2, 
}


const TRANSLATION_ID: = DialogicGlossary.TRANSLATION_PROPERTY






func _init(file_path: String, original_locale: String, separator_enabled: bool) -> void :
    used_file_path = file_path
    add_separator = separator_enabled



    var locale_array_line: = PackedStringArray(["keys", original_locale])
    lines.append(locale_array_line)

    if not ResourceLoader.exists(file_path):
        is_new_file = true



        column_count = 2
        return

    file = FileAccess.open(file_path, FileAccess.READ)

    var locale_csv_row: = file.get_csv_line()
    column_count = locale_csv_row.size()
    var locale_key: = locale_csv_row[0]

    old_lines[locale_key] = locale_csv_row

    _read_file_into_lines()




func _read_file_into_lines() -> void :
    while not file.eof_reached():
        var line: = file.get_csv_line()
        var row_key: = line[0]

        old_lines[row_key] = line







func collect_lines_from_characters(characters: Dictionary) -> void :
    for character: DialogicCharacter in characters.values():

        var name_property: = DialogicCharacter.TranslatedProperties.NAME
        var display_name_key: String = character.get_property_translation_key(name_property)
        var line_value: String = character.display_name
        var array_line: = PackedStringArray([display_name_key, line_value])
        lines.append(array_line)

        var nicknames: Array = character.nicknames

        if not nicknames.is_empty():
            var nick_name_property: = DialogicCharacter.TranslatedProperties.NICKNAMES
            var nickname_string: String = ",".join(nicknames)
            var nickname_name_line_key: String = character.get_property_translation_key(nick_name_property)
            var nick_array_line: = PackedStringArray([nickname_name_line_key, nickname_string])
            lines.append(nick_array_line)


        if add_separator:
            _append_empty()



func _append_empty() -> void :
    var empty_line: = PackedStringArray(["", ""])
    lines.append(empty_line)



func _get_key_type(key: String) -> PropertyType:
    if key.ends_with(DialogicGlossary.NAME_PROPERTY):
        return PropertyType.String

    if key.ends_with(DialogicGlossary.ALTERNATIVE_PROPERTY):
        return PropertyType.Array

    return PropertyType.Other


func _process_line_into_array(csv_values: PackedStringArray, property_type: PropertyType) -> Array[String]:
    const KEY_VALUE_INDEX: = 0
    var values_as_array: Array[String] = []

    for i in csv_values.size():

        if i == KEY_VALUE_INDEX:
            continue

        var csv_value: = csv_values[i]

        if csv_value.is_empty():
            continue

        match property_type:
            PropertyType.String:
                values_as_array = [csv_value]

            PropertyType.Array:
                var split_values: = csv_value.split(",")

                for value in split_values:
                    values_as_array.append(value)

    return values_as_array


func _add_keys_to_glossary(glossary: DialogicGlossary, names: Array) -> void :
    var glossary_prefix_key: = glossary._get_glossary_translation_id_prefix()
    var glossary_translation_id_prefix: = _get_glossary_translation_key_prefix(glossary)

    for glossary_line: PackedStringArray in names:

        if glossary_line.is_empty():
            continue

        var csv_key: = glossary_line[0]


        if not csv_key.begins_with(glossary_prefix_key):
            continue

        var value_type: = _get_key_type(csv_key)


        if (value_type == PropertyType.Other
        or not csv_key.begins_with(glossary_translation_id_prefix)):
            continue

        var new_line_to_add: = _process_line_into_array(glossary_line, value_type)

        for name_to_add: String in new_line_to_add:
            glossary._translation_keys[name_to_add.strip_edges()] = csv_key








func add_translation_keys_to_glossary(glossary: DialogicGlossary) -> void :
    glossary._translation_keys.clear()
    _add_keys_to_glossary(glossary, lines)
    _add_keys_to_glossary(glossary, old_lines.values())





func _get_glossary_translation_key_prefix(glossary: DialogicGlossary) -> String:
    return (
        DialogicGlossary.RESOURCE_NAME
            .path_join(glossary._translation_id)
    )








func _sort_glossary_entry_property_keys(property_key_a: String, property_key_b: String) -> bool:
    const GLOSSARY_CSV_LINE_ORDER: = {
        DialogicGlossary.NAME_PROPERTY: 0, 
        DialogicGlossary.ALTERNATIVE_PROPERTY: 1, 
        DialogicGlossary.TEXT_PROPERTY: 2, 
        DialogicGlossary.EXTRA_PROPERTY: 3, 
    }
    const UNKNOWN_PROPERTY_ORDER: = 100

    var value_a: int = GLOSSARY_CSV_LINE_ORDER.get(property_key_a, UNKNOWN_PROPERTY_ORDER)
    var value_b: int = GLOSSARY_CSV_LINE_ORDER.get(property_key_b, UNKNOWN_PROPERTY_ORDER)

    return value_a < value_b




func collect_lines_from_glossary(glossary: DialogicGlossary) -> void :

    for glossary_value: Variant in glossary.entries.values():

        if glossary_value is String:
            continue

        var glossary_entry: Dictionary = glossary_value
        var glossary_entry_name: String = glossary_entry[DialogicGlossary.NAME_PROPERTY]

        var _glossary_translation_id: = glossary.get_set_glossary_translation_id()
        var entry_translation_id: = glossary.get_set_glossary_entry_translation_id(glossary_entry_name)

        var entry_property_keys: = glossary_entry.keys().duplicate()
        entry_property_keys.sort_custom(_sort_glossary_entry_property_keys)

        var entry_name_property: String = glossary_entry[DialogicGlossary.NAME_PROPERTY]

        for entry_key: String in entry_property_keys:

            if entry_key.begins_with(DialogicGlossary.PRIVATE_PROPERTY_PREFIX):
                continue

            var item_value: Variant = glossary_entry[entry_key]
            var item_value_str: = ""

            if item_value is Array:
                var item_array: = item_value as Array

                item_value_str = " ,".join(item_array)

            elif not item_value is String or item_value.is_empty():
                continue

            else:
                item_value_str = item_value

            var glossary_csv_key: = glossary._get_glossary_translation_key(entry_translation_id, entry_key)

            if (entry_key == DialogicGlossary.NAME_PROPERTY
            or entry_key == DialogicGlossary.ALTERNATIVE_PROPERTY):
                glossary.entries[glossary_csv_key] = entry_name_property

            var glossary_line: = PackedStringArray([glossary_csv_key, item_value_str])

            lines.append(glossary_line)


        if add_separator:
            _append_empty()





func collect_lines_from_timeline(timeline: DialogicTimeline) -> void :
    for event: DialogicEvent in timeline.events:

        if event.can_be_translated():

            if event._translation_id.is_empty():
                event.add_translation_id()
                event.update_text_version()

            var properties: Array = event._get_translatable_properties()

            for property: String in properties:
                var line_key: String = event.get_property_translation_key(property)
                var line_value: String = event._get_property_original_translation(property)
                var array_line: = PackedStringArray([line_key, line_value])
                lines.append(array_line)


    if add_separator:
        _append_empty()









func update_csv_file_on_disk() -> void :

    if lines.size() < 2:
        print_rich("[color=yellow]No lines for the CSV file, skipping: " + used_file_path)

        return


    file = FileAccess.open(used_file_path, FileAccess.WRITE)

    for line in lines:
        var row_key: = line[0]



        if row_key in old_lines:
            var old_line: PackedStringArray = old_lines[row_key]
            var updated_line: PackedStringArray = line + old_line.slice(2)

            var line_columns: int = updated_line.size()
            var line_columns_to_add: = column_count - line_columns


            for _i in range(line_columns_to_add):
                updated_line.append("")

            file.store_csv_line(updated_line)
            updated_rows += 1

        else:
            var line_columns: int = line.size()
            var line_columns_to_add: = column_count - line_columns


            for _i in range(line_columns_to_add):
                line.append("")

            file.store_csv_line(line)
            new_rows += 1

    file.close()
