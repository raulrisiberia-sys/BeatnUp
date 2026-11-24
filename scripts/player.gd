extends CharacterBody2D
class_name Player

## Beat n Up - Player Controller (prototipo)
## Soporta movimiento lateral, salto y ataques básicos placeholder.
## Listo para conectar AnimatedSprite2D cuando lleguen los sprites.

enum State { IDLE, RUN, JUMP, ATTACK, HURT }

@export var speed: float = 280.0
@export var jump_velocity: float = -420.0
@export var acceleration: float = 1800.0
@export var friction: float = 1600.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_state: State = State.IDLE
var facing_right: bool = true
var can_attack: bool = true

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer: Timer = $AttackTimer
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	attack_timer.one_shot = true
	attack_timer.timeout.connect(_on_attack_finished)
	# Placeholder: si no hay sprites todavía, el ColorRect se ve
	if sprite.sprite_frames == null or sprite.sprite_frames.get_animation_names().is_empty():
		print("Player: No hay SpriteFrames todavía. Usando placeholder visual.")

func _physics_process(delta: float) -> void:
	# Gravedad
	if not is_on_floor():
		velocity.y += gravity * delta

	# Input horizontal
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

		# Salto
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_velocity
			current_state = State.JUMP

		# Ataques
		if can_attack and is_on_floor():
			if Input.is_action_just_pressed("punch"):
				_start_attack("punch")
			elif Input.is_action_just_pressed("kick"):
				_start_attack("kick")

	# Actualizar animación (cuando existan)
	_update_animation()

	move_and_slide()

func _start_attack(attack_type: String) -> void:
	current_state = State.ATTACK
	can_attack = false
	velocity.x = 0  # Frena durante el ataque (típico beat 'em up)
	attack_timer.start(0.35)  # Duración placeholder del ataque
	print("Attack: ", attack_type)  # Aquí luego pondremos hitboxes

func _on_attack_finished() -> void:
	can_attack = true
	if is_on_floor():
		current_state = State.IDLE
	else:
		current_state = State.JUMP

func _update_facing() -> void:
	if sprite:
		sprite.flip_h = not facing_right

func _update_animation() -> void:
	if sprite == null or sprite.sprite_frames == null:
		return
	
	var anim := "idle"
	match current_state:
		State.IDLE:
			anim = "idle"
		State.RUN:
			anim = "run"
		State.JUMP:
			anim = "jump"
		State.ATTACK:
			anim = "punch"  # o "kick" según el tipo
		State.HURT:
			anim = "hurt"
	
	if sprite.animation != anim and sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)

## Llamar desde fuera cuando recibamos daño
func take_damage(_amount: int = 1) -> void:
	if current_state == State.HURT:
		return
	current_state = State.HURT
	velocity.x = -150 if facing_right else 150  # Knockback simple
	# Aquí más tarde: parpadeo, invencibilidad, etc.
	await get_tree().create_timer(0.4).timeout
	current_state = State.IDLE
