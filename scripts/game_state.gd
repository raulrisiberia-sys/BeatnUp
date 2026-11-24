extends Node

## Autoload global para datos compartidos entre menú y partida

var selected_character: String = "raul"  # "raul" o "vanesa"
var is_online: bool = false
var is_host: bool = false

# Para saber qué personaje eligió cada peer (se sincroniza después)
var player_characters: Dictionary = {}  # peer_id -> "raul" / "vanesa"
