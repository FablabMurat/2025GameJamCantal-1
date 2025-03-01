extends Node2D

var perso1
var perso2

var mission = [0,2,0,0]

signal collect(perso,flowertype)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	semegazon()
	
	newplants(50)
	
	var persotscn = preload("res://perso.tscn")
	perso1 = persotscn.instantiate()
	perso1.position = $MarkerPerso1.position
	perso1.start(1)
	add_child(perso1)
	perso2 = persotscn.instantiate()
	perso2.position = $MarkerPerso2.position
	perso2.start(2)
	add_child(perso2)

func semegazon() :
	var cells = Array()
	for x in range(0,13):
		for y in range(0,10):
			cells.append(Vector2i(x,y))
	$TileMap/TileMapLayer.set_cells_terrain_connect(cells,0,0,false)

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

func setmission(listflowers : Array):
	mission = listflowers
	for i in range(1,listflowers.size()+1) :
		var ctrlImage = TextureRect.new()
		ctrlImage.texture = load("res://Ressources/Images/flower_%02d.png" % i)
		%HBoxMission.add_child(ctrlImage)


func fleurattrape(perso, fleur):
	print ("Fleur ",fleur.flowertype," attrapé par ",perso.nperso)
	
	
	var ctrlImage = TextureRect.new()
	ctrlImage.texture = load("res://Ressources/Images/flower_%02d.png" % fleur.flowertype)
	#var container : CenterContainer = CenterContainer.new()
	#container.size.x = 64
	#container.add_child(ctrlImage)
	%VBoxContainer2.add_child(ctrlImage)

	var fleurtscn = load("res://plante.tscn")
	var fleurinv : Plante = fleurtscn.instantiate() 
	fleurinv.choosetype(fleur.flowertype)
	fleurinv.nocontact()
	if perso.nperso == 1 :
		%VBoxContainer1.call_deferred("add_child",fleurinv)
	elif perso.nperso == 2 :
		%VBoxContainer2.call_deferred("add_child",fleurinv)
	collect.emit(perso,fleur.flowertype) # Ca ne sert à rien
	fleur.queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
