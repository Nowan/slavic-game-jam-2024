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

# Set via RPC to simulate is_action_just_pressed.
@export var barking := false
@export var dashing := false

@rpc("call_local", "reliable")
func bark():
	barking = true

@rpc("call_local", "reliable")
func dash():
	dashing = true

func _ready() -> void:
	# Only process for the local player.
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

func get_input():
	var input = Vector2.ZERO
	input.x = Input.get_axis(move_left, move_right)
	input.y = Input.get_axis(move_up, move_down)
	return input.normalized()

func _physics_process(delta: float) -> void:
	direction = get_input()
	
	if Input.is_action_just_pressed(use_bark):
		bark.rpc()
		
	if Input.is_action_just_pressed(use_dash):
		dash.rpc()
