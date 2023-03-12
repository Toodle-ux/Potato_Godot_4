extends CanvasLayer

var turn = 1
var action_points = 3

var money = 0
var potatoes_1 = 0
var seeds_1 = 50
var big_potatoes = 0

signal update_status

# two status of one turn
enum status {
	harvest,
	growing
}

var current_status = status.harvest

@onready var ui_status = $VBoxContainer/ui_status
@onready var ui_turn = $VBoxContainer/ui_turn
@onready var ui_action_points = $VBoxContainer/ui_action_points
@onready var button_next_turn = $VBoxContainer/button_next_turn
@onready var ui_money = $VBoxContainer/ui_money
@onready var ui_potatoes_1 = $VBoxContainer/ui_potatoes_1
@onready var ui_seeds_1 = $VBoxContainer/ui_seeds_1

# Called when the node enters the scene tree for the first time.
func _ready():
	ui_status.text = "Status: " + str(current_status)
	ui_turn.text = "Turn: " + var_to_str(turn)
	ui_action_points.text = "Action: " + var_to_str(action_points)
	ui_money.text = "Money: " + var_to_str(money)
	ui_potatoes_1.text = "Potatoes: " + var_to_str(potatoes_1)
	ui_seeds_1.text = "Seeds: " + var_to_str(seeds_1)
	

# consume a certain action point and update
func _consume_action_points(number):
	action_points = action_points - number
	print(turn)
	print(action_points)
	_change_status()
	_update_ui()

func _change_status():
	if action_points < 1:
		current_status = status.harvest
		emit_signal("update_status")

func _update_turn():
	if action_points < 1:
		action_points = 3
		turn += 1
		
# update ui
func _update_ui():
	ui_status.text = "Status: " + str(current_status)
	ui_turn.text = "Turn: " + var_to_str(turn)
	ui_action_points.text = "Action: " + var_to_str(action_points)
	ui_money.text = "Money: " + var_to_str(money)
	ui_potatoes_1.text = "Potatoes: " + var_to_str(potatoes_1)
	ui_seeds_1.text = "Seeds: " + var_to_str(seeds_1)
	if current_status == status.growing:
		button_next_turn.visible = false
	else:
		button_next_turn.visible = true

func _on_button_next_turn_pressed():
	action_points = 3
	turn += 1
	current_status = status.growing
	_update_ui()

