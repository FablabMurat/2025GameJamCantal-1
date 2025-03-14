extends Node

var MAXLEVEL = 5
var level
var waitingtostart : bool

@export var newlevel_timer : float = 3.0
@export_range(0, 1, 0.1) var master_volume : float = 1
@export_range(0, 1, 0.1) var music_volume : float = 0.2
@export_range(0, 1, 0.1) var SFX_volume : float = 1
@export var disable_start_countdown : bool = false

var j1device : int = -1
var j2device : int = -1

var zonejeu : ZoneJeu
var score : Array[int]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	%VBoxScore.hide()
	%StartButton.text = "  Start !  "
	%StartButton.show()
	$TimerInactivite.stop()
	#TODO : il faudrait aussi que le start soit déclenché par une action manette
	waitingtostart = true

# Click sur bouton Start/Restart
func _on_start_button_up() -> void:
	start()

func start():
	# Start ou Continue
	waitingtostart = false
	if disable_start_countdown:
		newlevel_timer = 0.0
	$TimerInactivite.stop()
	%VBoxScore.hide()
	%StartButton.hide()
	%HBoxChoiceJoy.hide()
	%Label.text = "Niveau %d" % level
	%Label.show()
	startCountdown(newlevel_timer," Prêts ? ")

func startCountdown(timeout, text = ""):
	%Countdown.start(timeout,text)

func _on_countdown_timeout() -> void:
	if level <= MAXLEVEL :
		runlevel()
	else:
		# A priori on ne devrait jamais passer par là
		pass

func runlevel():
	$CenterContainer.hide()
	$PanelContainer/TextureRectIntro.hide()
	$PanelContainer/TextureRectInter.hide()
	var zonejeutscn = load("res://zonejeu.tscn")
	zonejeu = zonejeutscn.instantiate()
	zonejeu.initlevel(level,j1device,j2device)
	zonejeu.niveaufini.connect(endoflevel.bind())
	zonejeu.process_mode = Node.PROCESS_MODE_PAUSABLE
	$PanelContainer.add_sibling(zonejeu)

func endoflevel(winner, tabscore : Array):
	zonejeu.call_deferred("queue_free")
	
	var scorej1 = tabscore[0].reduce(func(accum, number): return accum + number)
	var scorej2 = tabscore[1].reduce(func(accum, number): return accum + number)

	if winner == 0 and scorej1 == scorej2 :
		# ni 1 ni 2, donc pas de gagnant car jeu bloqué
		%Label.text = "Match nul !"
	else:
		if winner == 0 :
			winner = 1 if scorej1 > scorej2 else 2
		score[winner-1] += 1
		%Label.text = "Victoire Joueur %d !" % winner 
		level += 1
	%Label.show()
	
	# Ménage dans la VBoxScore
	for hbox in %VBoxScore.get_children():
		if hbox is HBoxContainer :
			hbox.queue_free()
	
	# Affiche du score dans la VBoxScore
	for joueur in range(2):
		var hbox = HBoxContainer.new()
		hbox.alignment = BoxContainer.ALIGNMENT_BEGIN
		#var label = Label.new()
		#label.text = "Joueur %d : " %(joueur +1)
		#label.add_theme_font_size_override("font_size",24)
		#label.add_theme_color_override("font_color",Color.DARK_GREEN)
		#hbox.add_child(label)
		
		var textureperso = TextureRect.new()
		textureperso.texture = load("res://Ressources/Images/character_%02d_profil_down.png" % (joueur+1))		
		hbox.add_child(textureperso)
		
		for flowertype in range(0,tabscore[joueur].size()) :
			for i in tabscore[joueur][flowertype] :
				var ctrlImage = TextureRectFlower.new(flowertype+1)
				ctrlImage.size_flags_vertical = Control.SIZE_SHRINK_END # INUTILE
		
				hbox.add_child(ctrlImage)
		%VBoxScore.add_child(hbox)
	%VBoxScore.show()

	# Fin de partie ?
	if level+1 > MAXLEVEL :
		# Il n'y a plus de niveaux - Fin de partie
		$PanelContainer/TextureRectIntro.show()
		%VBoxScore/LabelScore.text += "\n-- FIN DE PARTIE --"
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

func _input(event : InputEvent):
	if not waitingtostart: return
	if event.is_action_pressed("choose_1"):
		# Une manette a actionné le X (bleu) sur la manette XBox
		# Ce sera la joueur 1 (en rouge) FIXME
		print ("J1=",event.device," from ",Input.get_connected_joypads())
		print ("event=",event.as_text())
		j1device = event.device
		for joypad in Input.get_connected_joypads():
			if joypad != j1device:
				j2device = joypad
				break
		start()
	elif event.is_action_pressed("choose_2"):
		# Une manette a actionné le B (rouge) sur la manette XBox
		# Ce sera la joueur 2 (en bleu) FIXME
		print ("J2=",event.device," from ",Input.get_connected_joypads())
		print ("event=",event.as_text())
		j2device = event.device
		for joypad in Input.get_connected_joypads():
			if joypad != j2device:
				j1device = joypad
				break
		start()
	
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
	AudioServer.set_bus_volume_db(2, linear_to_db(SFX_volume))
