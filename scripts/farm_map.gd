extends TileMap

# tilemap bounds
var min_x
var min_y
var max_x
var max_y

# calculate the size of the tilemap at the start of the game
func _ready():
	_calculate_bounds()
	#print(min_x, max_x, min_y, max_y)


# called when pressing a button
func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var click_cell_position =  local_to_map(event.position)
			_check_tile(click_cell_position)
			print(click_cell_position)
			


func _check_tile(click_cell_position):
	var data :TileData = get_cell_tile_data(0,click_cell_position)
	
	# if in the harvest state, 1 harvest potatoes, 2 plant seeds 
	if GameManager.current_status == GameManager.status.harvest:
		if data and data.get_custom_data("Farmable") == true:
			_farm(click_cell_position)
		if data and data.get_custom_data("Harvestable") == true:
			_harvest(click_cell_position)
	
	# if in the growing state, destroy obstacles
	if GameManager.current_status == GameManager.status.growing: 
		if data and data.get_custom_data("Obstacles") == true:
			_obstacles_to_farmable(click_cell_position)
	
	
	
	
# change farmable cells to buds
func _farm(click_cell_position):
	if GameManager.seeds_1 > 0:
		set_cell(0, click_cell_position, 0, Vector2i(54,3))
		GameManager.seeds_1 -= 1
		GameManager._update_ui()

# destroy obstacles and turn it into a farmable land 
func _obstacles_to_farmable(click_cell_position):
	GameManager._consume_action_points(1)
	set_cell(0,click_cell_position,0,Vector2i(46,3))
	
# harvest clicked potatoes
func _harvest(click_cell_position):
	set_cell(0, click_cell_position, 0, Vector2i(52, 3))
	GameManager.potatoes_1 += 1
	GameManager._update_ui()
	
	#_calculate_bounds()
	
#	var data :TileData = get_cell_tile_data(0, Vector2(1,1))
#	print(data)
#
	#print(min_x, max_x)
#	for x in range(0, 10):
#		for y in range(0,10):
#			print(Vector2(x, y))
#			var data :TileData = get_cell_tile_data(0, Vector2(x, y))
#			print(data.get_custom_data("Planted"))
#			if data and data.get_custom_data("Planted") == true:
#				set_cell(0, Vector2(x, y), 0, Vector2i(54,5))

# loop over all tiles and turn buds into potatoes
func _mature():
	pass

	#_calculate_bounds()
	
#	var data :TileData = get_cell_tile_data(0, Vector2(1,1))
#	print(data)
#
	#print(min_x, max_x)
#	for x in range(0, 10):
#		for y in range(0,10):
#			print(Vector2(x, y))
#			var data :TileData = get_cell_tile_data(0, Vector2(x, y))
#			print(data.get_custom_data("Planted"))
#			if data and data.get_custom_data("Planted") == true:
#				set_cell(0, Vector2(x, y), 0, Vector2i(54,5))

# calculate the bounds of the tilemap
func _calculate_bounds():
	var used_cells = get_used_cells(0)
	
	min_x = 100
	min_y = 100
	max_x = 0
	max_y = 0
	
	for pos in used_cells:
		if pos.x < min_x:
			min_x = int(pos.x)
		elif pos.x > max_x:
			max_x = int(pos.x)
		if pos.y < min_y:
			min_y = int(pos.y)
		elif pos.y > max_y:
			max_y = int(pos.y)
	
	#print(min_x, max_x)
