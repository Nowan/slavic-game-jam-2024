extends MultiplayerSynchronizer

# Movement mapping
@export var move_right = "ui_right"
@export var move_left = "ui_left"
@export var move_up = "ui_up"
@export var move_down = "ui_down"
@export var use_bark = "ui_accept"
@export var use_dash = "ui_cancel"

# Synchronized property.
@export var direction := Vector2.ZERO
@export var barking := false

# Set via RPC to simulate is_action_just_pressed.
# !!! WARNING !!! Do NOT add these to synced properties 
@export var bark_pressed := false
@export var bark_released := false
@export var dash_pressed := false

@rpc("call_local", "reliable")
func _bark_pressed():
	bark_pressed = true
	
@rpc("call_local", "reliable")
func _bark_released():
	bark_released = true

@rpc("call_local", "reliable")
func _dash_pressed():
	dash_pressed = true

func _ready() -> void:
	# Only process for the local player.
	# Both frame and physics, in case someone decides to switch where the
	# input is handled.
	set_physics_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

func get_input():
	var input = Vector2.ZERO
	input.x = Input.get_axis(move_left, move_right)
	input.y = Input.get_axis(move_up, move_down)
	return input.normalized()

func _physics_process(delta: float) -> void:
	direction = get_input()	
	barking = Input.is_action_pressed(use_bark)
	
	if Input.is_action_just_pressed(use_bark):
		_bark_pressed.rpc()
	
	if Input.is_action_just_released(use_bark):
		_bark_released.rpc()
	
	if Input.is_action_just_pressed(use_dash):
		_dash_pressed.rpc()
