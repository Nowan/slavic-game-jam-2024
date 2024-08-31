class_name Dog extends CharacterBody2D

# Movement mapping
@export var move_right = "ui_right"
@export var move_left = "ui_left"
@export var move_up = "ui_up"
@export var move_down = "ui_down"
@export var use_bark = "ui_accept"
@export var use_dash = "ui_cancel"

# Dog variables
@export var bark_max_distance = 500.0
@export var bark_min_distance = 200.0
@export var speed = 600.0
@export var rotation_speed = 3.5

var direction = Vector2.ZERO
var bark_full_charge_time = 1.0

var _bark_cone: VisionCone2D
var _bark_cone_area: Area2D
var _sheep_in_bark_cone: Array[Sheep]
var _bark_pressed_time: float = 0.0

var _dash_ready: bool

func _ready():
	_bark_cone = get_node("Sprite2D/BarkCone")
	_bark_cone_area = get_node("Sprite2D/BarkCone/BarkConeArea")
	_bark_cone_area.monitoring = false
	_bark_cone_area.monitorable = false
	_dash_ready = true
	add_to_group("players")
	
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
	if direction != Vector2.ZERO:
		rotate_sprite(velocity.angle() - PI / 2)
	
	move_and_slide()
	
	if Input.is_action_just_pressed(use_bark):
		_bark_cone_area.monitoring = true
		_bark_cone_area.monitorable = true
	
	if Input.is_action_just_pressed(use_dash):
		if _dash_ready == true:
			self.speed *= 2
			$DashDuration.start()
			$DashCooldown.start()
			_dash_ready = false
		
	if Input.is_action_pressed(use_bark):
		_bark_pressed_time += delta
	
	var bark_strength = min(_bark_pressed_time / bark_full_charge_time, 1)
	_bark_cone.max_distance = bark_min_distance + (bark_max_distance - bark_min_distance) * bark_strength if bark_strength else 0;
	
	if Input.is_action_just_released(use_bark):
		for sheep in _sheep_in_bark_cone:
			sheep.flee_from_bark(self, bark_strength)
		_bark_cone_area.monitoring = false
		_bark_cone_area.monitorable = false
		_bark_pressed_time = 0
		$AudioStreamPlayer2D.play()
		


func _on_bark_cone_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("sheep"):
		_sheep_in_bark_cone.append(body)


func _on_bark_cone_area_body_exited(body: Node2D) -> void:
	if (body.is_in_group("sheep")):
		_sheep_in_bark_cone.remove_at(_sheep_in_bark_cone.find(body))
		
func _on_dash_timer_timeout() -> void:
	speed /= 2
	$DashDuration.stop()

func _on_dash_cooldown_timeout() -> void:
	_dash_ready = true
	$DashCooldown.stop()
