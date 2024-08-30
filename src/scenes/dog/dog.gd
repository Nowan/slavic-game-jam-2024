extends CharacterBody2D

var _angular_speed = PI
var _dog_speed = 500.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var direction = 0
	if Input.is_action_pressed("move_left"):
		direction = -1
	if Input.is_action_pressed("move_right"):
		direction = 1
	
	rotation += _angular_speed * direction * delta
	
	var 	velocity = Vector2.ZERO
	
	#if Input.is_action_pressed("move_up"):
		#velocity = Vector2.DOWN.rotated(rotation) * _dog_speed
		#
	#if Input.is_action_pressed("move_down"):
		#velocity = Vector2.UP.rotated(rotation) * _dog_speed
		
	velocity = (Input.get_action_strength("move_up") - Input.get_action_strength("move_down")) * _dog_speed * transform.y

	set_velocity(velocity)
	
	print(velocity)
	
	move_and_slide()
