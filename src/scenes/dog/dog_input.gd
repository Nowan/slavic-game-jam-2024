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
		
		#move_right = "move_right_%s" % dog.player_device
		#move_left = "move_left_%s" % dog.player_device
		#move_up = "move_up_%s" % dog.player_device
		#move_down = "move_down_%s" % dog.player_device
		#use_bark = "use_bark_%s" % dog.player_device
		#use_dash = "use_dash_%s" % dog.player_device
		
		return
		
	_add_multiplayer_device_mapping()
	
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

func _add_multiplayer_device_mapping() -> void:
	InputMap.add_action(move_right, 0.2)
	InputMap.add_action(move_left, 0.2)
	InputMap.add_action(move_up, 0.2)
	InputMap.add_action(move_down, 0.2)
	InputMap.add_action(use_bark, 0.2)
	InputMap.add_action(use_dash, 0.2)
	
	var move_right_event_joypad = InputEventJoypadMotion.new()
	move_right_event_joypad.device = 0
	move_right_event_joypad.axis = JOY_AXIS_LEFT_X
	move_right_event_joypad.axis_value = 1.0
	
	var move_left_event_joypad = InputEventJoypadMotion.new()
	move_left_event_joypad.device = 0
	move_left_event_joypad.axis = JOY_AXIS_LEFT_X
	move_left_event_joypad.axis_value = -1.0

	var move_down_event_joypad = InputEventJoypadMotion.new()
	move_down_event_joypad.device = 0
	move_down_event_joypad.axis = JOY_AXIS_LEFT_Y
	move_down_event_joypad.axis_value = 1.0
	
	var move_up_event_joypad = InputEventJoypadMotion.new()
	move_up_event_joypad.device = 0
	move_up_event_joypad.axis = JOY_AXIS_LEFT_Y
	move_up_event_joypad.axis_value = -1.0
	
	var use_bark_event_joypad = InputEventJoypadButton.new()
	use_bark_event_joypad.device = 0
	use_bark_event_joypad.button_index = JOY_BUTTON_RIGHT_SHOULDER
	
	var use_dash_event_joypad = InputEventJoypadButton.new()
	use_dash_event_joypad.device = 0
	use_dash_event_joypad.button_index = JOY_BUTTON_LEFT_SHOULDER
	
	var move_right_event_keyboard = InputEventKey.new()
	move_right_event_keyboard.physical_keycode = KEY_D
	
	var move_left_event_keyboard = InputEventKey.new()
	move_left_event_keyboard.physical_keycode = KEY_A

	var move_down_event_keyboard = InputEventKey.new()
	move_down_event_keyboard.physical_keycode = KEY_S
	
	var move_up_event_keyboard = InputEventKey.new()
	move_up_event_keyboard.physical_keycode = KEY_W
	
	var use_bark_event_keyboard = InputEventKey.new()
	use_bark_event_keyboard.physical_keycode = KEY_SPACE
	
	var use_dash_event_keyboard = InputEventKey.new()
	use_dash_event_keyboard.physical_keycode = KEY_SHIFT
		
	InputMap.action_add_event(move_right, move_right_event_joypad)
	InputMap.action_add_event(move_right, move_right_event_keyboard)
	
	InputMap.action_add_event(move_left, move_left_event_joypad)
	InputMap.action_add_event(move_left, move_left_event_keyboard)
	
	InputMap.action_add_event(move_up, move_up_event_joypad)
	InputMap.action_add_event(move_up, move_up_event_keyboard)
	
	InputMap.action_add_event(move_down, move_down_event_joypad)
	InputMap.action_add_event(move_down, move_down_event_keyboard)
	
	InputMap.action_add_event(use_bark, use_bark_event_joypad)
	InputMap.action_add_event(use_bark, use_bark_event_keyboard)
	
	InputMap.action_add_event(use_dash, use_dash_event_joypad)
	InputMap.action_add_event(use_dash, use_dash_event_keyboard)
