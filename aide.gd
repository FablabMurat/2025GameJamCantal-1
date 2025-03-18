extends PanelContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	get_viewport().size_changed.connect(resized.bind())
	resized()
	%FermerButton.grab_focus()

# Repositionnement du Control en cas de redimensionnement de la fenêtre
func resized():
	var vp : Viewport = get_viewport()
	self.size = vp.size
	self.size = vp.size

func _on_fermer_pressed():
	self.queue_free()

func _on_fermer_button_gui_input(event: InputEvent) -> void:
	print(event)
	if %FermerButton.visible and event is InputEventJoypadButton and event.is_pressed():
		self.queue_free()
