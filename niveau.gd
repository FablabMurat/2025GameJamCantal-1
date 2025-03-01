extends Node2D

var perso1
var perso2

var mission : Array

signal collect(perso,flowertype)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	semegazon()
	
	var inlinesum = func sum(accum, num): return accum+num*20
	newplants(50+mission.reduce(inlinesum),mission.map(func xx(elt): return elt*2))
	
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

var plantetscn = preload("res://plante.tscn")
	
func newplants(n, tabspawn : Array):
	var tilemap = $TileMap/TileMapLayer
	var map_rect = tilemap.get_used_rect()
	
	for i in range(tabspawn.size()):
		if tabspawn[i] >= 0 :
			var newplant = plantetscn.instantiate()
			addplant(i+1,newplant,map_rect,tabspawn[i])
	
	for i in range(n):
		var newplant = plantetscn.instantiate()

		var rand = randf()
		if rand < 0.1:
			addplant(2,newplant,map_rect,1)
		elif rand < 0.2:
			addplant(3,newplant,map_rect,1)
		else:
			addplant(1,newplant,map_rect,1)
		

func addplant(idxplant,newplant,map_rect,nb):
	var padding = 8
	var tilemap = $TileMap/TileMapLayer
	var cell_size = Vector2(tilemap.tile_set.tile_size)
	
	var random_cell = Vector2i(
			randi_range(map_rect.position.x, map_rect.end.x - 1),
			randi_range(map_rect.position.y, map_rect.end.y - 1)
		)
		
	var base_pos = tilemap.map_to_local(random_cell)
	newplant.position = base_pos + Vector2(
		randf_range(padding, cell_size.x - padding),
		randf_range(padding, cell_size.y - padding)
	)

	newplant.rotation = randf_range(-0.26, 0.26)
	newplant.scale *= randf_range(0.9, 1.1)
		
	newplant.choosetype(idxplant)
	match idxplant:
		1:
			newplant.nocontact()
		2:
			newplant.isspecial()
			newplant.attrape.connect(fleurattrape)
		3:
			newplant.isspecial()
			newplant.attrape.connect(fleurattrape)
			newplant.canStun = true
		4:
			newplant.isspecial()
			newplant.attrape.connect(fleurattrape)
			newplant.canSpeedBoost = true
		5:
			newplant.isspecial()
			newplant.attrape.connect(fleurattrape)
			newplant.swapPosition.connect(swap_player_positions)
			newplant.canSwapPosition = true
		_:
			newplant.nocontact()
	add_child(newplant)

func setmission(listflowers : Array):
	mission = listflowers
	for i in range(0,listflowers.size()) :
		if listflowers[i] != 0 : 
			for n in range(0,listflowers[i]) :
				var ctrlImage = TextureRect.new()
				ctrlImage.texture = load("res://Ressources/Images/flower_%02d.png" % (i+1))
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

func swap_player_positions():
	var temp_pos = perso1.position
	perso1.position = perso2.position
	perso2.position = temp_pos
