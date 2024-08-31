extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var alive_sheeps := str(WinArea.SHEEPS_INITIAL_NUMBER - WinArea.deadSheeps)
	$AliveSheeps.text = str("Alive sheeps: " + alive_sheeps + "/" + str(WinArea.SHEEPS_INITIAL_NUMBER))
	$WinSheeps.text = str("Win sheeps: " + str(WinArea.currentSheepsInWinArea) + "/" + alive_sheeps)
	$AlivePlayers.text = str("Alive players: " + str(WinArea.INITIAL_PLAYER_NUMBER - WinArea.deadPlayers))
	$WinPlayers.text = str("Win players: " + str(WinArea.currentPlayersInWinArea))
