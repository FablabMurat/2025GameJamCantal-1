extends Node2D

var perso1
var perso2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var persotscn = preload("res://perso.tscn")
	perso1 = persotscn.instantiate()
	perso1.position = $MarkerPerso1.position
	perso1.start(1)
	add_child(perso1)
	perso2 = persotscn.instantiate()
	perso2.position = $MarkerPerso2.position
	perso2.start(2)
	add_child(perso2)
	
	newplants(50)

func newplants(n):
	var plantetscn = preload("res://plante.tscn")
	for i in range(n):
		var newplant
		newplant = plantetscn.instantiate()
		newplant.position.x = randi_range(0,500)
		newplant.position.y = randi_range(0,500)
		if i % 10 == 0 :
			newplant.isspecial()
		else:
			newplant.nocontact()
		add_child(newplant)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
