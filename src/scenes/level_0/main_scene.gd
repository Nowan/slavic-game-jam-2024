extends Node2D

const FIRST_DOG_INITAL_POSITION = Vector2(320, 200)
const DOG_INITIAL_POSITION_OFFSET = Vector2(130, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# TODO(mlazowik): check behaviour on larger ping/jitter, tweak this
	# if needed
	# Engine.set_physics_ticks_per_second(10)
		
	if not multiplayer.has_multiplayer_peer():
		# keyboard
		add_local_player(0)
		
		for controller_id in Input.get_connected_joypads():
			if controller_id == 0:
				# first controller is an alternative to keyboard
				continue
			
			print(controller_id)
			add_local_player(controller_id)
		
		return
		
	if not multiplayer.is_server():
		return
		
	print("am server!")
	
	var index = 0
	for id in multiplayer.get_peers():
		print("add player " + str(id))
		add_player(id, index)
		index += 1


func add_player(id: int, index: int):
	var dog = preload("res://src/scenes/dog/Dog.tscn").instantiate()
	dog.player = id
	dog.position = FIRST_DOG_INITAL_POSITION + index * DOG_INITIAL_POSITION_OFFSET
	dog.name = str(index)
	$Players.add_child(dog, true)
	
func add_local_player(index: int):
	var dog = preload("res://src/scenes/dog/Dog.tscn").instantiate()
	dog.position = FIRST_DOG_INITAL_POSITION + index * DOG_INITIAL_POSITION_OFFSET
	dog.name = str(index)
	dog.player_device = index
	_add_local_device_mapping(index)
	$Players.add_child(dog, true)

# TODO(mlazowik): safe to remove? This script was not even conntected before
# my changes.
	
# TODO(mlazowik): safe to remove? This script was not even conntected before
# my changes.
func show_power_text():
	$Dog/BarkTextPlaceholder.text = "WOOF"
	$Dog/BarkTextPlaceholder.visible = true
	$Dog/BarkTimer.start(0.5)

# TODO(mlazowik): safe to remove? This script was not even conntected before
# my changes.
func _on_bark_timer_timeout() -> void:
	$Dog/BarkTextPlaceholder.visible = false

func _add_local_device_mapping(device: int) -> void:
	
	var move_right = "move_right_%s" % device
	var move_left = "move_left_%s" % device
	var move_up = "move_up_%s" % device
	var move_down = "move_down_%s" % device
	var use_bark = "use_bark_%s" % device
	var use_dash = "use_dash_%s" % device
	
	InputMap.add_action(move_right, 0.2)
	InputMap.add_action(move_left, 0.2)
	InputMap.add_action(move_up, 0.2)
	InputMap.add_action(move_down, 0.2)
	InputMap.add_action(use_bark, 0.2)
	InputMap.add_action(use_dash, 0.2)
	
	var move_right_event_joypad = InputEventJoypadMotion.new()
	move_right_event_joypad.device = device
	move_right_event_joypad.axis = JOY_AXIS_LEFT_X
	move_right_event_joypad.axis_value = 1.0
	
	var move_left_event_joypad = InputEventJoypadMotion.new()
	move_left_event_joypad.device = device
	move_left_event_joypad.axis = JOY_AXIS_LEFT_X
	move_left_event_joypad.axis_value = -1.0

	var move_down_event_joypad = InputEventJoypadMotion.new()
	move_down_event_joypad.device = device
	move_down_event_joypad.axis = JOY_AXIS_LEFT_Y
	move_down_event_joypad.axis_value = 1.0
	
	var move_up_event_joypad = InputEventJoypadMotion.new()
	move_up_event_joypad.device = device
	move_up_event_joypad.axis = JOY_AXIS_LEFT_Y
	move_up_event_joypad.axis_value = -1.0
	
	var use_bark_event_joypad = InputEventJoypadButton.new()
	use_bark_event_joypad.device = device
	use_bark_event_joypad.button_index = JOY_BUTTON_RIGHT_SHOULDER
	
	var use_dash_event_joypad = InputEventJoypadButton.new()
	use_dash_event_joypad.device = device
	use_dash_event_joypad.button_index = JOY_BUTTON_LEFT_SHOULDER
	
	if device == 0:
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
		
		InputMap.action_add_event(move_right, move_right_event_keyboard)
		InputMap.action_add_event(move_left, move_left_event_keyboard)
		InputMap.action_add_event(move_up, move_up_event_keyboard)
		InputMap.action_add_event(move_down, move_down_event_keyboard)
		InputMap.action_add_event(use_bark, use_bark_event_keyboard)
		InputMap.action_add_event(use_dash, use_dash_event_keyboard)
		
	InputMap.action_add_event(move_right, move_right_event_joypad)
	InputMap.action_add_event(move_left, move_left_event_joypad)
	InputMap.action_add_event(move_up, move_up_event_joypad)
	InputMap.action_add_event(move_down, move_down_event_joypad)
	InputMap.action_add_event(use_bark, use_bark_event_joypad)
	InputMap.action_add_event(use_dash, use_dash_event_joypad)
	
	print("Added device mapping for device %s" % device)
