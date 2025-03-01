extends CharacterBody2D
class_name Perso

@export var nperso : int

var bouger_droite : String
var bouger_gauche : String
var bouger_haut : String
var bouger_bas : String

const SPEED = 200

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
	var direction = Vector2.ZERO

	if nperso == 0:
		# Personnage pas encore initialisé correctement
		return

	direction.x = Input.get_axis(bouger_gauche, bouger_droite)
	direction.y = Input.get_axis(bouger_haut, bouger_bas)
	
	velocity = direction.normalized() * SPEED
	move_and_slide()
	
	#
	#var collision = get_last_slide_collision()
	#if collision:
		#var plante = collision.get_collider()
		#if plante.is_in_group("plante"):
			#pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
