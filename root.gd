extends Node

var level = 1

@export var intro_timer : float = 4.0 
@export var newlevel_timer : float = 3.0

var missions : Array
var niveau : Node2D
var score : Array[int]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	missions.append([0,1,1,0,0])
	missions.append([0,2,1,1,0])
	missions.append([0,3,2,1,0])
	missions.append([0,3,2,1,1])
	missions.append([0,2,2,2,1])
	
	start()
	
func start():
	score = [0,0]
	$CenterContainer.show()
	$PanelContainer/TextureRectIntro.show()
	$PanelContainer/TextureRectInter.hide()
	startCountdown(intro_timer)

func runlevel():
	$CenterContainer.hide()
	$PanelContainer/TextureRectIntro.hide()
	$PanelContainer/TextureRectInter.hide()
	var niveautscn = load("res://niveau.tscn")
	niveau = niveautscn.instantiate()
	niveau.collect.connect(collected.bind())
	niveau.niveaufini.connect(endoflevel.bind())
	niveau.setmission(missions[level-1])
	niveau.addlevelmap(level)
	add_child(niveau)

func endoflevel(winner):
	if winner == 0 :
		# ni 1 ni 2, donc pas de gagnant car jeu bloqué
		%Label.text = "Match nul !   Même niveau..."
	else:
		score[winner-1] += 1
		%Label.text = "Victoire Joueur %d !" % winner + "\nNiveau suivant..." 
		level += 1
	%LabelScore.text = "Joueur 1 : %d \nJoueur 2 : %d" % score
	## TODO :Afficher aussi des scores en plus joli?
	
	niveau.call_deferred("queue_free")
	# astuce pas jolie pour attendre que niveau soit détruit avant de passer au niveau suivant
	# Mais ça permet aussi aux joueurs de se préparer
	$PanelContainer/TextureRectInter.show()
	$CenterContainer.show()
	startCountdown(newlevel_timer)

func _on_timer_timeout() -> void:
	if level <= missions.size() :
		runlevel()
	else:
		$CenterContainer.show()
		%Label.text = "-- FIN DE PARTIE --"
		%LabelScore.text = "Joueur 1 : %d \nJoueur 2 : %d" % score
	# TODO : Gérer le Restart

func collected(perso, flowertype):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if %CountdownCenterContainer.visible :
		%CountdownProgressBar.value = $StartTimer.time_left * 100
		%CountdownLabel.text = "%d" % roundi($StartTimer.time_left)
		if %CountdownProgressBar.value == 0 :
			%CountdownProgressBar.hide()

func startCountdown(timeout):
	%CountdownCenterContainer.show()
	%CountdownProgressBar.show()
	%CountdownProgressBar.value = timeout*100
	%CountdownProgressBar.max_value = timeout*100
	%CountdownLabel.text = "%d" % roundi(timeout)
	$StartTimer.start(timeout)

func _on_start_timer_timeout() -> void:
	%CountdownCenterContainer.show()
	if level <= missions.size() :
		runlevel()
	else:
		$CenterContainer.show()
		%Label.text = "-- FIN DE PARTIE --"
		# TODO :Afficher aussi des scores
