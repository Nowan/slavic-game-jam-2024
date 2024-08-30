extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.set_physics_ticks_per_second(10)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_pressed("user_power"): show_power_text()
	
	
	

func show_power_text():
	$Dog/BarkTextPlaceholder.text = "WOOF"
	$Dog/BarkTextPlaceholder.visible = true
	$Dog/BarkTimer.start(0.5)


func _on_bark_timer_timeout() -> void:
	$Dog/BarkTextPlaceholder.visible = false
