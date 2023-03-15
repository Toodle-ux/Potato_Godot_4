extends TileMap

@onready var tilemap_large_1 = $"../tilemap_large_1"
@onready var tilemap_large_2 = $"../tilemap_large_2"
@onready var tilemap_large_3 = $"../tilemap_large_3"
@onready var tilemap_large_4 = $"../tilemap_large_4"

var tile_size = 120
var tile_array = []

var playground_action_points = 2


func _ready():
	
	GameManager.visible = true
	
	# get all used cells
	_calculate_bounds()
	# listen to the signal from game manager. whenever receives the signal, loop over all cells
	GameManager.connect("update_status", _loop_over_cells)
	# DialogicScene._play_dialogue()
	var test :TileData = get_cell_tile_data(0, Vector2i(3, 4))
	print("tile 3,4", test.get_custom_data("Harvestable"))

# called when pressing a button
func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var click_cell_position =  local_to_map(event.position)
			_check_tile(click_cell_position)
			print("small cell" + str(click_cell_position))
			var test :TileData = get_cell_tile_data(0, Vector2i(3, 4))

func _check_tile(click_cell_position):
	var data :TileData = get_cell_tile_data(0,click_cell_position)
	
	# if in the harvest state, 1 harvest potatoes, 2 plant seeds 
	if GameManager.current_status == GameManager.status.harvest:
		if data and data.get_custom_data("Farmable") == true:
			_farm(click_cell_position)
		if data and data.get_custom_data("Harvestable") == true:
			_harvest(click_cell_position)
		if data and data.get_custom_data("Machine") == true:
			if data.get_custom_data("Working"):
				_harvest_machine(click_cell_position)
			else:
				_proceed_potatoes(click_cell_position)
	
	var four_farmable_tiles = true
	# if in the growing state, destroy obstacles
	if GameManager.current_status == GameManager.status.growing: 
		for x in [0, 1]:
			for y in [0, 1]:
				var current_cell = click_cell_position + Vector2i(x, y)
				four_farmable_tiles = four_farmable_tiles and tile_array.has(current_cell)
				if tile_array.has(current_cell):
					var current_cell_data :TileData = get_cell_tile_data(0, current_cell)
					four_farmable_tiles = four_farmable_tiles and current_cell_data.get_custom_data("Farmable")
		
		if four_farmable_tiles and GameManager.action_points >= playground_action_points:
			_build_playground(click_cell_position)
		elif data and data.get_custom_data("Farmable") == true:
			_build_machines(click_cell_position)
		
		if data and data.get_custom_data("Obstacles") == true:
			_obstacles_to_farmable(click_cell_position)
	
# change farmable cells to buds
func _farm(click_cell_position):
	if GameManager.seeds_1 > 0:
		set_cell(0, click_cell_position, 0, Vector2i(0, 0))
		GameManager.seeds_1 -= 1
		GameManager._update_ui()

# destroy obstacles and turn it into a farmable land 
func _obstacles_to_farmable(click_cell_position):
	GameManager._consume_action_points(1)
	set_cell(0,click_cell_position,0,Vector2i(10, 0))

func _build_machines(cell):
	GameManager._consume_action_points(1)
	set_cell(0, cell, 0, Vector2i(0, 1))

func _proceed_potatoes(cell):
	if GameManager.potatoes_1 > 0:
		GameManager.potatoes_1 -= 1
		GameManager._update_ui()
		set_cell(0, cell, 0, Vector2i(1, 1))

func _harvest_machine(cell):
	set_cell(0, cell, 0, Vector2i(0, 1))
	GameManager.potatoes_1 += 1
	GameManager._update_ui()
	
# harvest clicked potatoes
func _harvest(click_cell_position):
	set_cell(0, click_cell_position, 0, Vector2i(10, 0))
	GameManager.potatoes_1 += 1
	GameManager._update_ui()

# loop over all tiles and turn buds into potatoes
func _mature(cell):
	var data :TileData = get_cell_tile_data(0, cell)
	if data and data.get_custom_data("Plant_Name") == "Bald":
		set_cell(0, cell, 0, Vector2i(5, 0))
	
	if data and data.get_custom_data("Plant_Name") == "Leaf":
		set_cell(0, cell, 0, Vector2i(3, 0))
	
	if data and data.get_custom_data("Plant_Name") == "Flower":
		set_cell(0, cell, 0, Vector2i(4, 0))

	print("mature")


