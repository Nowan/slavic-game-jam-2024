class_name Player extends CharacterBody2D

@export var move_right = "ui_right"
@export var move_left = "ui_left"
@export var move_up = "ui_up"
@export var move_down = "ui_down"
@export var use_power = "ui_accept"

@export var speed = 500
@export var rotation_speed = 3.5

var direction = Vector2.ZERO

var _bark_cone: VisionCone2D
var _sheep_in_bark_cone: Array[Sheep]

func _ready():
	_bark_cone = get_node("Sprite2D/BarkCone")
	
func get_input():
	var input = Vector2.ZERO
	input.x = Input.get_axis(move_left, move_right)
	input.y = Input.get_axis(move_up, move_down)
	return input.normalized()
	
func rotate_sprite(angle) -> void:
	$Sprite2D.rotation = angle
	$DogHitbox.rotation = angle

func _physics_process(delta):
	print(WinArea.SHEEPS_INITIAL_NUMBER)
	direction = get_input()
	velocity = speed * direction
	rotate_sprite(velocity.angle() - PI / 2)
	
	move_and_slide()
	
	if Input.is_action_just_pressed(use_power):
		for sheep in _sheep_in_bark_cone:
			sheep.flee_from_bark(self)
	

func _on_bark_cone_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("sheep"):
		_sheep_in_bark_cone.append(body)


func _on_bark_cone_area_body_exited(body: Node2D) -> void:
	if (body.is_in_group("sheep")):
		_sheep_in_bark_cone.remove_at(_sheep_in_bark_cone.find(body))
