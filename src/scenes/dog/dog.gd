extends CharacterBody2D

@export var speed = 500
@export var rotation_speed = 3.5

var rotation_direction = 0

func _physics_process(delta):
	rotation_direction = Input.get_axis("move_left", "move_right")
	velocity = transform.y * Input.get_axis("move_down", "move_up") * speed
	rotation += rotation_direction * rotation_speed * delta
	move_and_slide()
