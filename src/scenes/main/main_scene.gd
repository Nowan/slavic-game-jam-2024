extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if Input.is_action_pressed("user_power"): show_power_text()
	

func show_power_text():
	$Dog/BarkTextPlaceholder.text = "Bark"
	$Dog/BarkTextPlaceholder.visible = true
	$Dog/BarkTimer.start(0.5)


func _on_bark_timer_timeout() -> void:
	$Dog/BarkTextPlaceholder.visible = false
