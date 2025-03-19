extends GPUParticles2D



func _ready():
    restart()
    await finished
    queue_free()
