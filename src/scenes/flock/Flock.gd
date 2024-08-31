extends Node2D

@export var boids: int = 20
@export var Boid: PackedScene

enum State {IDLE, FLEEING}

var _width = ProjectSettings.get_setting("display/window/size/viewport_width")
var _height = ProjectSettings.get_setting("display/window/size/viewport_height")

var _state = State.IDLE;

func _ready():
	for _i in range(boids):
		randomize()
		var boid = Boid.instantiate()
		boid.position = Vector2(randf_range(0, _width), randf_range(0, _height))
		boid.set_status(FlockTypes.BoidStatus.IDLE)
		add_child(boid)
		
		
