extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _play_dialogue():
	var opening_dialogue = Dialogic.start("0")
	add_child(opening_dialogue)
