class_name Dog extends CharacterBody2D

# Dog variables
@export var bark_max_distance = 500.0
@export var bark_min_distance = 200.0
@export var speed = 600.0
@export var rotation_speed = 3.5

# Set by the authority, synchronized on spawn.
@export var player := 1 :
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer.
		$PlayerInput.set_multiplayer_authority(id)
		
@export var player_device: int

# Player synchronized input.
@onready var input = $PlayerInput

var direction = Vector2.ZERO
var bark_full_charge_time = 1.0

var _bark_cone: VisionCone2D
var _bark_cone_area: Area2D
var _sheep_in_bark_cone: Array[Sheep]
var _bark_pressed_time: float = 0.0

var _dash_ready: bool

func _ready():
	_bark_cone = get_node("Body/BarkCone")
	_bark_cone_area = get_node("Body/BarkCone/BarkConeArea")
	_bark_cone_area.monitoring = false
	_bark_cone_area.monitorable = false
	_dash_ready = true
	add_to_group("players")
	
#func rotate_sprite(angle) -> void:
	#$Sprite2D.rotation = angle
	#$DogHitbox.rotation = angle

func _physics_process(delta):
	velocity = speed * input.direction

	if input.direction != Vector2.ZERO:
		$Body.rotation = velocity.angle() - PI / 2

	move_and_slide()

	if input.direction == Vector2.ZERO:
		$AnimationPlayer.play("idle")
		$AnimationPlayer.speed_scale = 1
	else:
		$AnimationPlayer.play("run")
		$AnimationPlayer.speed_scale = 1 if $DashDuration.time_left == 0 else 2
	
	if input.bark_pressed:
		_bark_cone_area.monitoring = true
		_bark_cone_area.monitorable = true

	input.bark_pressed = false

	if input.dash_pressed:
		if _dash_ready == true:
			self.speed *= 2
			$DashDuration.start()
			$DashCooldown.start()
			_dash_ready = false

	input.dash_pressed = false

	if input.barking:
		_bark_pressed_time += delta
	
	var bark_strength = min(_bark_pressed_time / bark_full_charge_time, 1)
	_bark_cone.max_distance = bark_min_distance + (bark_max_distance - bark_min_distance) * bark_strength if bark_strength else 0;
	
	if input.bark_released:
		for sheep in _sheep_in_bark_cone:
			sheep.flee_from_bark(self, bark_strength)
		_bark_cone_area.monitoring = false
		_bark_cone_area.monitorable = false
		_bark_pressed_time = 0
		$AudioStreamPlayer2D.volume_db = bark_strength * 15
		$AudioStreamPlayer2D.play()
		print(bark_strength)
		
	input.bark_released = false


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
