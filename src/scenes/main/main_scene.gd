extends Node2D

const FIRST_DOG_INITAL_POSITION = Vector2(320, 200)
const DOG_INITIAL_POSITION_OFFSET = Vector2(130, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# TODO(mlazowik): check behaviour on larger ping/jitter, tweak this
	# if needed
	# Engine.set_physics_ticks_per_second(10)
		
	if not multiplayer.has_multiplayer_peer():
		add_local_player(0)
		add_local_player(1)
		add_local_player(2)
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
	
	var move_right_event = InputEventJoypadMotion.new()
	move_right_event.device = device
	move_right_event.axis = JOY_AXIS_LEFT_X
	move_right_event.axis_value = 1.0
	
	var move_left_event = InputEventJoypadMotion.new()
	move_left_event.device = device
	move_left_event.axis = JOY_AXIS_LEFT_X
	move_left_event.axis_value = -1.0

	var move_down_event = InputEventJoypadMotion.new()
	move_down_event.device = device
	move_down_event.axis = JOY_AXIS_LEFT_Y
	move_down_event.axis_value = 1.0
	
	var move_up_event = InputEventJoypadMotion.new()
	move_up_event.device = device
	move_up_event.axis = JOY_AXIS_LEFT_Y
	move_up_event.axis_value = -1.0
	
	var use_bark_event = InputEventJoypadButton.new()
	use_bark_event.device = device
	use_bark_event.button_index = JOY_BUTTON_RIGHT_SHOULDER
	
	var use_dash_event = InputEventJoypadButton.new()
	use_dash_event.device = device
	use_dash_event.button_index = JOY_BUTTON_LEFT_SHOULDER
		
	InputMap.action_add_event(move_right, move_right_event)
	InputMap.action_add_event(move_left, move_left_event)
	InputMap.action_add_event(move_up, move_up_event)
	InputMap.action_add_event(move_down, move_down_event)
	InputMap.action_add_event(use_bark, use_bark_event)
	InputMap.action_add_event(use_dash, use_dash_event)
	
	print("Added device mapping for device %s" % device)
