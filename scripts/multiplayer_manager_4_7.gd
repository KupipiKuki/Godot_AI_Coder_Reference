class_name NetworkManager
extends Node
## Reference Godot 4.7 High-Level Multiplayer & @rpc Manager with 4.5+ Variadic Logging.

signal player_list_updated
signal connection_succeeded
signal connection_failed

const DEFAULT_PORT: int = 7777
const MAX_CLIENTS: int = 8

var players: Dictionary[int, Dictionary] = {}
var local_player_info: Dictionary[String, Variant] = {"name": "Player", "ready": false}


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func log_net_event(tag: StringName, ...details: Array) -> void:
	var msg_parts := PackedStringArray(["[Net:%s]" % tag])
	for item: Variant in details:
		msg_parts.append(str(item))
	print(" ".join(msg_parts))


func host_game(port: int = DEFAULT_PORT) -> Error:
	var peer := ENetMultiplayerPeer.new()
	var err: Error = peer.create_server(port, MAX_CLIENTS)
	if err != OK:
		return err
	multiplayer.multiplayer_peer = peer
	players[1] = local_player_info.duplicate()
	log_net_event(&"HOST", "Server started on port", port)
	player_list_updated.emit()
	return OK


func join_game(address: String = "127.0.0.1", port: int = DEFAULT_PORT) -> Error:
	var peer := ENetMultiplayerPeer.new()
	var err: Error = peer.create_client(address, port)
	if err != OK:
		return err
	multiplayer.multiplayer_peer = peer
	log_net_event(&"CLIENT", "Connecting to", address, port)
	return OK


@rpc("any_peer", "reliable")
func _register_player(new_player_info: Dictionary) -> void:
	var sender_id: int = multiplayer.get_remote_sender_id()
	players[sender_id] = new_player_info
	player_list_updated.emit()


func _on_peer_connected(id: int) -> void:
	_register_player.rpc_id(id, local_player_info)


func _on_peer_disconnected(id: int) -> void:
	players.erase(id)
	player_list_updated.emit()


func _on_connected_ok() -> void:
	var peer_id: int = multiplayer.get_unique_id()
	players[peer_id] = local_player_info.duplicate()
	player_list_updated.emit()
	connection_succeeded.emit()


func _on_connected_fail() -> void:
	multiplayer.multiplayer_peer = null
	connection_failed.emit()


func _on_server_disconnected() -> void:
	multiplayer.multiplayer_peer = null
	players.clear()
	player_list_updated.emit()
