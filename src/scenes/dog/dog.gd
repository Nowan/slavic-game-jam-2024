extends Sprite2D

var _angular_speed = PI
var _dog_speed = 500.0

var _direction := 0
var _velocity := Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if multiplayer.is_server():
		set_multiplayer_authority(multiplayer.get_unique_id())
	else:
		set_multiplayer_authority(multiplayer.get_peers()[0])
		
	print("Unique id: ", multiplayer.get_unique_id())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		print("I have authority!")
		_direction = 0
		if Input.is_action_pressed("move_left"):
			_direction = -1
		if Input.is_action_pressed("move_right"):
			_direction = 1
		
		_velocity = Vector2.ZERO
		
		if Input.is_action_pressed("move_up"):
			_velocity = Vector2.DOWN.rotated(rotation) * _dog_speed
			
		if Input.is_action_pressed("move_down"):
			_velocity = Vector2.UP.rotated(rotation) * _dog_speed
			
		set_pos_and_motion.rpc(position, rotation, _direction, _velocity)
	else:
		print("I don't!")

	rotation += _angular_speed * _direction * delta
	position += _velocity * delta

@rpc("unreliable")
func set_pos_and_motion(pos: Vector2, rot: float, direction: int, velocity: Vector2) -> void:
	# print(pos)
	# print(rot)
	# print(direction)
	# print(velocity)
	print("set called!")
	position = pos
	rotation = rot
	_direction = direction
	_velocity = velocity
