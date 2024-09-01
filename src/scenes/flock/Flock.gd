extends Node2D

@export var boids: int = WinArea.SHEEPS_INITIAL_NUMBER
@export var Boid: PackedScene

var _width = ProjectSettings.get_setting("display/window/size/viewport_width")
var _height = ProjectSettings.get_setting("display/window/size/viewport_height")

func _ready():
	var sheeps: Array[Sheep] = []
	for _i in range(boids):
		var boid = Boid.instantiate()
		
		boid.position = Vector2(randf_range(500, 2300), randf_range(500, 2000))
		boid.rotation = randf_range(0, PI * 2)
		add_child(boid, true)
		sheeps.append(boid)
	
	for sheep in sheeps:
		sheep.move_and_slide()
