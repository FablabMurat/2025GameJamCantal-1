extends Node2D

var perso1
var perso2

var mission : Array
var sollayer : TileMapLayer
var map_rect : Rect2
var allflowers : Array[int]

const RANDFLOWERS = 25 

signal collect(perso,flowertype)
signal niveaufini(winner : Perso)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	semegazon()
	setupLevelYSort()
	#var nbtotal = mission.reduce(func sum(total,nb): return total+nb*2) + 15
	newplants(mission.map(func xx(elt): return elt*2),RANDFLOWERS)
	
func setupLevelYSort():
	var niveau: CanvasItem = $ZoneJeu/MarkerLevel.get_child(0)
	niveau.z_index = 0
	niveau.y_sort_enabled = true
	niveau.z_as_relative = false
	
	var obstacles = $ZoneJeu/MarkerLevel.get_child(0).get_node("Obstacles")
	obstacles.z_index = 1
	obstacles.y_sort_enabled = true
	obstacles.z_as_relative = false

func semegazon() :
	var cells = Array()
	for x in range(-3,22):
		for y in range(-1,13):
			cells.append(Vector2i(x,y))
	$ZoneJeu/LayerGazon.set_cells_terrain_connect(cells,0,0,false)

var plantetscn = preload("res://plante.tscn")
var used_cells
	
func newplants(tabspawn : Array, nrandom : int):
	used_cells = {}
	# plantes pour la mission
	for i in range(tabspawn.size()):
		if tabspawn[i] > 0 :
			for nbplants in range(tabspawn[i]) :
				var newplant = plantetscn.instantiate()
				addplant(i+1,newplant)

	# plantes supplémentaires (décor et effets)
	for i in range(nrandom):
		var newplant = plantetscn.instantiate()

		var rand = randf()
		if rand < 0.1:
			# 10% de plantes de téléportation
			addplant(5,newplant)
		elif rand < 0.2:
			# 10% de plantes de speedboost
			addplant(4,newplant)
		elif rand < 0.35:
			# 15% de plantes de stun
			addplant(3,newplant)
		elif rand < 0.5:
			# 15% de plantes bleues à collecter, sans effet
			addplant(2,newplant)
		else:
			# 50% de plantes de décoration, sans effet
			addplant(1,newplant)

func addplant(idxplant, newplant):
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
	
	var ecartmax = 10
	newplant.position = fleurs_tilemap.map_to_local(random_cell);
	newplant.position += Vector2(randi_range(-ecartmax,ecartmax),randi_range(-ecartmax,ecartmax))

	#newplant.y_sort_enabled = true
	#newplant.z_index = 1

	newplant.settype(idxplant)
	match idxplant:
		1:  # décoration, sans effet
			newplant.nocontact()
		2:  # sans effet, mais ramassables
			newplant.isspecial()
			newplant.attrape.connect(fleurattrapee)
		3:  # stun, mais ramassables
			newplant.isspecial()
			newplant.attrape.connect(fleurattrapee)
			newplant.canStun = true
		4:  # speedboost, mais ramassables
			newplant.isspecial()
			newplant.attrape.connect(fleurattrapee)
			newplant.canSpeedBoost = true
		5:  # téléportation par swap, mais ramassables
			newplant.isspecial()
			newplant.attrape.connect(fleurattrapee)
			newplant.swapPosition.connect(swap_player_positions)
			newplant.canSwapPosition = true
		_:
			newplant.nocontact()
	$ZoneJeu/MarkerLevel.get_child(0).add_child(newplant)
	allflowers[idxplant-1] += 1

func setmission(listflowers : Dictionary):
	self.mission = listflowers["mission"].duplicate()
	allflowers.resize(mission.size())
	
	for nj in range(1,3) :
		for i in range(0,mission.size()) :
			if mission[i] != 0 : 
				for n in range(0,mission[i]) :
					var ctrlImage = TextureRectFlower.new(i+1)
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
	#print ("Fleur ",fleur.flowertype," attrapée par ",perso.nperso)
	#print("1 : ",perso1.mission)
	#print("2 : ",perso2.mission)
	
	perso.fleurattrapee(fleur)
	allflowers[fleur.flowertype -1 ] -= 1
	if checkmatchnul() :
		niveaufini.emit(0)
	fleur.queue_free()

func removeflower(nperso,flowertype):
	if nperso == 1 :
		for vb in %VBoxContainer1.get_children() :
			if vb is TextureRectFlower :
				if vb.flowertype == flowertype :
					vb.queue_free()
					return
	elif nperso == 2:
		for vb in %VBoxContainer2.get_children() :
			if vb is TextureRectFlower :
				if vb.flowertype == flowertype :
					vb.queue_free()
					return

func checkmatchnul():
	for perso in [perso1,perso2] :
		for idx in range(perso.mission.size()) :
			if perso.mission[idx] > 0  and allflowers[idx] >= perso.mission[idx] :
				# Un personnage peut encore gagner
				#print ("%d peut gagner grace à %d" % [perso.nperso,idx])
				return false
	return true

func endoflevel(nperso):
	niveaufini.emit(nperso)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func swap_player_positions():
	var temp_pos = perso1.position
	perso1.position = perso2.position
	perso2.position = temp_pos
