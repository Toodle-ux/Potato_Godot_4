extends TileMap

@onready var tilemap_small = $"../tilemap_small"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var click_cell_position =  local_to_map(event.position)
			print("big cell:" + str(click_cell_position))
			_check_tile(click_cell_position)

func _check_tile(cell):
	var data :TileData = get_cell_tile_data(0, cell)
	
	if GameManager.current_status == GameManager.status.harvest:
		if data and data.get_custom_data("Playground") == true:
			if data.get_custom_data("Empty") == true:
				_put_into_playground(cell)
			else:
				_harvest_organic_potatoes(cell)
			
		if data and data.get_custom_data("Farmland") and data.get_custom_data("Harvestable") == true:
			_harvest_big_potatoes(cell)

func _put_into_playground(cell):
	set_cell(0, cell, 0, Vector2i(1, 0))

func _harvest_organic_potatoes(cell):
	set_cell(0, cell, 0, Vector2i(2, 0))

func _harvest_big_potatoes(cell):
	set_cell(0, cell, -1, Vector2i(3, 0))
	for i in [0, 1]:
		for j in [0, 1]:
			var x = cell.x * 2 + i
			var y = cell.y * 2 + j
			print(Vector2i(x, y))
			tilemap_small.set_cell(0, Vector2i(x, y), 0, Vector2i(10, 0))
