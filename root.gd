extends Node

var level = 1

var murs : Array
var missions : Array
var niveau : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	missions.append([0,1,1,0,0])
	missions.append([0,2,1,1,0])
	missions.append([0,3,2,1,0])
	
	murs.append([Vector2i(5,5),Vector2i(8,5),Vector2i(8,3)])
	
	runlevel()

func runlevel():
	$CenterContainer.visible = true
	var niveautscn = load("res://niveau.tscn")
	niveau = niveautscn.instantiate()
	if murs.size() >= level :
		niveau.addmurs(murs[level-1])
	niveau.collect.connect(collected.bind())
	niveau.niveaufini.connect(endoflevel.bind())
	niveau.setmission(missions[level-1])
	add_child(niveau)

func endoflevel(nperso):
	level += 1
	niveau.call_deferred("queue_free")
	# astuce pas jolie pour attendre que niveau soit détruit avant de passer au niveau suivant
	$Timer.start()
	$CenterContainer.visible = true
	$CenterContainer/Label.text = "Niveau terminé  !"
	# TODO :Afficher aussi des scores
		

func _on_timer_timeout() -> void:
	if level <= missions.size() :
		runlevel()
	else:
		$CenterContainer.visible = true
		$CenterContainer/Label.text = "-- FIN DE PARTIE --"
		# TODO :Afficher aussi des scores

func collected(perso, flowertype):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
