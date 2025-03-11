extends CharacterBody2D
class_name Perso

@export var nperso : int

var bouger_droite : String
var bouger_gauche : String
var bouger_haut : String
var bouger_bas : String

var dir : String = "bas"
var picking = false
var plant_being_picked : Area2D

const SPEED = 200
@export_range(0, 3, 0.1) var cast_cueillette = 0.5
var stun_duration : float

var speedMultiplier = 0

var mission : Array[int]
var collected : Array[int]

signal cueillette(perso : Perso,flower : Plante)
signal missionfinie(nwinner : int)

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
	collected.resize(mission.size())

	bouger_droite = "move_right_%d" %  nperso
	bouger_gauche = "move_left_%d" %  nperso
	bouger_haut = "move_up_%d" %  nperso
	bouger_bas = "move_down_%d" %  nperso
	
	$AnimatedSprite2D.sprite_frames = load("res://joueur_%d.tres" % nperso)
	

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
		if not $Footsteps.playing:
			$Footsteps.play()
		if velocity.x < 0: dir = "gauche"
		elif velocity.x > 0: dir = "droite"
		elif velocity.y > 0: dir = "bas"
		elif velocity.y < 0: dir = "haut"
		$AnimatedSprite2D.play("run_" + dir)
	elif picking:
		$AnimatedSprite2D.play("pickup_" + dir)
	else :
		$AnimatedSprite2D.play("idle_" + dir)
		$Footsteps.stop()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("cueillir_%d" % nperso) and not is_stunned and !velocity:
		# Cueillette
		startcueillette()
	if $PauseBar.visible :
		var cast_style = $PauseBar.get_theme_stylebox("fill") as StyleBoxFlat
		if is_stunned :
			cast_style.bg_color = Color(0.812, 0.25, 0.222) # ROUGE
			$PauseBar.value = 1 - ($StunTimer.time_left / stun_duration)
		else:
			cast_style.bg_color = Color(0, 0.344, 1) # BLEU
			$PauseBar.value = 1 - ($CueilletteTimer.time_left / cast_cueillette)

func startcueillette():
	picking = true
	speedMultiplier = -1.0  # avec le +1, ça bloque le perso
	#$PauseBar.max_value = float(cast_cueillette) # FIXME
	$CueilletteTimer.start(cast_cueillette)
	$FX_animation.play("pickup")
	$PauseBar.show()

# Fin de la cueillette, plante vraiment cueillie
func _on_cuillette_timer_timeout() -> void:
	speedMultiplier = 0.0
	$FX_animation.play("none")
	$PauseBar.hide()
	picking = false
	if $AreaCueillette2D.has_overlapping_areas():
		for i in $AreaCueillette2D.get_overlapping_areas():
			if i is Plante :
				var plante = i as Plante
				if plante.cueilliepar(self) :
					fleurcueillie(plante)
					break # On n'en prend qu'une à la fois

func fleurcueillie(fleur : Plante):
	if mission[fleur.flowertype-1] > 0 :
		# On ne prend en compte que les fleurs attendues par la mission
		collected[fleur.flowertype-1] += 1
		# il faut en supprimer une du panier
		mission[fleur.flowertype-1] -= 1
	
	cueillette.emit(self,fleur)
	
	# TODO Changer la logique de mission remplie ?
	# Vérifie si on a rempli la mission
	#print("%d : " % nperso, mission)
	if mission[fleur.flowertype-1] <= 0 :
		if mission.all(func (n): return n<=0):
			# On a fini la mission
			missionfinie.emit(nperso)
	

var is_stunned := false
@onready var stun_timer := $StunTimer

func apply_stun(duration: float):
	if not is_stunned:
		stun_duration = duration
		is_stunned = true
		stun_timer.start(duration)
		#modulate = Color.RED
		#$PauseBar.max_value = float(duration)
		$PauseBar.show()
		$AnimatedSprite2D.stop()
		if not $Stunned.playing:
			$Stunned.play()


func _on_stun_timer_timeout():
	is_stunned = false
	modulate = Color.WHITE
	$FX_animation.animation = "none"
	$PauseBar.hide()
	$AnimatedSprite2D.play()
	$Stunned.stop()

@onready var speed_boost_timer := $SpeedBoostTimer
func apply_speed_boost(duration :float, boostStrength :float):
	speedMultiplier = boostStrength
	speed_boost_timer.start(duration)
	if not $Speedboost.playing:
			$Speedboost.play()
	
func _on_speed_boost_timer_timeout() -> void:
	speedMultiplier = 0
	$Speedboost.stop()
