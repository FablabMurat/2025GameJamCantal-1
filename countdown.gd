extends VBoxContainer
class_name Countdown

signal timeout

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func start(timeout, text = ""):
	self.show()
	%CountdownProgressBar.show()
	%CountdownProgressBar.value = timeout*100
	%CountdownProgressBar.max_value = timeout*100
	%CountdownLabel.text = "%d" % roundi(timeout)
	if text == "" :
		$Label.hide()
	else:
		$Label.text = text
		$Label.show()
	$Timer.start(timeout)

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
