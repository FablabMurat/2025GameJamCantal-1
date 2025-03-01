extends CharacterBody2D
class_name Perso

@export var nperso : int

var bouger_droite : String
var bouger_gauche : String
var bouger_haut : String
var bouger_bas : String

const SPEED = 200

var speedMultiplier = 0

func _init():
	nperso = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func start(np):
	nperso = np
	bouger_droite = "move_right_%d" %  nperso
	bouger_gauche = "move_left_%d" %  nperso
	bouger_haut = "move_up_%d" %  nperso
	bouger_bas = "move_down_%d" %  nperso
	
	$Sprite2D.texture = load("res://Ressources/Images/character_%02d_face.png" % np)
	var rescale : float
	rescale = 64.0 / $Sprite2D.texture.get_width()
	scale.x = rescale
	scale.y = rescale

func _physics_process(delta):
	if is_stunned:
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	var direction = Vector2.ZERO

	if nperso == 0:
		# Personnage pas encore initialisé correctement
		return

	direction.x = Input.get_axis(bouger_gauche, bouger_droite)
	direction.y = Input.get_axis(bouger_haut, bouger_bas)
	
	velocity = direction.normalized() * (SPEED * (speedMultiplier + 1))
	move_and_slide()
	
	#
	#var collision = get_last_slide_collision()
	#if collision:
		#var plante = collision.get_collider()
		#if plante.is_in_group("plante"):
			#pass

func _process(delta: float) -> void:
	pass

var is_stunned := false
@onready var stun_timer := $StunTimer

func apply_stun(duration: float):
	if not is_stunned:
		is_stunned = true
		stun_timer.start(duration)
		modulate = Color.RED

func _on_stun_timer_timeout():
	is_stunned = false
	modulate = Color.WHITE

@onready var speed_boost_timer := $SpeedBoostTimer
func apply_speed_boost(duration :float, boostStrength :float):
	speedMultiplier = boostStrength
	speed_boost_timer.start(duration)

func _on_speed_boost_timer_timeout() -> void:
	speedMultiplier = 0
