extends Control

## Pantalla de selección de personaje + Host / Join para multijugador local (LAN)

const DEFAULT_PORT := 7777
const MAX_PLAYERS := 2

@onready var raul_button: Button = $VBox/CharacterSelect/RaulButton
@onready var vanesa_button: Button = $VBox/CharacterSelect/VanesaButton
@onready var host_button: Button = $VBox/Network/HostButton
@onready var join_button: Button = $VBox/Network/JoinButton
@onready var ip_input: LineEdit = $VBox/Network/IPInput
@onready var status_label: Label = $VBox/StatusLabel
@onready var single_button: Button = $VBox/SinglePlayerButton

var selected_character: String = "raul"  # "raul" o "vanesa"

func _ready() -> void:
	raul_button.pressed.connect(_on_raul_selected)
	vanesa_button.pressed.connect(_on_vanesa_selected)
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)
	single_button.pressed.connect(_on_single_player)
	
	_update_character_buttons()
	
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _on_raul_selected() -> void:
	selected_character = "raul"
	_update_character_buttons()

func _on_vanesa_selected() -> void:
	selected_character = "vanesa"
	_update_character_buttons()

func _update_character_buttons() -> void:
	raul_button.modulate = Color(0.4, 0.8, 1.0) if selected_character == "raul" else Color(0.6, 0.6, 0.6)
	vanesa_button.modulate = Color(1.0, 0.4, 0.7) if selected_character == "vanesa" else Color(0.6, 0.6, 0.6)

func _on_single_player() -> void:
	GameState.selected_character = selected_character
	GameState.is_online = false
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_host_pressed() -> void:
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	if error != OK:
		status_label.text = "Error al crear servidor: " + str(error)
		return
	
	multiplayer.multiplayer_peer = peer
	GameState.selected_character = selected_character
	GameState.is_online = true
	GameState.is_host = true
	status_label.text = "Servidor creado. Esperando jugador... (puerto %d)" % DEFAULT_PORT
	_go_to_game()

func _on_join_pressed() -> void:
	var address := ip_input.text.strip_edges()
	if address.is_empty():
		address = "127.0.0.1"
	
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(address, DEFAULT_PORT)
	if error != OK:
		status_label.text = "Error al conectar: " + str(error)
		return
	
	multiplayer.multiplayer_peer = peer
	GameState.selected_character = selected_character
	GameState.is_online = true
	GameState.is_host = false
	status_label.text = "Conectando a %s..." % address

func _on_connected_to_server() -> void:
	status_label.text = "¡Conectado! Entrando al juego..."
	_go_to_game()

func _on_connection_failed() -> void:
	status_label.text = "Fallo al conectar. Revisa la IP y que el host esté activo."

func _on_server_disconnected() -> void:
	status_label.text = "Desconectado del servidor."
	multiplayer.multiplayer_peer = null

func _go_to_game() -> void:
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/Game.tscn")
