extends Node2D

@export var boids: int = WinArea.SHEEPS_INITIAL_NUMBER
@export var Boid: PackedScene
#@export var spawn_regions: Array[Area2D] = []

var _width = ProjectSettings.get_setting("display/window/size/viewport_width")
var _height = ProjectSettings.get_setting("display/window/size/viewport_height")

func _ready():
	var spawn_areas = get_children().filter(func(child): return child is Area2D)
	var sheeps: Array[Sheep] = []
	for _i in range(boids):
		var spawn_area = spawn_areas[randi_range(0, spawn_areas.size() - 1)]
		var boid = Boid.instantiate()
		var radius = ((spawn_area.get_child(0) as CollisionShape2D).shape as CircleShape2D).radius
		var spawn_position = spawn_area.position + rand_point_in_circle(radius)

		boid.position = spawn_position
		boid.rotation = randf_range(0, PI * 2)
		add_child(boid, true)
		sheeps.append(boid)
	
	for sheep in sheeps:
		sheep.move_and_slide()

static func rand_point_in_circle(p_radius = 1.0):
	var r = sqrt(randf_range(0.0, 1.0)) * p_radius
	var t = randf_range(0.0, 1.0) * TAU
	return Vector2(r * cos(t), r * sin(t))
