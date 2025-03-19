extends Camera2D
@onready var rand = RandomNumberGenerator.new()
@onready var noise = FastNoiseLite.new()
@export var SHAKE_DECAY_RATE: float = 6.0
var noise_i: float = 0.0
var global

func _ready():
    noise.seed = rand.randi()
    noise.frequency = 0.5
    global = $"/root/Global"

func _process(delta):
    if not Global.settings["screenshake"]:
        Global.shake_strength = 0.0
    var camera_panning = (get_global_mouse_position() - offset) / 100
    if not Global.settings["camerapanning"]:
        camera_panning = Vector2(0, 0)
    var relative_pos = camera_panning + Vector2(960, 540)
    global.shake_strength = lerp(global.shake_strength, 0.0, delta * SHAKE_DECAY_RATE)
    offset = relative_pos + get_noise_offset(delta)

func get_noise_offset(delta):
    noise_i += delta * 5
    return Vector2(
        noise.get_noise_2d(1, noise_i) * global.shake_strength, 
        noise.get_noise_2d(100, noise_i) * global.shake_strength
    )
