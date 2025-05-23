@tool
extends DialogicIndexer


func _get_events() -> Array:
    return []


func _get_editors() -> Array:
    return [this_folder.path_join("glossary_editor.tscn")]

func _get_subsystems() -> Array:
    return [{"name": "Glossary", "script": this_folder.path_join("subsystem_glossary.gd")}]
