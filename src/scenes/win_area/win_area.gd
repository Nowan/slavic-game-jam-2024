class_name WinArea
extends Area2D

static var SHEEPS_INITIAL_NUMBER := 20
static var INITIAL_PLAYER_NUMBER := 2 # TODO for now

static var deadPlayers := 0
static var deadSheeps := 0

static var currentPlayersInWinArea := 0
static var currentSheepsInWinArea := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if (body is Player):
		currentPlayersInWinArea += 1
	if (body.is_in_group("sheep")):
		currentSheepsInWinArea += 1
	if (currentSheepsInWinArea + deadSheeps == SHEEPS_INITIAL_NUMBER && currentPlayersInWinArea + deadPlayers == INITIAL_PLAYER_NUMBER):
		get_tree().change_scene_to_file("res://src/scenes/second/second.tscn")


func _on_body_exited(body: Node2D) -> void:
	if (body is Player):
		currentPlayersInWinArea -= 1
	if (body.is_in_group("sheep")):
		currentSheepsInWinArea -= 1
	pass # Replace with function body.
