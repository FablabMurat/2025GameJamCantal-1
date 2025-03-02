extends CharacterBody2D
class_name Perso

@export var nperso : int

var bouger_droite : String
var bouger_gauche : String
var bouger_haut : String
var bouger_bas : String

const SPEED = 200
const PAUSEMAX = 3.0

var speedMultiplier = 0

var mission : Array
signal updatepanier(nperso,flowertype)
signal missionfinie(nwinner)

func _init():
	nperso = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	$FX_animation.animation = "none"
	$PauseBar.hide()

func start(np, _mission):
	nperso = np
	bouger_droite = "move_right_%d" %  nperso
	bouger_gauche = "move_left_%d" %  nperso
	bouger_haut = "move_up_%d" %  nperso
	bouger_bas = "move_down_%d" %  nperso
	
	$AnimatedSprite2D.sprite_frames = load("res://joueur_%d.tres" % nperso)
	#$Sprite2D.texture = load("res://Ressources/Images/character_%02d_face.png" % np)
	#var rescale : float
	#rescale = 64.0 / 130 #130 = largeur png (ou c' est degueu)
	#scale.x = rescale
	#scale.y = rescale
	#
	mission = _mission

func fleurattrapee(fleur : Plante):
	if mission[fleur.flowertype-1] > 0 :
		# il faut en supprimer une du panier
		updatepanier.emit(nperso,fleur.flowertype)

	mission[fleur.flowertype-1] -= 1
	#
	# Vérifie si on a rempli la mission
	if mission[fleur.flowertype-1] <= 0 :
		if mission.all(func (n): return n<=0):
			# On a fini la mission
			missionfinie.emit(nperso)
	
func _physics_process(delta):
	if is_stunned:
		$FX_animation.play("stun")
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
	
	$AnimatedSprite2D.play()
	if !velocity :
		$AnimatedSprite2D.animation = "idle"
	elif velocity :
		if velocity.x != 0:
			$AnimatedSprite2D.animation = "cote"
			$AnimatedSprite2D.flip_h = velocity.x < 0
		elif velocity.y > 0:
			$AnimatedSprite2D.animation = "face"
		elif velocity.y < 0:
			$AnimatedSprite2D.animation = "dos"
	
	#
	#var collision = get_last_slide_collision()
	#if collision:
		#var plante = collision.get_collider()
		#if plante.is_in_group("plante"):
			#pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("cueillir_%d" % nperso) and not is_stunned:
		# Cueillette
		cueillette()
	if $PauseBar.visible :
		if is_stunned :
			$PauseBar.value = $StunTimer.time_left
		else:
			$PauseBar.value = $CueilletteTimer.time_left

func cueillette():
	speedMultiplier = -1.0  # avec le +1, çà bloque le perso
	$PauseBar.max_value = int(PAUSEMAX)
	$CueilletteTimer.start()
	$FX_animation.play("pickup")
	$PauseBar.show()
	if $AreaCueillette2D.has_overlapping_areas():
		for i in $AreaCueillette2D.get_overlapping_areas():
			if i is Plante :
				var plante = i as Plante
				#if plante.flowertype > 1 :
				plante.cueillir(self)
	
	
func _on_cuillette_timer_timeout() -> void:
	speedMultiplier = 0.0
	$FX_animation.play("none")
	$PauseBar.hide()
	pass # Replace with function body.

var is_stunned := false
@onready var stun_timer := $StunTimer

func apply_stun(duration: float):
	if not is_stunned:
		is_stunned = true
		stun_timer.start(duration)
		modulate = Color.RED
		$PauseBar.max_value = int(PAUSEMAX)
		$PauseBar.show()


func _on_stun_timer_timeout():
	is_stunned = false
	modulate = Color.WHITE
	$FX_animation.animation = "none"
	$PauseBar.hide()

@onready var speed_boost_timer := $SpeedBoostTimer
func apply_speed_boost(duration :float, boostStrength :float):
	speedMultiplier = boostStrength
	speed_boost_timer.start(duration)

func _on_speed_boost_timer_timeout() -> void:
	speedMultiplier = 0
