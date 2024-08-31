class_name Dog
extends CharacterBody2D

@export var move_right = "ui_right"
@export var move_left = "ui_left"
@export var move_up = "ui_up"
@export var move_down = "ui_down"
@export var use_bark = "ui_accept"
@export var use_dash = "ui_cancel"
@export var bark_max_distance = 500.0
@export var bark_min_distance = 200.0
@export var bark_full_charge_time = 0.4
@export var speed = 500
@export var rotation_speed = 3.5

var direction = Vector2.ZERO

var _bark_cone: VisionCone2D
var _bark_cone_area: Area2D
var _sheep_in_bark_cone: Array[Sheep]
var _bark_pressed_time: float = 0.0

func _ready():
	_bark_cone = get_node("Sprite2D/BarkCone")
	_bark_cone_area = get_node("Sprite2D/BarkCone/BarkConeArea")
	_bark_cone_area.monitoring = false
	_bark_cone_area.monitorable = false
	
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
	
	if Input.is_action_just_pressed(use_bark):
		for sheep in _sheep_in_bark_cone:
			sheep.flee_from_bark(self)
		_bark_cone_area.monitoring = true
		_bark_cone_area.monitorable = true
	
	if Input.is_action_just_pressed(use_dash):
		self.speed *= 2
		
	if Input.is_action_pressed(use_bark):
		_bark_pressed_time += delta
	
	var bark_strength = min(_bark_pressed_time / bark_full_charge_time, 1)
	_bark_cone.max_distance = bark_min_distance + (bark_max_distance - bark_min_distance) * bark_strength if bark_strength else 0;
	
	if Input.is_action_just_released(use_power):
		for sheep in _sheep_in_bark_cone:
			sheep.flee_from_bark(self, bark_strength)
		_bark_cone_area.monitoring = false
		_bark_cone_area.monitorable = false
		_bark_pressed_time = 0


func _on_bark_cone_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("sheep"):
		_sheep_in_bark_cone.append(body)


func _on_bark_cone_area_body_exited(body: Node2D) -> void:
	if (body.is_in_group("sheep")):
		_sheep_in_bark_cone.remove_at(_sheep_in_bark_cone.find(body))
