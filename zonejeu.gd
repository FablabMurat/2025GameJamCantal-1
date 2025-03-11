extends Node2D
class_name ZoneJeu

var mission : Array
var dureemax : float = 0.0
var sollayer : TileMapLayer
var niveau : Niveau

const RANDFLOWERS = 25 

signal niveaufini(winner : Perso)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	semegazon()
	#var nbtotal = mission.reduce(func sum(total,nb): return total+nb*2) + 15
	niveau.newplants(mission.map(func xx(elt): return elt*2),RANDFLOWERS)
	# Duree max de la mission
	if dureemax > 0.0 :
		$DureeJeuTimer.start(dureemax)
		%LabelDuree.show()
		updateduree()
	else:
		%LabelDuree.hide()
	
func semegazon() :
	var cells = Array()
	for x in range(-3,22):
		for y in range(-1,13):
			cells.append(Vector2i(x,y))
	$LayerGazon.set_cells_terrain_connect(cells,0,0,false)


func initlevel(level: int):
	var leveltscn = load("res://niveau_%d.tscn" % level)
	niveau = leveltscn.instantiate()
	niveau.cueillette.connect(removeflower.bind())
	niveau.niveaufini.connect(endoflevel.bind())
	# TODO : init complète
	%MarkerLevel.add_child(niveau)
	
	# La partie contenu de la mission : fleurs à collecter
	self.mission = niveau.mission.duplicate()
	
	# Remplissage de la mission à effectuer, TODO : est-ce la cible du jeu ?
	for nj in range(1,3) :  # pour chaque joueur
		for i in range(0,mission.size()) :
			if mission[i] != 0 : 
				for n in range(0,mission[i]) :
					var ctrlImage = TextureRectFlower.new(i+1)
					if nj == 1 :
						%VBoxContainer1.add_child(ctrlImage)
					elif nj == 2 :
						%VBoxContainer2.add_child(ctrlImage)
	
	# La partie duree max du niveau
	if niveau.duree != 0:
		self.dureemax = niveau.duree
		# start du timer dans le _ready

func updateduree():
	if dureemax > 0 :
		%LabelDuree.text = "%.1f" % $DureeJeuTimer.time_left


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

func _on_duree_jeu_timer_timeout() -> void:
	# qui gagne ? FIXME
	endoflevel(0)

func endoflevel(nperso):
	niveaufini.emit(nperso)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	updateduree()
