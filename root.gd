extends Node

var level

@export var newlevel_timer : float = 3.0
@export_range(0, 1, 0.1) var master_volume : float = 1
@export_range(0, 1, 0.1) var music_volume : float = 0.2
@export var disable_start_countdown : bool = false

var levels : Array[Dictionary]
var niveau : Node2D
var score : Array[int]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	levels.append({"mission" : [0,1,1,0,0], "duree" :  40})
	levels.append({"mission" : [0,2,1,1,0], "duree" :  60})
	levels.append({"mission" : [0,3,2,1,0], "duree" :  80})
	levels.append({"mission" : [0,3,2,1,1], "duree" : 100})
	levels.append({"mission" : [0,2,2,2,1], "duree" : 100})
	$PauseContainer.hide()
	resized()
	intro()

func resized():
	var vp : Viewport = get_viewport()
	$PanelContainer.size = vp.size
	$PauseContainer.size = vp.size

func intro():
	level = 1
	score = [0,0]
	$CenterContainer.show()
	$PanelContainer/TextureRectIntro.show()
	$PanelContainer/TextureRectInter.hide()
	%Countdown.hide()
	%Label.hide()
	%LabelScore.hide()
	%StartButton.text = "  Start !  "
	%StartButton.show()
	$TimerInactivite.stop()
	#TODO : il faudrait aussi que le start soit déclenché par une action manette

# Click sur bouton Start/Restart
func _on_start_button_up() -> void:
	start()

func start():
	# Start ou Continue
	if disable_start_countdown:
		newlevel_timer = 0.0
	$TimerInactivite.stop()
	%LabelScore.hide()
	%StartButton.hide()
	%Label.text = "Niveau %d" % level
	%Label.show()
	startCountdown(newlevel_timer," Prêts ? ")

func startCountdown(timeout, text = ""):
	%Countdown.start(timeout,text)

func _on_countdown_timeout() -> void:
	if level <= levels.size() :
		runlevel()
	else:
		# A priori on ne devrait jamais passer par là
		pass

func runlevel():
	$CenterContainer.hide()
	$PanelContainer/TextureRectIntro.hide()
	$PanelContainer/TextureRectInter.hide()
	var niveautscn = load("res://niveau.tscn")
	niveau = niveautscn.instantiate()
	niveau.collect.connect(collected.bind())
	niveau.niveaufini.connect(endoflevel.bind())
	niveau.setmission(levels[level-1])
	niveau.addlevelmap(level)
	niveau.process_mode = Node.PROCESS_MODE_PAUSABLE
	#add_child(niveau)
	$PanelContainer.add_sibling(niveau)

func endoflevel(winner):
	niveau.call_deferred("queue_free")
	
	
	if winner == 0 :
		# ni 1 ni 2, donc pas de gagnant car jeu bloqué
		%Label.text = "Match nul !"
	else:
		score[winner-1] += 1
		%Label.text = "Victoire Joueur %d !" % winner 
		level += 1
	%Label.show()
	%LabelScore.text = "Joueur 1 : %d \nJoueur 2 : %d" % score
	%LabelScore.show()
	## TODO :Afficher aussi des scores en plus joli?
	
	# Fin de partie ?
	if level+1 > levels.size() :
		# Il n'y a plus de niveaux - Fin de partie
		$PanelContainer/TextureRectIntro.show()
		%LabelScore.text += "\n-- FIN DE PARTIE --"
		%StartButton.text = " Restart "
		level = 1  # On se prépare pour la prochaine partie
		%StartButton.show()
		$CenterContainer.show()
		$TimerInactivite.start()
	else:
		$PanelContainer/TextureRectInter.show()
		if winner == 0 :
			%StartButton.text = " Même niveau... "
		else:
			%StartButton.text = " Suivant... "
		%StartButton.show()
		$CenterContainer.show()

func _on_timer_inactivite_timeout() -> void:
	# Se déclenche quand on a fini une partie et qu'on ne fait par Restart
	intro()

func collected(perso, flowertype):
	# Ca peut être l'occasion de relancer une fleur...
	# sous réserve de connecter le signal
	pass
	
func _unhandled_input(event: InputEvent):
	if (event.is_action_released("ui_cancel")):
		if not get_tree().paused :
			# Mise en pause
			topause()
		else:
			# Sortie de la pause
			# FIXME : on ne passe jamais ici
			outpause()

func topause():
	# Mise en pause
	get_tree().paused = true
	$PauseContainer.show()

func _on_out_pause_button_up() -> void:
	outpause()

func outpause():
	$PauseContainer.hide()
	get_tree().paused = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(master_volume))
	AudioServer.set_bus_volume_db(1, linear_to_db(music_volume))
