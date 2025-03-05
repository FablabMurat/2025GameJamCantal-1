extends TextureRect
class_name TextureRectFlower

var flowertype

func _init(type) -> void:
	stretch_mode = STRETCH_KEEP_CENTERED
	flowertype = type
	texture = load("res://Ressources/Images/flower_%02d.png" % (type))
