class_name DialogicSubsystem
extends Node

var dialogic: DialogicGameHandler = null

enum LoadFlags{FULL_LOAD, ONLY_DNODES}



func post_install() -> void :
    pass




func clear_game_state(_clear_flag: = DialogicGameHandler.ClearFlags.FULL_CLEAR) -> void :
    pass





func load_game_state(_load_flag: = LoadFlags.FULL_LOAD) -> void :
    pass





func save_game_state() -> void :
    pass



func pause() -> void :
    pass



func resume() -> void :
    pass
