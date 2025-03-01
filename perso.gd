extends CharacterBody2D

@export var nperso : int

var bouger_droite : String
var bouger_gauche : String
var bouger_haut : String
var bouger_bas : String

const SPEED = 100

var vitesse = SPEED

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func start():
	pass

func _physics_process(delta):
	var direction = Vector2.ZERO

	direction.x = Input.get_axis(bouger_gauche, bouger_droite)
	direction.y = Input.get_axis(bouger_haut, bouger_bas)
	
	velocity = direction.normalized() * vitesse * delta
	
	move_and_slide()
	
	var collision = get_last_slide_collision()
	if collision:
		var ball = collision.get_collider()
		if ball.is_in_group("ballon"):
			ball.apply_central_impulse(velocity*2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
