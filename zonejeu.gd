extends Node2D
class_name ZoneJeu

var dureemax : float = 0.0
var niveau : Niveau

signal niveaufini(winner : Perso)

func initlevel(level: int, j1dev:int = 0, j2dev:int = 0):
	var leveltscn = load("res://niveau_%d.tscn" % level)
	niveau = leveltscn.instantiate()
	niveau.cueillette.connect(removeflower.bind())
	niveau.niveaufini.connect(endoflevel.bind())
	niveau.addjoy(j1dev,j2dev)
	%MarkerLevel.add_child(niveau)
	
	# La partie contenu de la mission : fleurs à collecter
	var mission = niveau.mission
	
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	semegazon()
	niveau.spawnplants()
	# Duree max de la mission
	if dureemax > 0.0 :
		$DureeJeuTimer.start(dureemax)
		#%LabelDuree.show()
		%ProgressBarDuree.max_value = dureemax # FIXME : pas idéal
		%ProgressBarDuree.show()
		updateduree()
	else:
		#FIXME joueur plutôt sur la HBox
		#%LabelDuree.hide()
		%ProgressBarDuree.hide()

func semegazon() :
	var cells = Array()
	for x in range(-3,22):
		for y in range(-1,13):
			cells.append(Vector2i(x,y))
	$LayerGazon.set_cells_terrain_connect(cells,0,0,false)

func updateduree():
	if dureemax > 0 :
		var timeleft = $DureeJeuTimer.time_left
		#%LabelDuree.text = "%.1f" % timeleft
		
		%ProgressBarDuree.value = timeleft
		if timeleft <= 5:
			%ProgressBarDuree.set_theme_type_variation("ProgressBarAlert")
			%AnimationPlayerDuree.play("blink")
		elif timeleft <= 10:
			%ProgressBarDuree.set_theme_type_variation("ProgressBarWarning")
		else:
			%ProgressBarDuree.set_theme_type_variation("")

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
	# qui gagne ? C'est root qui va décider en fonction des collected
	var score : Array
	for p in niveau.persos :
		score.append(p.collected)
	endoflevel(0,score)

func endoflevel(nperso,tabscore):
	niveaufini.emit(nperso,tabscore)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	updateduree()
