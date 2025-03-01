extends StaticBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func nocontact():
	$CollisionShape2D.queue_free()

func isspecial():
	add_to_group("guards")

func choosesprite():
	var icon = preload("res://Ressources/Images/icon.svg")
	$Sprite2D.texture = icon

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
