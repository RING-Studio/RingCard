extends WorldEnvironment
@onready var blur_environment = load("res://shader/blur_environment.tres")
@onready var bg_environment = load("res://shader/bg_environment.tres")
@onready var global = $"/root/Global"
@export var mode: String = "bg"

func _enter_tree():

    environment = load("res://shader/bg_environment.tres")
