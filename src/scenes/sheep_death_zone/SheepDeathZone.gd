extends Area2D

@export var DeathIndicator: PackedScene = null
@export var ui_indicators_parent: Node2D = null

func _on_body_entered(body: Node2D) -> void:
	if (body.is_in_group("sheep")):
		$AudioStreamPlayer.play()
		WinArea.deadSheeps += 1
		#(body as Sheep).die_from_fall()
		body.queue_free()
		_show_death_indicator_above_body(body)
		
func _show_death_indicator_above_body(body: Node2D):
	if ui_indicators_parent != null:
		var death_indicator = DeathIndicator.instantiate()
		var position = ui_indicators_parent.to_local(body.global_position)
		var animation_player = death_indicator.find_child("AnimationPlayer") as AnimationPlayer
		
		death_indicator.position = position
		ui_indicators_parent.add_child(death_indicator)
		
		animation_player.play("default")