# add all used cells to an array
func _calculate_bounds():
	var used_cells = get_used_cells(0)
	
	for pos in used_cells:
		tile_array.append(pos)

	#print(tile_array)	

# at the end of each turn, loop over all the cells
func _loop_over_cells():
	print("handle cells")
	var test :TileData = get_cell_tile_data(0, Vector2i(3, 4))
	print("tile 3,4", test.get_custom_data("Harvestable"))

	for cell in tile_array:
		# combine four mature small potatoes into 1 large potato
		_combine_potatoes(cell)
	
	for cell in tile_array:
		# mature planted potatoes
		var data :TileData = get_cell_tile_data(0,cell)
		if data and data.get_custom_data("Planted") == true:
			_mature(cell)
			pass

func _combine_potatoes(cell):
	# TODO: the type of the large potato should be depended on the arrangement of small potatoes
	var potato_name = []
	var turn_big = true
	
	# for the surrounding potatoes of a certain potato
	for x in [0, 1]:
		for y in [0, 1]:
			var current_cell = cell + Vector2i(x, y)
			turn_big = turn_big and tile_array.has(current_cell)
			if tile_array.has(current_cell):
				var data :TileData = get_cell_tile_data(0, current_cell)
				if data and data.get_custom_data("Harvestable") == true:
					var current_name = data.get_custom_data("Plant_Name")
					potato_name.append(current_name)
				else:
					turn_big = false
			#else: 
				#turn_big = false
	
	# if all 4 surrounding potatoes are big potatoes, delete the four potatoes and add a big potato		
	if turn_big == true:
		for x in [0, 1]:
			for y in [0, 1]:
				var current_cell = cell + Vector2i(x, y)
				set_cell(0, current_cell, -1, Vector2i(11, 0))
		_grow_big_potatoes(cell)

func _build_playground(cell):
	GameManager._consume_action_points(playground_action_points)
	
	for x in [0, 1]:
		for y in [0, 1]:
			var current_cell = cell + Vector2i(x, y)
			set_cell(0, current_cell, 0, Vector2i(11, 0))
			
	if (cell.x % 2 == 0) && (cell.y % 2 != 0):
		var x = cell.x / 2
		var y = (cell.y + 1) / 2
		tilemap_large_1.set_cell(0, Vector2i(x, y), 0, Vector2i(2, 0))
	
	if (cell.x % 2 == 0) && (cell.y % 2 == 0):
		var x = cell.x / 2
		var y = cell.y / 2
		tilemap_large_2.set_cell(0, Vector2i(x, y), 0, Vector2i(2, 0))
	
	if (cell.x % 2 != 0) && (cell.y % 2 != 0):
		# print("big potato")
		var x = (cell.x - 1) / 2
		var y = (cell.y + 1) / 2
		tilemap_large_3.set_cell(0, Vector2i(x, y), 0, Vector2i(2, 0))

	if (cell.x % 2 != 0) && (cell.y % 2 == 0):
		var x = (cell.x - 1) / 2
		var y = cell.y / 2
		tilemap_large_4.set_cell(0, Vector2i(x, y), 0, Vector2i(2, 0))

# grow a big potato at the location of four small potatoes	
func _grow_big_potatoes(cell):
	if (cell.x % 2 == 0) && (cell.y % 2 != 0):
		var x = cell.x / 2
		var y = (cell.y + 1) / 2
		tilemap_large_1.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
	
	if (cell.x % 2 == 0) && (cell.y % 2 == 0):
		var x = cell.x / 2
		var y = cell.y / 2
		tilemap_large_2.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
	
	if (cell.x % 2 != 0) && (cell.y % 2 != 0):
		# print("big potato")
		var x = (cell.x - 1) / 2
		var y = (cell.y + 1) / 2
		tilemap_large_3.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))

	if (cell.x % 2 != 0) && (cell.y % 2 == 0):
		var x = (cell.x - 1) / 2
		var y = cell.y / 2
		tilemap_large_4.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
