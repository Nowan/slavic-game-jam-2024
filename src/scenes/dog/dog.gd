extends CharacterBody2D

@export var move_right = "ui_right"
@export var move_left = "ui_left"
@export var move_up = "ui_up"
@export var move_down = "ui_down"
@export var use_power = "ui_accept"

@export var speed = 500
@export var rotation_speed = 3.5

var direction = Vector2.ZERO

func get_input():
	var input = Vector2.ZERO
	input.x = Input.get_axis(move_left, move_right)
	input.y = Input.get_axis(move_up, move_down)
	return input.normalized()
	
func rotate_sprite(angle) -> void:
	$Sprite2D.rotation = angle
	$DogHitbox.rotation = angle

func _physics_process(delta):
	direction = get_input()
	velocity = speed * direction
	rotate_sprite(velocity.angle() - PI / 2)
	
	move_and_slide()
