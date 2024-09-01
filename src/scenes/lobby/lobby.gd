extends Control

const SERVER_IP = "188.245.152.157"
# Default game server port. Can be any number between 1024 and 49151.
# Not present on the list of registered or common ports as of May 2024:
# https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
const DEFAULT_PORT = 8910
const MAX_PLAYERS = 10

@onready var status_text: LineEdit = $Status
@onready var online_button: Button = $OnlineButton
@onready var local_button: Button = $LocalButton
@onready var status_ok: Label = $StatusOk
@onready var status_fail: Label = $StatusFail

var players = {}
var player_info = {"playing": false}
var players_loaded = 0
var server_seed = 0

var peer: ENetMultiplayerPeer

# TODO(mlazowik): do not require server restart after each game
func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		# Run your server startup code here...
		#
		# Using this check, you can start a dedicated server by running
		# a Godot binary (editor or export template) with the `--headless`
		# command-line argument.
		
		server_seed = randi()
		seed(server_seed)
		
		_on_host_pressed()
		
	# Connect all the callbacks related to networking.
	multiplayer.peer_connected.connect(_player_connected)
	multiplayer.peer_disconnected.connect(_player_disconnected)
	multiplayer.connected_to_server.connect(_connected_ok)
	multiplayer.connection_failed.connect(_connected_fail)
	multiplayer.server_disconnected.connect(_server_disconnected)

# When the server decides to start the game from a UI scene,
# do Lobby.load_game.rpc(filepath)
# @rpc("call_local", "reliable")
func load_game():
	var main: Node2D = load("res://src/scenes/main/MainScene.tscn").instantiate()
	# Connect deferred so we can safely erase it from the callback.
	# main.game_finished.connect(_end_game, CONNECT_DEFERRED)

	get_tree().get_root().add_child(main)
	hide()
	
	if not multiplayer.has_multiplayer_peer():
		return
	
	if not multiplayer.is_server():
		player_loaded.rpc_id(1)
	
# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "reliable")
func player_loaded():
	var player_id = multiplayer.get_remote_sender_id()
	players[player_id]["playing"] = true
	
	players_loaded += 1
	print("loaded " + str(players_loaded) + " out of " + str(players.size()))
	if players_loaded == players.size():
		# $/root/Game.start_game()
		print("load game!")
		load_game()
		players_loaded = 0
	
#region Network callbacks from SceneTree
# Callback from SceneTree.
func _player_connected(_id: int) -> void:
	if multiplayer.is_server():
		if _is_game_started():
			handle_game_already_in_progress.rpc_id(_id)
		
		set_client_seed.rpc_id(_id, server_seed)
	
	if _id == 1 or multiplayer.is_server():
		return
	
	print("Registring " + str(_id))
	_register_player.rpc_id(_id, player_info)

@rpc("reliable")
func handle_game_already_in_progress():
	multiplayer.set_multiplayer_peer(null)
	# TODO(mlazowik): auto retry?
	online_button.disabled = true
	_set_status("Game already in progress. Try closing the program and opening it later, or play in local mode.", false)

@rpc("reliable")
func set_client_seed(server_seed: int):
	print("Got seed from server: " + str(server_seed))
	seed(server_seed)

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	online_button.disabled = false
	_set_status(str(players.size()) + " players ready", true)
	# player_connected.emit(new_player_id, new_player_info)	

func _player_disconnected(_id: int) -> void:
	var playing = _id == 1 or players[_id]["playing"]
	
	players.erase(_id)
	
	if not multiplayer.is_server():
		_set_status(str(players.size()) + " players ready", true)
		
	if not _is_game_started() or not playing:
		return
	
	if _id == 1:
		_end_game("Server disconnected.")
	
	_end_game("One of the players disconnected.")

# Callback from SceneTree, only for clients (not server).
func _connected_ok() -> void:
	var peer_id = multiplayer.get_unique_id()
	print("connected ok, I am " + str(peer_id))
	players[peer_id] = player_info
	_set_status("Waiting for more players", true)
	_register_player.rpc_id(1, player_info)
	# TODO(mlazowik): uncomment before release?
	# online_button.disabled = true
	online_button.text = "Play"
	# load_game()
	# player_connected.emit(peer_id, player_info) 

# Callback from SceneTree, only for clients (not server).
func _connected_fail() -> void:
	_set_status("Couldn't connect.", false)

	multiplayer.set_multiplayer_peer(null)  # Remove peer.
	online_button.set_disabled(false)


func _server_disconnected() -> void:
	_end_game("Server disconnected.")
#endregion

#region Game creation methods
func _end_game(with_error: String = "") -> void:
	print("end game")
	
	# TODO(mlazowik): better end handling
	get_tree().quit()
	
	return
	
	## print(get_tree().get_root().get_tree_string())
	#if _is_game_started:
		## Erase immediately, otherwise network might show
		## errors (this is why we connected deferred above).
		#get_node(^"/root/Main").free()
		#show()
#
	#multiplayer.set_multiplayer_peer(null)  # Remove peer.
	#play_button.set_disabled(false)
#
	#_set_status(with_error, false)


func _is_game_started() -> bool:
	return has_node("/root/Main")

func _set_status(text: String, is_ok: bool) -> void:
	# Simple way to show status.
	if is_ok:
		status_ok.set_text(text)
		status_fail.set_text("")
	else:
		status_ok.set_text("")
		status_fail.set_text(text)


func _on_host_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	# Set a maximum of 1 peer, since Pong is a 2-player game.
	var err := peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	if err != OK:
		# Is another server running?
		_set_status("Can't host, address in use.",false)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)

	multiplayer.set_multiplayer_peer(peer)
	_set_status("Waiting for player...", true)
	get_window().title = ProjectSettings.get_setting("application/config/name") + ": Server"


func _connect_to_server():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(SERVER_IP, DEFAULT_PORT)
	if error:
		return error
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)

	_set_status("Connecting...", true)
	get_window().title = ProjectSettings.get_setting("application/config/name") + ": Client"
#endregion

func _on_join_pressed():
	# XXX(mlazowik): CURSED CONDITIONAL LOGIC, DO NOT EDIT BUTTON TEXT
	# (or edit and also edit the ifs here and the logic that updates the text
	if online_button.text == "Online":
		_connect_to_server()
		
	if online_button.text == "Play":
		load_game_all_clients.rpc()
	
@rpc("reliable", "call_local", "any_peer")
func load_game_all_clients():
	if multiplayer.is_server():
		return
	
	load_game()

func _on_local_join_pressed():
	multiplayer.set_multiplayer_peer(null)
	load_game()
