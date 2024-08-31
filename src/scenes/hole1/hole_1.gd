extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	#body.queue_free()
	#if (body is Dog):
		#WinArea.deadPlayers += 1
		#remove_from_group("players")
	if (body.is_in_group("sheep")):
		body.queue_free()
		WinArea.deadSheeps += 1
		
	if (WinArea.deadPlayers == WinArea.INITIAL_PLAYER_NUMBER):
		get_tree().quit()
