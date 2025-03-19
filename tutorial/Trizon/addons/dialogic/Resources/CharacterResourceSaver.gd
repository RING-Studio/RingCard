@tool
class_name DialogicCharacterFormatSaver
extends ResourceFormatSaver


func _get_recognized_extensions(_resource: Resource) -> PackedStringArray:
    return PackedStringArray(["dch"])



func _recognize(resource: Resource) -> bool:

    resource = resource as DialogicCharacter

    if resource:
        return true

    return false



func _save(resource: Resource, path: String = "", _flags: int = 0) -> Error:
    var file: = FileAccess.open(path, FileAccess.WRITE)

    if not file:


        print("[Dialogic] Error opening file:", FileAccess.get_open_error())
        return FileAccess.get_open_error()

    var result: = var_to_str(inst_to_dict(resource))
    file.store_string(result)

    return OK
