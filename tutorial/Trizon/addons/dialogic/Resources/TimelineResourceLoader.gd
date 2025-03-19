@tool
class_name DialogicTimelineFormatLoader
extends ResourceFormatLoader



func _get_recognized_extensions() -> PackedStringArray:
    return PackedStringArray(["dtl"])



func _get_resource_type(path: String) -> String:
    var ext: = path.get_extension().to_lower()
    if ext == "dtl":
        return "Resource"

    return ""



func _get_resource_script_class(path: String) -> String:
    var ext: = path.get_extension().to_lower()
    if ext == "dtl":
        return "DialogicTimeline"

    return ""



func _handles_type(typename: StringName) -> bool:
    return ClassDB.is_parent_class(typename, "Resource")



func _load(path: String, _original_path: String, _use_sub_threads: bool, _cache_mode: int) -> Variant:
    var file: = FileAccess.open(path, FileAccess.READ)

    if not file:


        print("[Dialogic] Error opening file:", FileAccess.get_open_error())
        return FileAccess.get_open_error()

    var tml: = DialogicTimeline.new()
    tml.from_text(file.get_as_text())
    return tml
