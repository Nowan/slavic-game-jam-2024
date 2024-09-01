extends Control

# Default game server port. Can be any number between 1024 and 49151.
# Not present on the list of registered or common ports as of May 2024:
# https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
const DEFAULT_PORT = 8910
const MAX_PLAYERS = 10

@onready var address: LineEdit = $Address
@onready var host_button: Button = $HostButton
@onready var join_button: Button = $JoinButton
@onready var status_ok: Label = $StatusOk
@onready var status_fail: Label = $StatusFail
@onready var port_forward_label: Label = $PortForward
@onready var find_public_ip_button: LinkButton = $FindPublicIP

var players = {}
var player_info = {"name": "Name"}
var players_loaded = 0

var peer: ENetMultiplayerPeer

# TODO(mlazowik): do not require server restart after each game
func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		# Run your server startup code here...
		#
		# Using this check, you can start a dedicated server by running
		# a Godot binary (editor or export template) with the `--headless`
		# command-line argument.
		_on_host_pressed()
	else:
		_connect_to_server()
		
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
	
	if not multiplayer.is_server():
		player_loaded.rpc_id(1)
	
# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "reliable")
func player_loaded():
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
	if _id == 1 or multiplayer.is_server():
		return
	
	print("Registring " + str(_id))
	_register_player.rpc_id(_id, player_info)

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	# player_connected.emit(new_player_id, new_player_info)

func _player_disconnected(_id: int) -> void:
	players.erase(_id)
	
	if multiplayer.is_server():
		_end_game("Client disconnected.")
	else:
		_end_game("Server disconnected.")


# Callback from SceneTree, only for clients (not server).
func _connected_ok() -> void:
	var peer_id = multiplayer.get_unique_id()
	print("connected ok, I am " + str(peer_id))
	players[peer_id] = player_info
	_register_player.rpc_id(1, player_info)
	# load_game()
	# player_connected.emit(peer_id, player_info)

# Callback from SceneTree, only for clients (not server).
func _connected_fail() -> void:
	_set_status("Couldn't connect.", false)

	multiplayer.set_multiplayer_peer(null)  # Remove peer.
	host_button.set_disabled(false)
	join_button.set_disabled(false)


func _server_disconnected() -> void:
	_end_game("Server disconnected.")
#endregion

#region Game creation methods
func _end_game(with_error: String = "") -> void:
	if has_node("/root/Pong"):
		# Erase immediately, otherwise network might show
		# errors (this is why we connected deferred above).
		get_node(^"/root/Pong").free()
		show()

	multiplayer.set_multiplayer_peer(null)  # Remove peer.
	host_button.set_disabled(false)
	join_button.set_disabled(false)

	_set_status(with_error, false)


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
	host_button.set_disabled(true)
	join_button.set_disabled(true)
	_set_status("Waiting for player...", true)
	get_window().title = ProjectSettings.get_setting("application/config/name") + ": Server"

	# Only show hosting instructions when relevant.
	port_forward_label.visible = true
	find_public_ip_button.visible = true


func _connect_to_server():
	var ip := address.get_text()
	if not ip.is_valid_ip_address():
		_set_status("IP address is invalid.", false)
		return

	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, DEFAULT_PORT)
	if error:
		return error
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)

	_set_status("Connecting...", true)
	get_window().title = ProjectSettings.get_setting("application/config/name") + ": Client"
#endregion

func _on_join_pressed():
	load_game()

func _on_find_public_ip_pressed() -> void:
	OS.shell_open("https://icanhazip.com/")
