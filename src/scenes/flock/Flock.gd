extends Node2D

@export var boids: int = 5
@export var Boid: PackedScene

var _width = ProjectSettings.get_setting("display/window/size/viewport_width")
var _height = ProjectSettings.get_setting("display/window/size/viewport_height")

func _ready():
	for _i in range(boids):
		randomize()
		var boid = Boid.instantiate()
		
		boid.position = Vector2(randf_range(0, 100), randf_range(0, 100))
		add_child(boid)
		
		
