class_name WinArea
extends Area2D

@export var WinIndicator: PackedScene = null
@export var ui_indicators_parent: Node2D = null

static var SHEEPS_INITIAL_NUMBER := 90
static var INITIAL_PLAYER_NUMBER := 2 # TODO for now

static var deadPlayers := 0
static var deadSheeps := 0

static var currentPlayersInWinArea := 0
static var currentSheepsInWinArea := 0

static var currentLevel := 0;

signal level_changed(level: TextureRect)

# Called when the node enters the scene gtree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#print(str(currentSheepsInWinArea) + " " + str(deadSheeps) + " " 
	#+ str(SHEEPS_INITIAL_NUMBER) + " " + str(currentPlayersInWinArea) + " " 
	#+ str(deadPlayers) + " " + str(INITIAL_PLAYER_NUMBER))

func _on_body_entered(body: Node2D) -> void:
	if (body is Dog):
		currentPlayersInWinArea += 1
	if (body.is_in_group("sheep")):
		var sheep = body as Sheep
		currentSheepsInWinArea += 1
		sheep.set_collision_mask_value(6, true)
		sheep.set_collision_layer_value(6, true)
		_show_win_indicator_above_body(body)
		
		sheep.playWin()
		
	if (currentSheepsInWinArea + deadSheeps == SHEEPS_INITIAL_NUMBER 
	#&& currentPlayersInWinArea + deadPlayers == INITIAL_PLAYER_NUMBER
	):
		currentLevel += 1
		var root = get_parent()
		var audio_player = root.get_node("MusicPlayer") as AudioStreamPlayer
		audio_player.stop()
		$WinSoundPlayer.play()
		#get_tree().change_scene_to_file("res://src/scenes/level_" + str(currentLevel) + "/level_" + str(currentLevel) + ".tscn")
		
		get_tree().change_scene_to_file("res://src/scenes/lobby/lobby.tscn")
		
		root.get_parent().remove_child(root)
		emit_signal("level_changed", get_parent().get_node("ParallaxBackground/ParallaxLayer/TextureRect"))


func _on_body_exited(body: Node2D) -> void:
	if (body is Dog):
		currentPlayersInWinArea -= 1
	if (body.is_in_group("sheep")):
		currentSheepsInWinArea -= 1
		
func _show_win_indicator_above_body(body: Node2D):
	if (ui_indicators_parent != null):
		var win_indicator = WinIndicator.instantiate()
		var position = ui_indicators_parent.to_local(body.global_position)
		var animation_player = win_indicator.find_child("AnimationPlayer") as AnimationPlayer
		
		win_indicator.position = position
		ui_indicators_parent.add_child(win_indicator)
		
		animation_player.play("default")
