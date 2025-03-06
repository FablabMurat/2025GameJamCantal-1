extends VBoxContainer
class_name Countdown

signal timeout

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func start(delai, text = ""):
	self.show()
	%CountdownProgressBar.show()
	%CountdownProgressBar.value = delai*100
	%CountdownProgressBar.max_value = delai*100
	%CountdownLabel.text = "%d" % roundi(delai)
	if text == "" :
		$Label.hide()
	else:
		$Label.text = text
		$Label.show()
	$Timer.start(delai)

func _on_timer_timeout() -> void:
	self.hide()
	timeout.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if visible :
		%CountdownProgressBar.value = $Timer.time_left * 100
		%CountdownLabel.text = "%d" % roundi($Timer.time_left)
		if %CountdownProgressBar.value == 0 :
			%CountdownProgressBar.hide()
