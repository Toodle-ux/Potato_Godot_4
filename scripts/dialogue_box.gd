extends TextureRect

@export var dialogPath = ""
@export var textSpeed = 0.05

var dialog

var phraseNum = 0
var finished = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.wait_time = textSpeed
	dialog = getDialog()
	assert(dialog, "Dialog not found")
	nextPhrase()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$indicator.visible = finished
	if Input.is_action_just_pressed("ui_accept"):
		print("ui_accept")
		if finished:
			nextPhrase()
		else:
			$text.visible_characters = len($text.text)

func getDialog() -> Array:
	assert(FileAccess.file_exists(dialogPath), "File path does not exist")
	var f = FileAccess.open(dialogPath, FileAccess.READ)
	var json = f.get_as_text()
	
	var output = JSON.parse_string(json)
	
	if typeof(output) == TYPE_ARRAY:
		return output
	else:
		return []	
	
func nextPhrase() -> void:
	if phraseNum >= len(dialog):
		queue_free()
		return
	
	finished = false
	
	$name.bbcode_text = dialog[phraseNum]["Name"]
	$text.bbcode_text = dialog[phraseNum]["Text"]
	
	$text.visible_characters = 0
	
	var img = "res://assets/images/portraits/" + dialog[phraseNum]["Img"] + dialog[phraseNum]["Emotion"] + ".png"
	#var img = "res://assets/images/portraits/" + dialog[phraseNum]["Name"] + ".png"
	if FileAccess.file_exists(img):
		$portrait.texture = load(img)
	else:
		$portrait.texture = null
	
	while $text.visible_characters < len($text.text):
		$text.visible_characters += 1
		
		$Timer.start()
		await $Timer.timeout
	
	finished = true
	phraseNum += 1
	return
