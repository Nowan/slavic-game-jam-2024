extends Node2D


func _init():
	visible = false


func _input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == MOUSE_BUTTON_LEFT:
			visible = true
			position = event.position
		elif event.get_button_index() == MOUSE_BUTTON_RIGHT:
			visible = false
