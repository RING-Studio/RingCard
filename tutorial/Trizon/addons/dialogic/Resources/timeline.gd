@tool
extends Resource
class_name DialogicTimeline




var events: Array = []
var events_processed: = false



func _to_string() -> String:
    return "[DialogicTimeline:{file}]".format({"file": resource_path})



func get_event(index: int) -> Variant:
    if index >= len(events):
        return null
    return events[index]




func from_text(text: String) -> void :
    events = text.split("\n", true)
    events_processed = false



func as_text() -> String:
    var result: = ""

    if events_processed:
        var indent: = 0
        for idx in range(0, len(events)):
            var event: DialogicEvent = events[idx]

            if event.event_name == "End Branch":
                indent -= 1
                continue

            if event != null:
                for i in event.empty_lines_above:
                    result += "	".repeat(indent) + "\n"
                result += "	".repeat(indent) + event.event_node_as_text.replace("\n", "\n" + "	".repeat(indent)) + "\n"
            if event.can_contain_events:
                indent += 1
            if indent < 0:
                indent = 0
    else:
        for event in events:
            result += str(event) + "\n"

        result.trim_suffix("\n")

    return result.strip_edges()



func process() -> void :
    if typeof(events[0]) == TYPE_STRING:
        events_processed = false


    if events_processed:
        for event in events:
            event.event_node_ready = true
        return

    var event_cache: = DialogicResourceUtil.get_event_cache()
    var end_event: = DialogicEndBranchEvent.new()

    var prev_indent: = ""
    var processed_events: = []


    var prev_was_opener: = false

    var lines: = events
    var idx: = -1
    var empty_lines: = 0
    while idx < len(lines) - 1:
        idx += 1


        var line: = ""
        if typeof(lines[idx]) == TYPE_STRING:
            line = lines[idx]
        else:
            line = lines[idx].event_node_as_text


        var line_stripped: String = line.strip_edges(true, false)
        if line_stripped.is_empty():
            empty_lines += 1
            continue


        var indent: String = line.substr(0, len(line) - len(line_stripped))
        if len(indent) < len(prev_indent):
            for i in range(len(prev_indent) - len(indent)):
                processed_events.append(end_event.duplicate())


        if prev_was_opener and len(indent) <= len(prev_indent):
            processed_events.append(end_event.duplicate())

        prev_indent = indent



        var event_content: String = line_stripped
        var event: DialogicEvent
        for i in event_cache:
            if i._test_event_string(event_content):
                event = i.duplicate()
                break

        event.empty_lines_above = empty_lines

        while !event.is_string_full_event(event_content):
            idx += 1
            if idx == len(lines):
                break

            var following_line_stripped: String = lines[idx].strip_edges(true, false)

            if following_line_stripped.is_empty():
                break

            event_content += "\n" + following_line_stripped

        event._load_from_string(event_content)
        event.event_node_as_text = event_content

        processed_events.append(event)
        prev_was_opener = event.can_contain_events
        empty_lines = 0

    if !prev_indent.is_empty():
        for i in range(len(prev_indent)):
            processed_events.append(end_event.duplicate())

    events = processed_events
    events_processed = true



func clean() -> void :
    if not events_processed:
        return
    reference()


    await Engine.get_main_loop().process_frame

    for event: DialogicEvent in events:
        for con_in in event.get_incoming_connections():
            con_in.signal .disconnect(con_in.callable)

        for sig in event.get_signal_list():
            for con_out in event.get_signal_connection_list(sig.name):
                con_out.signal .disconnect(con_out.callable)
    unreference()
