extends Node

var level = 1

@export var intro_timer : float = 4.0 
@export var newlevel_timer : float = 3.0
var newlevel_ui = false

var missions : Array
var niveau : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	missions.append([0,1,1,0,0])
	missions.append([0,2,1,1,0])
	missions.append([0,3,2,1,0])
	missions.append([0,3,2,1,1])
	missions.append([0,2,2,2,1])
	
	$CenterContainer.show()
	$StartTimer.start(intro_timer)

func runlevel():
	$CenterContainer.hide()
	var niveautscn = load("res://niveau.tscn")
	niveau = niveautscn.instantiate()
	niveau.collect.connect(collected.bind())
	niveau.niveaufini.connect(endoflevel.bind())
	niveau.setmission(missions[level-1])
	niveau.addlevelmap(level)
	add_child(niveau)

func endoflevel(nperso):
	level += 1
	niveau.call_deferred("queue_free")
	# astuce pas jolie pour attendre que niveau soit détruit avant de passer au niveau suivant
	$Timer.start(newlevel_timer)
	$CenterContainer.show()
	newlevel_ui = true
	#%Label.text = str($Timer.time_left) #"Niveau terminé  !"
	## TODO :Afficher aussi des scores
		

func _on_timer_timeout() -> void:
	newlevel_ui = false
	if level <= missions.size() :
		runlevel()
	else:
		$CenterContainer.show()
		%Label.text = "-- FIN DE PARTIE --"
		# TODO :Afficher aussi des scores

func collected(perso, flowertype):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if newlevel_ui:
		%Label.text = str(int($Timer.time_left) + 1) # -1 pour que le niveau commence pile sur le 0
	pass

func _on_start_timer_timeout() -> void:
	$CenterContainer.hide()
	runlevel()
