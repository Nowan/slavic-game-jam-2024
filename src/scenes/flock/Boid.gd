class_name Sheep extends CharacterBody2D

@export var max_speed: = 275.0
@export var fleeing_dog_force: = 0.12
@export var fleeing_dog_bark_force_multiplier: = 40.0
@export var dog_bark_exhaustion_time = 2.5
@export var grazing_force: = 0.3
@export var staying_idle_time_range: = [4, 10]
@export var grazing_time_range: = [2, 10]
@export var fleeing_stop_time: = 5
@export var cohesion_force: = 0.05
@export var algin_force: = 0.05
@export var separation_force: = 0.05
@export var view_distance := 350.0
@export var avoid_distance := 110.0

var _width = ProjectSettings.get_setting("display/window/size/viewport_width")
var _height = ProjectSettings.get_setting("display/window/size/viewport_height")

var _flock: Array[Sheep] = []
var _graze_target: Vector2 = Vector2.INF
var _velocity: Vector2

var _status: FlockTypes.BoidStatus

var _dogs_fleeing_from: Array[Dog] = []
var _barks_fleeting_from: Array = []

var _fleeing_stop_timer: Timer
var _grazing_timer: Timer

func _ready():
	_fleeing_stop_timer = get_node("FleeingStopTimer")
	_grazing_timer = get_node("GrazingTimer")
	
	_fleeing_stop_timer.connect("timeout", set_status.bind(FlockTypes.BoidStatus.IDLE))
	_grazing_timer.connect("timeout", _switch_idle_or_graze)
	
	set_status(FlockTypes.BoidStatus.IDLE)
	_graze_target = get_random_target()
	
	#mouse_follow_force = 0
	#_velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * max_speed
	#_mouse_target = get_random_target()

func set_status(status: FlockTypes.BoidStatus):
	_status = status
	match _status:
		FlockTypes.BoidStatus.IDLE:
			$AnimationPlayer.play("idle")
			_barks_fleeting_from.clear()
			_dogs_fleeing_from.clear()
			_wait_and_graze()
		FlockTypes.BoidStatus.GRAZING:
			$AnimationPlayer.play("move")
			_barks_fleeting_from.clear()
			_dogs_fleeing_from.clear()
			_wait_and_stand()
		FlockTypes.BoidStatus.FLEEING:
			$AnimationPlayer.play("move")
	# Uncomment to have sheep setting status of all other sheep in a flock recursively
	# for f in _flock:
		# if (f != self && f.get_status() != status):
			# f.set_status(status)

func get_status():
	return _status

func playWin():
	$SheepEnteredSoundPlayer.play()

func flee_from_bark(dog: Dog, bark_strength: float):
	$AudioStreamPlayer2D.play()
	_barks_fleeting_from.append([dog.position, bark_strength, 0])
	set_status(FlockTypes.BoidStatus.FLEEING)

func die_from_fall():
	$AnimationPlayer.play("death_ravine_fall")
	$AnimationPlayer.connect("animation_finished", queue_free)

func _physics_process(delta):
	match _status:
		FlockTypes.BoidStatus.IDLE:
			_physics_process_idle(delta)
		FlockTypes.BoidStatus.GRAZING:
			_physics_process_grazing(delta)
		FlockTypes.BoidStatus.FLEEING:
			_physics_process_fleeing(delta)

func _physics_process_idle(delta):
	pass # do nothing
	
func _physics_process_grazing(delta):
	var vectors = get_flock_status(_flock)
	
	# steer towards vectors
	var cohesion_vector = vectors[0] * cohesion_force * 0.2
	var align_vector = vectors[1] * algin_force * 0.2
	var separation_vector = vectors[2] * separation_force * 5

	var acceleration = cohesion_vector + align_vector + separation_vector
	var grazing_progress = _grazing_timer.time_left / _grazing_timer.wait_time
	
	_velocity = (_velocity + acceleration * sin(grazing_progress * PI) * 5).limit_length(max_speed)
	
	if _velocity.length() > 1:
		look_at(position + _velocity)

	#DebugDraw2d.line_vector(position, _velocity);
	
	set_velocity(_velocity)
	move_and_slide()
	
	_velocity = velocity
	

func _physics_process_fleeing(delta: float):
	var fleeing_vector = Vector2.ZERO

	if _dogs_fleeing_from.size() > 0:
		var positions_fleeing_from = _dogs_fleeing_from.map(func(dog): return dog.position)
		fleeing_vector = global_position.direction_to(_calc_centroid(positions_fleeing_from)) * max_speed * fleeing_dog_force * -1
		#for dog in _dogs_fleeing_from:
			#var position_fleeing_from = dog.position
			#var fleeing_force = (1 - minf(position.distance_to(position_fleeing_from) / view_distance, 1.0) + 0.1) * 2
#
			#fleeing_vector = global_position.direction_to(position_fleeing_from) * max_speed * fleeing_force * -1
			#
	if _barks_fleeting_from.size() > 0:
		for bark_entry in _barks_fleeting_from:
			var bark_position = bark_entry[0]
			var bark_strength = bark_entry[1]
			var bark_elapsed_time = bark_entry[2]
			var bark_exhaustion_force = 1.0 - minf(bark_elapsed_time / dog_bark_exhaustion_time, 1.0)
			
			fleeing_vector += global_position.direction_to(bark_position) * bark_strength * -1 * fleeing_dog_bark_force_multiplier * bark_exhaustion_force
			
			bark_entry[2] += delta
			
	## get cohesion, alginment, and separation vectorsw
	var vectors = get_flock_status(_flock)
	
	# steer towards vectors
	var cohesion_vector = vectors[0] * cohesion_force
	var align_vector = vectors[1] * algin_force
	var separation_vector = vectors[2] * separation_force

	var acceleration = cohesion_vector + align_vector + separation_vector + fleeing_vector
	
	_velocity = (_velocity + acceleration).limit_length(max_speed)
	
	look_at(position + _velocity)

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
	return Vector2(randf_range(0, _width), randf_range(0, _height))


func _on_flock_view_body_entered(body: Node2D) -> void:
	if body.is_in_group("dog"):
		_dogs_fleeing_from.append(body)
		set_status(FlockTypes.BoidStatus.FLEEING)
		_fleeing_stop_timer.stop()
	elif body.is_in_group("sheep") && self != body:
		_flock.append(body)


func _on_flock_view_body_exited(body: Node2D) -> void:
	if body.is_in_group("dog"):
		_dogs_fleeing_from.remove_at(_dogs_fleeing_from.find(body))

		_fleeing_stop_timer.start(fleeing_stop_time)
	elif body.is_in_group("sheep") && self != body:
		_flock.remove_at(_flock.find(body))

func _calc_centroid(points: Array) -> Vector2:
	var centroid : Vector2 = Vector2.ZERO
	for point: Vector2 in points:
		centroid += point
	
	return centroid / points.size()

func _switch_idle_or_graze():
	match _status:
		FlockTypes.BoidStatus.IDLE:
			set_status(FlockTypes.BoidStatus.GRAZING)
		FlockTypes.BoidStatus.GRAZING:
			set_status(FlockTypes.BoidStatus.IDLE)

func _wait_and_graze():
	_grazing_timer.stop()
	_grazing_timer.start(randf_range(staying_idle_time_range[0], staying_idle_time_range[1]))

func _wait_and_stand():
	_grazing_timer.stop()
	_grazing_timer.start(randf_range(grazing_time_range[0], grazing_time_range[1]))
