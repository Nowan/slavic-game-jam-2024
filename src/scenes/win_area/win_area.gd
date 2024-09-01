class_name WinArea
extends Area2D

@export var WinIndicator: PackedScene = null
@export var ui_indicators_parent: Node2D = null

static var SHEEPS_INITIAL_NUMBER := 70
static var INITIAL_PLAYER_NUMBER := 2 # TODO for now

static var deadPlayers := 0
static var deadSheeps := 0

static var currentPlayersInWinArea := 0
static var currentSheepsInWinArea := 0

static var currentLevel := 0;

signal level_changed(level: TextureRect)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(str(currentSheepsInWinArea) + " " + str(deadSheeps) + " " 
	+ str(SHEEPS_INITIAL_NUMBER) + " " + str(currentPlayersInWinArea) + " " 
	+ str(deadPlayers) + " " + str(INITIAL_PLAYER_NUMBER))

func _on_body_entered(body: Node2D) -> void:
	if (body is Dog):
		currentPlayersInWinArea += 1
	if (body.is_in_group("sheep")):
		var sheep = body as Sheep
		currentSheepsInWinArea += 1
		sheep.set_collision_mask_value(6, true)
		sheep.set_collision_layer_value(6, true)
		_show_win_indicator_above_body(sheep)
		
	if (currentSheepsInWinArea + deadSheeps == SHEEPS_INITIAL_NUMBER 
	#&& currentPlayersInWinArea + deadPlayers == INITIAL_PLAYER_NUMBER
	):
		currentLevel += 1
		get_tree().change_scene_to_file("res://src/scenes/level_" + str(currentLevel) + "/level_" + str(currentLevel) + ".tscn")
		emit_signal("level_changed", get_parent().get_node("ParallaxBackground/ParallaxLayer/TextureRect"))


func _on_body_exited(body: Node2D) -> void:
	if (body is Dog):
		currentPlayersInWinArea -= 1
	if (body.is_in_group("sheep")):
		currentSheepsInWinArea -= 1
		
func _show_win_indicator_above_body(body: Node2D):
	var win_indicator = WinIndicator.instantiate()
	var position = ui_indicators_parent.to_local(body.global_position)
	var animation_player = win_indicator.find_child("AnimationPlayer") as AnimationPlayer
	
	win_indicator.position = position
	ui_indicators_parent.add_child(win_indicator)
	
	animation_player.play("default")
