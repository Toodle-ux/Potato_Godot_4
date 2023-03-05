extends TileMap

@onready var tilemap_large_1 = $"../tilemap_large_1"
@onready var tilemap_large_2 = $"../tilemap_large_2"
@onready var tilemap_large_3 = $"../tilemap_large_3"
@onready var tilemap_large_4 = $"../tilemap_large_4"

var tile_size = 120
var tile_array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	_calculate_bounds()
	GameManager.connect("update_status", _handle_cells)


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
		set_cell(0, click_cell_position, 0, Vector2i(0, 0))
		GameManager.seeds_1 -= 1
		GameManager._update_ui()

# destroy obstacles and turn it into a farmable land 
func _obstacles_to_farmable(click_cell_position):
	GameManager._consume_action_points(1)
	set_cell(0,click_cell_position,0,Vector2i(10, 0))
	
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


# calculate the bounds of the tilemap
func _calculate_bounds():
	var used_cells = get_used_cells(0)
	
	for pos in used_cells:
		tile_array.append(pos)

	#print(tile_array)	

func _handle_cells():
	print("handle cells")
	# print(tile_array)
	for cell in tile_array:
		# print(cell)
		_combine_potatoes(cell)
		var data :TileData = get_cell_tile_data(0,cell)
		if data and data.get_custom_data("Planted") == true:
			_mature(cell)

func _combine_potatoes(cell):
	var potato_name = []
	var turn_big = true
	
	for x in [0, 1]:
		for y in [0, 1]:
			var current_cell = cell + Vector2i(x, y)
			
			if tile_array.has(current_cell):
				var data :TileData = get_cell_tile_data(0, current_cell)
				if data and data.get_custom_data("Harvestable") == true:
					var current_name = data.get_custom_data("Plant_Name")
					potato_name.append(current_name)
					
				else:
					turn_big = false
			else: 
				turn_big = false
			
	if turn_big:
		for x in [0, 1]:
			for y in [0, 1]:
				var current_cell = cell + Vector2i(x, y)
				set_cell(0, current_cell, 0, Vector2i(11, 0))
		
		_grow_big_potatoes(cell)
	
func _grow_big_potatoes(cell):
	if (cell.x % 2 == 0) && (cell.y % 2 == 0):
		tilemap_large_1.set_cell(0, Vector2i(cell.x / 2, cell.y / 2), 0, Vector2i(0, 0))
