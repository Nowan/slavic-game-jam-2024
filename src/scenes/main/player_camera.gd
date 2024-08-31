extends Camera2D

@export var move_speed = 0.5
@export var zoom_speed = 0.05
@export var min_zoom = 0.5
@export var max_zoom = 0.8
@export var margin = Vector2(300, 300)
@export var zoom_factor: int

@onready var screen_size = get_viewport_rect().size

func _ready() -> void:
	zoom = Vector2.ONE * max_zoom

func _process(delta):
	var players = _get_players()
	if !players:
		return
	
	var player_positions = players.map(func(player): return player.global_position)
	global_position = lerp(position, _calc_centroid(player_positions), move_speed)
	
	var r = Rect2(position, Vector2.ONE)
	for player in players:
		r = r.expand(player.position)
	
	var z
	if r.size.x > r.size.y * screen_size.aspect():
		z = clamp(screen_size.x / r.size.x, min_zoom, max_zoom)
	else:
		z = clamp(screen_size.y / r.size.y, min_zoom, max_zoom)
	
	print(z)
	zoom = lerp(zoom, Vector2.ONE * z, zoom_speed)
	
func _calc_centroid(points: Array) -> Vector2:
	var centroid : Vector2 = Vector2.ZERO
	for point: Vector2 in points:
		centroid += point
	
	return centroid / points.size()
	
func _calc_furthest_distance(players: Array) -> int:
	var furthest_distance: int
	
	for player: Vector2 in players:
		for other_player: Vector2 in players:
			var distance = (player - other_player).length()
			if player == other_player:
				pass
			elif distance > furthest_distance:
				furthest_distance = distance
	
	return furthest_distance

func _on_level_changed(level: TextureRect) -> void:
	limit_right = level.size.x
	limit_bottom = level.size.y

func _get_players():
	get_parent().get_children().filter(func(child): return "Player" in child.name)
