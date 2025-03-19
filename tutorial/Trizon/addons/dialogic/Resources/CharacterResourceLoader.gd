@tool
class_name DialogicCharacterFormatLoader
extends ResourceFormatLoader




func _get_recognized_extensions() -> PackedStringArray:
    return PackedStringArray(["dch"])



func _get_resource_type(path: String) -> String:
    var ext: = path.get_extension().to_lower()
    if ext == "dch":
        return "Resource"

    return ""



func _get_resource_script_class(path: String) -> String:
    var ext: = path.get_extension().to_lower()
    if ext == "dch":
        return "DialogicCharacter"

    return ""



func _handles_type(typename: StringName) -> bool:
    return ClassDB.is_parent_class(typename, "Resource")



func _load(path: String, _original_path: String, _use_sub_threads: bool, _cache_mode: int) -> Variant:

    var file: = FileAccess.open(path, FileAccess.READ)

    if not file:


        print("[Dialogic] Error opening file:", FileAccess.get_open_error())
        return FileAccess.get_open_error()

    return dict_to_inst(str_to_var(file.get_as_text()))


func _get_dependencies(path: String, _add_type: bool) -> PackedStringArray:
    var depends_on: PackedStringArray = []
    var character: DialogicCharacter = load(path)
    for p in character.portraits.values():
        if "path" in p and p.path:
            depends_on.append(p.path)
    return depends_on


func _rename_dependencies(path: String, renames: Dictionary) -> Error:
    var character: DialogicCharacter = load(path)
    for p in character.portraits:
        if "path" in character.portraits[p] and character.portraits[p].path in renames:
            character.portraits[p].path = renames[character.portraits[p].path]
    ResourceSaver.save(character, path)
    return OK
