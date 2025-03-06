extends Area2D
class_name Plante

var flowertype : int

var growspeed : int = 5
var diespeed : int = 15
var picklimit : float = 0.5
var visiblelimit : float = 0.1
var growdirection : int = 0

var cangrow : bool
var candie : bool
var canStun : bool
var canSpeedBoost : bool
var canSwapPosition : bool
var pickable : bool = false

var effectsuspended : bool = false

@export var stun_duration : float = 2
@export var speed_boost_duration : float = 2
@export_range(0, 1, 0.05) var speed_boost_strength : float = 0.5

signal attrape(perso,plante)
signal swapPosition()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func nocontact():
	$CollisionShape2D.queue_free()
	self.monitorable = false

func isspecial():
	add_to_group("guards")

func settype(ft : int, growable : bool = false):
	flowertype = ft
	var icon = load("res://Ressources/Images/flower_%02d.png" % ft)

	$Sprite2D.texture = icon
	cangrow = growable
	if cangrow :
		self.scale = Vector2(0.01,0.01)
		growdirection = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Ici on peut essayer de faire grossir les plantes
	if cangrow:
		if growdirection > 0 :
			self.scale +=  Vector2(delta/growspeed,delta/growspeed)
		else:
			self.scale -=  Vector2(delta/diespeed,delta/diespeed)
		
		if growdirection > 0 and self.scale.x >=1 :
			growdirection = -1
		elif growdirection < 0 and self.scale.x < visiblelimit :
			self.queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("perso") :
		# La fleur est ramassée par le perso
		var perso = body as Perso
		effetspecial(perso)
	
func cueillir(body):
	#if body.is_in_group("perso") :
		# La fleur est ramassée par le perso
		var perso = body as Perso
		attrape.emit(perso, self)
		effetspecial(perso)

func effetspecial(surperso):
		if effectsuspended: return
		if canStun:
			surperso.apply_stun(stun_duration)
		if canSpeedBoost:
			surperso.apply_speed_boost(speed_boost_duration, speed_boost_strength)
		if canSwapPosition:
			swapPosition.emit()

# Suspend les effets de la plante pendant 1.5 s
func suspendeffect():
	$SuspendTimer.start(1.5)
	effectsuspended = true

func _end_suspend_timer() -> void:
	effectsuspended = false
	pass # Replace with function body.

func _on_body_exited(body: Node2D) -> void:
	pickable = false
	pass # Replace with function body.
