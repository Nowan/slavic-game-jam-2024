extends Node2D

const initDogPositions = {
	0: Vector2(326, 198),
	1: Vector2(604, 195),
	2: Vector2(460, 198),
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# TODO(mlazowik): check behaviour on larger ping/jitter, tweak this
	# if needed
	# Engine.set_physics_ticks_per_second(10)
		
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
	dog.position = initDogPositions[index]
	dog.name = str(index)
	$Players.add_child(dog, true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta: float) -> void:
#	if Input.is_action_pressed("user_power"): show_power_text()
	
	
	

func show_power_text():
	$Dog/BarkTextPlaceholder.text = "WOOF"
	$Dog/BarkTextPlaceholder.visible = true
	$Dog/BarkTimer.start(0.5)


func _on_bark_timer_timeout() -> void:
	$Dog/BarkTextPlaceholder.visible = false
