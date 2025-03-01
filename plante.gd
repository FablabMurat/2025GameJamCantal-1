extends Area2D

var flowertype : int

signal attrape(perso,plante)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func nocontact():
	$CollisionShape2D.queue_free()

func isspecial():
	add_to_group("guards")

func choosetype(ft : int):
	var icon = load("res://Ressources/Images/flower_%02d.png" % ft)
	$Sprite2D.texture = icon
	var rescale : float
	rescale = 32.0 / $Sprite2D.texture.get_width()
	scale.x = rescale
	scale.y = rescale

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("perso") :
		# La fleur est ramassée par le perso
		var perso = body as Perso
		attrape.emit(perso, self)
