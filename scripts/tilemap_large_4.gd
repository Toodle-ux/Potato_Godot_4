extends "res://scripts/tilemap_large.gd"


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var x = event.position.x - tilemap_small.tile_size
			var y = event.position.y
			var click_cell_position =  local_to_map(Vector2i(x, y))
			print("big cell:" + str(click_cell_position))
			_check_tile(click_cell_position)

func _harvest_big_potatoes(cell):
	set_cell(0, cell, -1, Vector2i(3, 0))
	for i in [0, 1]:
		for j in [0, 1]:
			var x = cell.x * 2 + 1 + i
			var y = cell.y * 2 + j
			print(Vector2i(x, y))
			tilemap_small.set_cell(0, Vector2i(x, y), 0, Vector2i(10, 0))
