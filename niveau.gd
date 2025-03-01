extends Node2D

var perso1
var perso2

signal collect(perso,flowertype)

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
		newplant.position.x = randi_range(32,500)
		newplant.position.y = randi_range(32,500)
		
		if i % 10 == 0 :
			newplant.choosetype(2)
			newplant.isspecial()
			newplant.attrape.connect(fleurattrape.bind())
		else:
			newplant.choosetype(1)
			newplant.nocontact()
		add_child(newplant)

func fleurattrape(perso, fleur):
	print ("Fleur ",fleur.flowertype," attrapé par ",perso.nperso)
	collect.emit(perso,fleur.flowertype) # Ca ne sert à rien
	fleur.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
