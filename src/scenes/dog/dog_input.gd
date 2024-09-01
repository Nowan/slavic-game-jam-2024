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
	if not multiplayer.has_multiplayer_peer():
		var dog = get_parent()
		
		if dog.name == "0":
			move_right = "move_right_player1"
			move_left = "move_left_player1"
			move_up = "move_up_player1"
			move_down = "move_down_player1"
			use_bark = "bark_player1"
			use_dash = "dash_player1"
		
		if dog.name == "1":
			move_right = "move_right_player2"
			move_left = "move_left_player2"
			move_up = "move_up_player2"
			move_down = "move_down_player2"
			use_bark = "bark_player2"
			use_dash = "dash_player2"
			
		if dog.name == "2":
			move_right = "move_right_player3"
			move_left = "move_left_player3"
			move_up = "move_up_player3"
			move_down = "move_down_player3"
			use_bark = "bark_player3"
			use_dash = "dash_player3"
		
		return
	
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
		if not multiplayer.has_multiplayer_peer():
			_bark_pressed()
		else:
			_bark_pressed.rpc()
	
	if Input.is_action_just_released(use_bark):
		if not multiplayer.has_multiplayer_peer():
			_bark_released()
		else:
			_bark_released.rpc()
	
	if Input.is_action_just_pressed(use_dash):
		if not multiplayer.has_multiplayer_peer():
			_dash_pressed()
		else:
			_dash_pressed.rpc()
