extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var alive_sheeps := str(WinArea.SHEEPS_INITIAL_NUMBER - WinArea.deadSheeps)
	$AliveSheeps.text = str(alive_sheeps + "/" + str(WinArea.SHEEPS_INITIAL_NUMBER))
	$WinSheeps.text = str(str(WinArea.currentSheepsInWinArea) + "/" + alive_sheeps)
	$DeadShips.text = str(WinArea.deadSheeps)
