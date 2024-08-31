extends CharacterBody2D

@export var max_speed: = 200.0
@export var fleeing_force: = -0.05
@export var calm_down_time: = 5
@export var cohesion_force: = 0.05
@export var algin_force: = 0.05
@export var separation_force: = 0.05
@export var view_distance := 150.0
@export var avoid_distance := 120.0

var _width = ProjectSettings.get_setting("display/window/size/viewport_width")
var _height = ProjectSettings.get_setting("display/window/size/viewport_height")

var _flock: Array = []
var _mouse_target: Vector2
var _velocity: Vector2

var _status: FlockTypes.BoidStatus = FlockTypes.BoidStatus.IDLE
var _dogs_fleeing_from: Array = []

var _calm_down_timer: Timer

func _ready():
	randomize()
	_calm_down_timer = get_node("CalmDownTimer")

	#mouse_follow_force = 0
	#_velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * max_speed
	#_mouse_target = get_random_target()

func set_status(status: FlockTypes.BoidStatus):
	_status = status
	#for f in _flock:
		#if (f != self && f.get_status() != status):
			#f.set_status(status)

func get_status():
	return _status

func _input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == MOUSE_BUTTON_LEFT:
			_mouse_target = event.position
		elif event.get_button_index() == MOUSE_BUTTON_RIGHT:
			_mouse_target = get_random_target()


func _physics_process(delta):
	match _status:
		FlockTypes.BoidStatus.IDLE:
			_physics_process_idle(delta)
		FlockTypes.BoidStatus.FLEEING:
			_physics_process_fleeing(delta)

func _physics_process_idle(delta):
	var mouse_vector = Vector2.ZERO

func _physics_process_fleeing(delta: float):
	var fleeing_vector = Vector2.ZERO
	#if _mouse_target != Vector2.INF:
		#mouse_vector = global_position.direction_to(_mouse_target) * max_speed * fleeing_force
	if _dogs_fleeing_from.size() > 0:
		var positions_fleeing_from = _dogs_fleeing_from.map(func(dog): return dog.position)
		fleeing_vector = global_position.direction_to(_calc_centroid(positions_fleeing_from)) * max_speed * fleeing_force
	## get cohesion, alginment, and separation vectorsw
	
	var vectors = get_flock_status(_flock)
	
	# steer towards vectors
	var cohesion_vector = vectors[0] * cohesion_force
	var align_vector = vectors[1] * algin_force
	var separation_vector = vectors[2] * separation_force

	var acceleration = cohesion_vector + align_vector + separation_vector + fleeing_vector
	
	_velocity = (_velocity + acceleration).limit_length(max_speed)
	
	look_at(position + _velocity)
	rotate(-PI * 0.5)

	#DebugDraw2d.line_vector(position, _velocity);
	
	set_velocity(_velocity)
	move_and_slide()
	_velocity = velocity

func get_flock_status(flock: Array):
	var center_vector: = Vector2()
	var flock_center: = Vector2()
	var align_vector: = Vector2()
	var avoid_vector: = Vector2()
	
	for f in flock:
		var neighbor_pos: Vector2 = f.global_position

		align_vector += f._velocity
		flock_center += neighbor_pos

		var d = global_position.distance_to(neighbor_pos)
		if d > 0 and d < avoid_distance:
			avoid_vector -= (neighbor_pos - global_position).normalized() * (avoid_distance / d * max_speed)
	
	var flock_size = flock.size()
	if flock_size:
		align_vector /= flock_size
		flock_center /= flock_size


		var center_dir = global_position.direction_to(flock_center)
		var center_speed = max_speed * (global_position.distance_to(flock_center) / $FlockView/ViewRadius.shape.radius)
		center_vector = center_dir * center_speed

	return [center_vector, align_vector, avoid_vector]


func get_random_target():
	randomize()
	return Vector2(randf_range(0, _width), randf_range(0, _height))


func _on_flock_view_body_entered(body: Node2D) -> void:
	if body.is_in_group("dog"):
		_dogs_fleeing_from.append(body)
		set_status(FlockTypes.BoidStatus.FLEEING)
		_calm_down_timer.stop()
	elif body.is_in_group("sheep") && self != body:
		_flock.append(body)


func _on_flock_view_body_exited(body: Node2D) -> void:
	if body.is_in_group("dog"):
		_dogs_fleeing_from.remove_at(_dogs_fleeing_from.find(body))

		_calm_down_timer.start(calm_down_time)
		#if _calm_down_timer:
			#_calm_down_timer.cancel_free()
		#_calm_down_timer = get_tree().create_timer(calm_down_time)
		#_calm_down_timer.timeout.connect(set_status.bind(FlockTypes.BoidStatus.IDLE))
		#set_status(FlockTypes.BoidStatus.IDLE)
	elif body.is_in_group("sheep") && self != body:
		_flock.remove_at(_flock.find(body))

func _calc_centroid(points: Array) -> Vector2:
	var centroid : Vector2 = Vector2.ZERO
	for point: Vector2 in points:
		centroid += point
	
	return centroid / points.size()


func _on_calm_down_timer_timeout() -> void:
	set_status(FlockTypes.BoidStatus.IDLE)
