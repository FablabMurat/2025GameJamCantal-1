extends Node2D
class_name Niveau

## Contenu de la mission :
## chaque élément du tableau est le nombre de fleurs à collecter par type.
## Si la valeur est à 0, il pourra quand même y avoir des fleurs mises au hasard,
## sinon aucune fleur du type n'apparaitra.
@export var mission : Array[int] :
	set(val) :
		mission = val.duplicate()
		allflowers.resize(mission.size())
## Nombre de fleurs apparaissant en plus de celles nécessaires pour la mission.
@export var moreFlowers : int = 2
## true si les plantes peuvent grandir et mourir.
@export var growablePlants : bool = true
## Durée maximale pour compléter le niveau.
## A la fin, celui qui a collecté le plus de fleurs de la mission gagnera.
@export var duree : int = 120
## Pourcentage de repousse ailleurs auprès disparition
@export var repoussePct : int = 50

var persos : Array[Perso]
var jdevice : Array[int]

signal niveaufini
signal cueillette(nperso : int, flowertype : int)
var allflowers : Array[int]
var finished : bool = false

func _init():
	allflowers.resize(mission.size())
	child_exiting_tree.connect(func (node):
		if node is Plante :
			fleurpartie(node.flowertype,node.cell)
			)

func addjoy(j1dev, j2dev):
	jdevice.append(j1dev)
	jdevice.append(j2dev)

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
var used_cells : Dictionary
	
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
	for i in range(moreFlowers):
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

	newplant.settype(idxplant,growablePlants)
	newplant.setcell(random_cell) # pour permettre une repousse sur cette case
	newplant.swapPosition.connect(swapplayers)
	
	add_child.call_deferred(newplant)
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
		perso.setdevice(jdevice[i-1])
		persos.append(perso)
		add_child(perso)

func endoflevel(nperso : int):
	finished = true
	# Le perso a fini sa mission
	var score : Array
	for p in persos :
		score.append(p.collected)
	niveaufini.emit(nperso,score) # FIXME : passer le score

#FIXME : ça peut dépendre de l'objectif de la mission, ou si des fleurs repoussent
func checkmatchnul():
	for perso in persos :
		for idx in range(perso.mission.size()) :
			if perso.mission[idx] > 0  and allflowers[idx] >= perso.mission[idx] :
				# Un personnage peut encore gagner
				#print ("%d peut gagner grace à %d" % [perso.nperso,idx])
				return false
	return true

func fleurcueillie(perso, fleur):
	# Signal vers ZoneJeu
	cueillette.emit(perso.nperso, fleur.flowertype)
	fleur.queue_free() # fleur partie se appelée automatiquement par signal

func fleurpartie(flowertype,cell):
	allflowers[flowertype -1 ] -= 1
	used_cells.erase(cell)
	
	if finished == true : return
	
	if randi_range(0,99) < repoussePct :
		var newplant = plantetscn.instantiate()
		addplant(flowertype,newplant)

	if checkmatchnul() :
		endoflevel(0)

func swapplayers():
	var temp_pos = persos[1].position
	persos[1].position = persos[0].position
	persos[0].position = temp_pos

func _input(event: InputEvent):
	# Astuce pour terminer plus vite un niveau en DEBUG
	if (event.is_action_released("ui_endoflevel")):
		endoflevel(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
