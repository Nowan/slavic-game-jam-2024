extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if (body.is_in_group("sheep")):
		WinArea.deadSheeps += 1
		(body as Sheep).die_from_fall()
		
