extends Node

var level = 1

var missions : Array
var niveau : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	missions.append([0,1,1,0,0])
	missions.append([0,2,1,1,0])
	missions.append([0,3,2,1,0])
	
	runlevel()

func runlevel():
	var niveautscn = load("res://niveau.tscn")
	niveau = niveautscn.instantiate()
	
	niveau.collect.connect(collected.bind())
	niveau.niveaufini.connect(endoflevel.bind())
	niveau.setmission(missions[level-1])
	add_child(niveau)

func endoflevel(nperso):
	level += 1
	
	if level <= missions.size() :
		niveau.call_deferred("queue_free")
		# astuce pas jolie pour attendre que niveau soit détruit avant de passer au niveau suivant
		$Timer.start()

func collected(perso, flowertype):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	runlevel() 
