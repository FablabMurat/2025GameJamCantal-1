extends Node2D
class_name Niveau

@export var mission : Array[int] : # FIXME setter
	set(val) :
		mission = val.duplicate()
		allflowers.resize(mission.size())
@export var moreflowers : int = 2
@export var growableplants : bool = true
@export var duree : int = 120

var persos : Array[Perso]

signal niveaufini
signal cueillette(nperso : int, flowertype : int)
var allflowers : Array[int]

func _init():
	allflowers.resize(mission.size())

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setupLevelYSort()
	
	spawnpersos()
	pass # Replace with function body.

func setupLevelYSort():
	var niveau: CanvasItem = self
	niveau.z_index = 0
	niveau.y_sort_enabled = true
	niveau.z_as_relative = false
	
	var obstacles = self.get_node("Obstacles")
	obstacles.z_index = 1
	obstacles.y_sort_enabled = true
	obstacles.z_as_relative = false


var plantetscn = preload("res://plante.tscn")
var used_cells
	
func spawnplants():
	var tabspawn = mission.map(func xx(elt): return elt*2)
	
	used_cells = {}
	# plantes pour la mission
	for i in range(tabspawn.size()):
		if tabspawn[i] > 0 :
			for nbplants in range(tabspawn[i]) :
				var newplant = plantetscn.instantiate()
				addplant(i+1,newplant)

	# plantes supplémentaires (décor et effets)
	for i in range(moreflowers):
		var newplant = plantetscn.instantiate()

		var rand = randf()
		if rand < 0.1 and mission.size() >= 5:
			# 10% de plantes de téléportation
			addplant(5,newplant)
		elif rand < 0.2 and mission.size() >= 4:
			# 10% de plantes de speedboost
			addplant(4,newplant)
		elif rand < 0.35 and mission.size() >= 3:
			# 15% de plantes de stun
			addplant(3,newplant)
		elif rand < 0.5 and mission.size() >= 2:
			# 15% de plantes bleues à collecter, sans effet
			addplant(2,newplant)
		else:
			# 50% de plantes de décoration, sans effet
			addplant(1,newplant)

func addplant(idxplant, newplant):
	var niveau = self
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

	newplant.settype(idxplant,growableplants)
	newplant.swapPosition.connect(swapplayers)
	
	add_child(newplant)
	allflowers[idxplant-1] += 1

func spawnpersos():
	var persotscn = preload("res://perso.tscn")
	var posj
	
	for i in range(1,3) :
		posj = get_node("Pos_J%d" % i)
		var perso : Perso
		perso = persotscn.instantiate()
		perso.position = posj.position
		perso.start(i,mission)
		perso.cueillette.connect(fleurcueillie.bind())
		perso.missionfinie.connect(endoflevel.bind())
		persos.append(perso)
		add_child(perso)

func endoflevel(nperso : int):
	# Le perso a fini sa mission
	var score : Array
	for p in persos :
		score.append(p.collected)
	niveaufini.emit(nperso,score) # FIXME : passer le score

#FIXME : ça peut dépendre de l'objectif de la mission
func checkmatchnul():
	for perso in persos :
		for idx in range(perso.mission.size()) :
			if perso.mission[idx] > 0  and allflowers[idx] >= perso.mission[idx] :
				# Un personnage peut encore gagner
				#print ("%d peut gagner grace à %d" % [perso.nperso,idx])
				return false
	return true

func fleurcueillie(perso, fleur):
	allflowers[fleur.flowertype -1 ] -= 1
	
	# Signal vers ZoneJeu
	cueillette.emit(perso.nperso, fleur.flowertype)
	fleur.queue_free()
	
	#FIXME
	if checkmatchnul() :
		niveaufini.emit(0)

func swapplayers():
	var temp_pos = persos[1].position
	persos[1].position = persos[2].position
	persos[2].position = temp_pos
	#FIXME : add effects, tempo, suspend flower effect

func _input(event: InputEvent):
	# Astuce pour terminer plus vite un niveau en DEBUG
	if (event.is_action_released("ui_endoflevel")):
		endoflevel(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
