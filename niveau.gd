extends Node2D

var perso1
var perso2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var persotscn = preload("res://perso.tscn")
	perso1 = persotscn.instantiate()
	perso1.position = $MarkerPerso1.position
	add_child(perso1)
	perso2 = persotscn.instantiate()
	perso2.position = $MarkerPerso2.position
	add_child(perso2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
