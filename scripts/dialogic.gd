extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _play_dialogue():
	var opening_dialogue = Dialogic.start("0")
	add_child(opening_dialogue)
