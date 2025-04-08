## A little version of SelectDeviceManager, just manage inputs to add and remove players. 
## So you press to add a Player and its device and read a list of them from this script
class_name MinimalSelectDeviceManager extends Node

@export var connection_devices : ConnectionDevicesManager
@export_category("Inputs")
@export var add_player : String = "ui_accept"
@export var remove_player : String = "ui_cancel"

## For every player (every array index), save a device (-1 is keyboard, >= 0 are joypads)
var players_devices : Array[int]

## Called when "add_player" is pressed on a new device
signal on_add_player(player_index : int, device : int, is_keyboard : bool)
## Called when "remove_player" is pressed on a saved device
signal on_remove_player(player_index : int, device : int, is_keyboard : bool)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(add_player):
		if players_devices.has(event.device) == false:
			players_devices.append(event.device)
	pass
