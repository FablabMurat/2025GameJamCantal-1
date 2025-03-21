extends Area2D
class_name Plante

var flowertype : int

const MAXSTARTDELAY = 10.0
var startdelay : float
var growspeed : int = 5
var diespeed : int = 15
var picklimit : float = 0.5
var visiblelimit : float = 0.1
var growdirection : int = 0
var cell

var cangrow : bool
var candie : bool
var canStun : bool
var canSpeedBoost : bool
var canSwapPosition : bool

var effectSuspended : bool = false
const suspendDuration : float = 2.0

@export var stun_duration : float = 2
@export var speed_boost_duration : float = 2
@export_range(0, 1, 0.05) var speed_boost_strength : float = 0.5
@export var minsizepickable = 0.3

var is_pickable : bool = false
var foufouille : float #animation on cueillette

##signal attrape(perso,plante)
signal swapPosition()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if cangrow :
		self.scale = Vector2(0.01,0.01)
		$CollisionShape2D.hide()
		$StartTimer.start(randf_range(0.1,MAXSTARTDELAY))

func nocontact():
	$CollisionShape2D.queue_free()
	self.monitorable = false

func isspecial():
	add_to_group("guards") # TODO : comprendre ce que ça apporte

func settype(ft : int, growable : bool = false):
	flowertype = ft
	var icon = load("res://Ressources/Images/flower_%02d.png" % ft)

	$Sprite2D.texture = icon
	cangrow = growable

	match ft:
		1:  # décoration, sans effet
			pass #nocontact()
		2:  # sans effet, mais ramassables
			isspecial()
		3:  # stun, mais ramassables
			isspecial()
			canStun = true
		4:  # speedboost, mais ramassables
			isspecial()
			canSpeedBoost = true
		5:  # téléportation par swap, mais ramassables
			isspecial()
			canSwapPosition = true
		_:
			nocontact()

func setcell(cellpos):
	cell = cellpos

func _on_start_timer_timeout() -> void:
	growdirection = 1
	$CollisionShape2D.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Ici on peut essayer de faire grossir les plantes
	if cangrow:
		if growdirection > 0 :
			self.scale +=  Vector2(delta/growspeed,delta/growspeed)
		elif growdirection < 0:
			self.scale -=  Vector2(delta/diespeed,delta/diespeed)
		
		if growdirection > 0 and self.scale.x >=1 :
			growdirection = -1
		elif growdirection < 0 and self.scale.x < visiblelimit :
			self.queue_free()
	
	# la fleur bouge lorsqu'on est assez proche pour la cueillir
	if is_pickable :
		$Sprite2D.rotation = sin(foufouille) * 0.3
		foufouille += 0.1
		if not $pickup_inprogress.playing:
			$pickup_inprogress.play()
	else:
		$Sprite2D.rotation = lerp($Sprite2D.rotation, 0.0, 0.1) #sinon back to rotation 0
		$pickup_inprogress.stop()

func pickable():
	return self.scale.x > minsizepickable
	
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("perso") :
		# La fleur est approchée par le perso
		var perso = body as Perso
		effetspecial(perso)
		is_pickable = true

func _on_body_exited(body: Node2D) -> void:
	# A priori, c'est un Perso qui part
	# FIXME mais on est peut-être 2 à côté de la plante
	# FIXME donc il ne faudrait certes pas arrêter l'animation
	is_pickable = false

# Cueillette effective par un des Perso
func cueilliepar(body):
	var perso = body as Perso
	if not pickable() : # fleur trop petite par exemple
		return false
	return true

func effetspecial(surperso):
	if effectSuspended: return
	if canStun:
		surperso.apply_stun(stun_duration)
	if canSpeedBoost:
		surperso.apply_speed_boost(speed_boost_duration, speed_boost_strength)
	if canSwapPosition:
		suspendEffect()
		swapPosition.emit()
		

# Suspend les effets de la plante pendant 1.5 s
func suspendEffect():
	$SuspendTimer.start(suspendDuration)
	effectSuspended = true

func _end_suspend_timer() -> void:
	effectSuspended = false
