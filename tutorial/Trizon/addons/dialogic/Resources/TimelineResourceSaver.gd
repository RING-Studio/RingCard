@tool
class_name DialogicTimelineFormatSaver
extends ResourceFormatSaver


func _get_recognized_extensions(_resource: Resource) -> PackedStringArray:
    return PackedStringArray(["dtl"])



func _recognize(resource: Resource) -> bool:

    resource = resource as DialogicTimeline

    if resource:
        return true

    return false




func _save(resource: Resource, path: String = "", _flags: int = 0) -> Error:
    if resource.get_meta("timeline_not_saved", false):

        var timeline_as_text: = ""

        if resource.events_processed:

            var indent: = 0
            for idx in range(0, len(resource.events)):
                if resource.events[idx]:
                    var event: DialogicEvent = resource.events[idx]
                    if event.event_name == "End Branch":
                        indent -= 1
                        continue

                    for i in event.empty_lines_above:
                        timeline_as_text += "	".repeat(indent) + "\n"

                    if event != null:
                        timeline_as_text += "	".repeat(indent) + event.event_node_as_text + "\n"
                    if event.can_contain_events:
                        indent += 1
                    if indent < 0:
                        indent = 0


        else:
            for event in resource.events:
                timeline_as_text += event + "\n"


        var file: = FileAccess.open(path, FileAccess.WRITE)
        if !file:
            print("[Dialogic] Error opening file:", FileAccess.get_open_error())
            return ERR_CANT_OPEN
        file.store_string(timeline_as_text)
        file.close()

    return OK
