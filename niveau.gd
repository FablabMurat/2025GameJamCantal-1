extends Node2D

var perso1
var perso2

var mission : Array
var sollayer : TileMapLayer
var map_rect : Rect2
	
signal collect(perso,flowertype)
signal niveaufini()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#semegazon()
	
	var inlinesum = func sum(accum, num): return accum+num*20
	newplants(30,mission.map(func xx(elt): return elt*2))
	

func semegazon() :
	var cells = Array()
	for x in range(-3,22):
		for y in range(-1,13):
			cells.append(Vector2i(x,y))
	$ZoneJeu/LayerGazon.set_cells_terrain_connect(cells,0,0,false)

var plantetscn = preload("res://plante.tscn")
var used_cells
	
func newplants(n, tabspawn : Array):
	#for i in range(tabspawn.size()):
		#if tabspawn[i] >= 0 :
			#var newplant = plantetscn.instantiate()
			#addplant(i+1,newplant,tabspawn[i])
	used_cells = {}
	for i in range(n):
		var newplant = plantetscn.instantiate()

		var rand = randf()
		if rand < 0.1:
			addplant(2,newplant,1)
		elif rand < 0.2:
			addplant(3,newplant,1)
		elif rand < 0.25:
			addplant(4,newplant,1)
		elif rand < 0.3:
			addplant(5,newplant,1)
		else:
			addplant(1,newplant,1)
		

func addplant(idxplant, newplant, nb):
	var niveau = $ZoneJeu/MarkerLevel.get_child(0)
	var fleurs_tilemap = niveau.get_node("Fleurs")
	var all_cells = fleurs_tilemap.get_used_cells()
	var available_cells = all_cells.filter(func(cell): return not used_cells.has(cell))
	fleurs_tilemap.visible = false
	if available_cells.size() == 0:
		push_warning("No available cells!")
		return
	
	var random_cell = available_cells[randi() % available_cells.size()]
	used_cells[random_cell] = true
	
	newplant.position = fleurs_tilemap.map_to_local(random_cell);

	#newplant.y_sort_enabled = true
	#newplant.z_index = 1

	newplant.choosetype(idxplant)
	match idxplant:
		1:
			newplant.nocontact()
		2:
			newplant.isspecial()
			newplant.attrape.connect(fleurattrapee)
		3:
			newplant.isspecial()
			newplant.attrape.connect(fleurattrapee)
			newplant.canStun = true
		4:
			newplant.isspecial()
			newplant.attrape.connect(fleurattrapee)
			newplant.canSpeedBoost = true
		5:
			newplant.isspecial()
			newplant.attrape.connect(fleurattrapee)
			newplant.swapPosition.connect(swap_player_positions)
			newplant.canSwapPosition = true
		_:
			newplant.nocontact()
	$ZoneJeu/MarkerLevel.get_child(0).add_child(newplant)

func setmission(listflowers : Array):
	mission = listflowers
	for nj in range(1,3) :
		for i in range(0,listflowers.size()) :
			if listflowers[i] != 0 : 
				for n in range(0,listflowers[i]) :
					var ctrlImage = TextureRectFlower.new()
					ctrlImage.flowertype = i + 1
					ctrlImage.texture = load("res://Ressources/Images/flower_%02d.png" % (i+1))
					if nj == 1 :
						%VBoxContainer1.add_child(ctrlImage)
					elif nj == 2 :
						%VBoxContainer2.add_child(ctrlImage)

func addlevelmap(level: int):
	var leveltscn = load("res://niveau_%d.tscn" % level)
	var levelmap : Node2D = leveltscn.instantiate()
	sollayer = levelmap.get_child(0)
	map_rect = sollayer.get_used_rect()
	%MarkerLevel.add_child(levelmap)
	
	spawnpersos()

func spawnpersos():
	var persotscn = preload("res://perso.tscn")
	var posj
	posj = %MarkerLevel.get_child(0).get_node("Pos_J1")
	perso1 = persotscn.instantiate()
	perso1.position = posj.position
	perso1.start(1,mission)
	perso1.updatepanier.connect(removeflower.bind())
	perso1.missionfinie.connect(endoflevel.bind())

	$ZoneJeu/MarkerLevel.get_child(0).add_child(perso1)
	posj = %MarkerLevel.get_child(0).get_node("Pos_J2")
	perso2 = persotscn.instantiate()
	perso2.position = posj.position
	perso2.start(2,mission)
	perso2.updatepanier.connect(removeflower.bind())
	perso2.missionfinie.connect(endoflevel.bind())
	$ZoneJeu/MarkerLevel.get_child(0).add_child(perso2)

func fleurattrapee(perso, fleur):
	print ("Fleur ",fleur.flowertype," attrapé par ",perso.nperso)
	
	#var ctrlImage = TextureRect.new()
	#ctrlImage.texture = load("res://Ressources/Images/flower_%02d.png" % fleur.flowertype)
	#if perso.nperso == 1 :
		#%VBoxContainer1.add_child(ctrlImage)
	#else:
		#%VBoxContainer2.add_child(ctrlImage)
		
	perso.fleurattrapee(fleur)
	fleur.queue_free()

func removeflower(nperso,flowertype):
	if nperso == 1 :
		for vb in %VBoxContainer1.get_children() :
			if vb is TextureRectFlower :
				if vb.flowertype == flowertype :
					vb.queue_free()
	elif nperso == 2:
		for vb in %VBoxContainer2.get_children() :
			if vb is TextureRectFlower :
				if vb.flowertype == flowertype :
					vb.queue_free()
			
	
func endoflevel(nperso):
	niveaufini.emit(nperso)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func swap_player_positions():
	var temp_pos = perso1.position
	perso1.position = perso2.position
	perso2.position = temp_pos
