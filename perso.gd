extends CharacterBody2D
class_name Perso

@export var nperso : int

var bouger_droite : String
var bouger_gauche : String
var bouger_haut : String
var bouger_bas : String

var dir : String = "bas"
var picking = false

const SPEED = 200
const PAUSESTUN = 3.0
const PAUSECUEILLE = 1.5

var speedMultiplier = 0

var mission : Array
signal updatepanier(nperso,flowertype)
signal missionfinie(nwinner)

func _init():
	nperso = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.animation = "idle_bas"
	$FX_animation.animation = "none"
	$PauseBar.hide()

func start(np, _mission):
	nperso = np
	mission = _mission.duplicate()

	bouger_droite = "move_right_%d" %  nperso
	bouger_gauche = "move_left_%d" %  nperso
	bouger_haut = "move_up_%d" %  nperso
	bouger_bas = "move_down_%d" %  nperso
	
	$AnimatedSprite2D.sprite_frames = load("res://joueur_%d.tres" % nperso)
	

func fleurattrapee(fleur : Plante):
	if mission[fleur.flowertype-1] > 0 :
		# il faut en supprimer une du panier
		updatepanier.emit(nperso,fleur.flowertype)
		mission[fleur.flowertype-1] -= 1
	#
	# Vérifie si on a rempli la mission
	#print("%d : " % nperso, mission)
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
	if velocity:
		if velocity.x < 0: dir = "gauche"
		elif velocity.x > 0: dir = "droite"
		elif velocity.y > 0: dir = "bas"
		elif velocity.y < 0: dir = "haut"
		$AnimatedSprite2D.play("run_" + dir)
	elif picking:
		$AnimatedSprite2D.play("pickup_" + dir)
	else :
		$AnimatedSprite2D.play("idle_" + dir)

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
	picking = true
	speedMultiplier = -1.0  # avec le +1, çà bloque le perso
	$PauseBar.max_value = int(PAUSECUEILLE)
	$CueilletteTimer.start(PAUSECUEILLE)
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
	picking = false


var is_stunned := false
@onready var stun_timer := $StunTimer

func apply_stun(duration: float):
	if not is_stunned:
		is_stunned = true
		stun_timer.start(duration)
		modulate = Color.RED
		$PauseBar.max_value = int(duration)
		$PauseBar.show()
		$AnimatedSprite2D.stop()


func _on_stun_timer_timeout():
	is_stunned = false
	modulate = Color.WHITE
	$FX_animation.animation = "none"
	$PauseBar.hide()
	$AnimatedSprite2D.play()

@onready var speed_boost_timer := $SpeedBoostTimer
func apply_speed_boost(duration :float, boostStrength :float):
	speedMultiplier = boostStrength
	speed_boost_timer.start(duration)

func _on_speed_boost_timer_timeout() -> void:
	speedMultiplier = 0
