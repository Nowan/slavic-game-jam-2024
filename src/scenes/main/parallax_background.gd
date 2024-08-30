extends ParallaxBackground


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_texture_repeat(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scroll_offset.x += 1000 * delta
	scroll_offset.y += 1000 * delta
