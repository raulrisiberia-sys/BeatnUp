extends Node2D

## Escena de juego - spawnea jugadores según modo (offline o LAN)

@onready var players_node: Node2D = $Players
@onready var status_label: Label = $UI/StatusLabel

var player_scene: PackedScene = preload("res://scenes/Player.tscn")

func _ready() -> void:
	if GameState.is_online:
		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
		
		_spawn_player(multiplayer.get_unique_id(), GameState.selected_character)
		
		if multiplayer.is_server():
			status_label.text = "HOST - Esperando al segundo jugador..."
		else:
			status_label.text = "CLIENTE - Conectado"
	else:
		_spawn_player(1, GameState.selected_character)
		status_label.text = "Modo un jugador - %s" % GameState.selected_character.to_upper()

func _spawn_player(peer_id: int, character: String) -> void:
	var player = player_scene.instantiate()
	player.name = str(peer_id)
	players_node.add_child(player)
	
	if peer_id == 1:
		player.position = Vector2(300, 550)
	else:
		player.position = Vector2(500, 550)
	
	player.setup(character, peer_id)
	GameState.player_characters[peer_id] = character

func _on_peer_connected(id: int) -> void:
	print("Peer conectado: ", id)
	status_label.text = "Jugador conectado! (id %d)" % id
	
	if multiplayer.is_server():
		rpc_id(id, "spawn_remote_player", 1, GameState.selected_character)

func _on_peer_disconnected(id: int) -> void:
	print("Peer desconectado: ", id)
	var player = players_node.get_node_or_null(str(id))
	if player:
		player.queue_free()
	status_label.text = "Jugador desconectado"

@rpc("any_peer", "reliable")
func spawn_remote_player(peer_id: int, character: String) -> void:
	if players_node.has_node(str(peer_id)):
		return
	_spawn_player(peer_id, character)
