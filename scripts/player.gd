extends CharacterBody2D
class_name Player

## Beat n Up - Player Controller
## Soporta multijugador (solo el authority controla el input)
## Diferentes personajes (Raúl / Vanesa) con colores placeholder

enum State { IDLE, RUN, JUMP, ATTACK, HURT }

@export var speed: float = 280.0
@export var jump_velocity: float = -420.0
@export var acceleration: float = 1800.0
@export var friction: float = 1600.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_state: State = State.IDLE
var facing_right: bool = true
var can_attack: bool = true
var character: String = "raul"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer: Timer = $AttackTimer
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var placeholder: ColorRect = $PlaceholderVisual
@onready var name_label: Label = $PlaceholderVisual/Label

func _ready() -> void:
	attack_timer.one_shot = true
	attack_timer.timeout.connect(_on_attack_finished)
	
	if name.is_valid_int():
		set_multiplayer_authority(name.to_int())
	
	_apply_character_style()

func setup(character_name: String, peer_id: int) -> void:
	character = character_name
	name = str(peer_id)
	set_multiplayer_authority(peer_id)
	_apply_character_style()

func _apply_character_style() -> void:
	if not is_inside_tree():
		return
	if character == "raul":
		placeholder.color = Color(0.2, 0.55, 1.0, 0.9)
		name_label.text = "RAÚL"
		speed = 260.0
		jump_velocity = -400.0
	else:
		placeholder.color = Color(1.0, 0.35, 0.65, 0.9)
		name_label.text = "VANESA"
		speed = 310.0
		jump_velocity = -440.0

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	var direction := Input.get_axis("move_left", "move_right")
	
	if current_state != State.ATTACK and current_state != State.HURT:
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
			facing_right = direction > 0
			_update_facing()
			if is_on_floor():
				current_state = State.RUN
		else:
			velocity.x = move_toward(velocity.x, 0, friction * delta)
			if is_on_floor() and abs(velocity.x) < 10:
				current_state = State.IDLE

		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_velocity
			current_state = State.JUMP

		if can_attack and is_on_floor():
			if Input.is_action_just_pressed("punch"):
				_start_attack("punch")
			elif Input.is_action_just_pressed("kick"):
				_start_attack("kick")

	_update_animation()
	move_and_slide()

func _start_attack(attack_type: String) -> void:
	current_state = State.ATTACK
	can_attack = false
	velocity.x = 0
	attack_timer.start(0.35)
	print("[%s] Attack: %s" % [character, attack_type])

func _on_attack_finished() -> void:
	can_attack = true
	if is_on_floor():
		current_state = State.IDLE
	else:
		current_state = State.JUMP

func _update_facing() -> void:
	if sprite:
		sprite.flip_h = not facing_right
	if placeholder:
		placeholder.scale.x = 1.0 if facing_right else -1.0

func _update_animation() -> void:
	if sprite == null or sprite.sprite_frames == null:
		return
	
	var anim := "idle"
	match current_state:
		State.IDLE: anim = "idle"
		State.RUN: anim = "run"
		State.JUMP: anim = "jump"
		State.ATTACK: anim = "punch"
		State.HURT: anim = "hurt"
	
	if sprite.animation != anim and sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)

func take_damage(_amount: int = 1) -> void:
	if current_state == State.HURT:
		return
	current_state = State.HURT
	velocity.x = -180 if facing_right else 180
	await get_tree().create_timer(0.4).timeout
	current_state = State.IDLE
