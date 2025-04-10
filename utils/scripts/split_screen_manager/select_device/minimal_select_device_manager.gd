## A little version of SelectDeviceManager, just manage inputs to add and remove players. 
## So you press to add a Player and its device and read a list of them from this script
class_name MinimalSelectDeviceManager extends Node

@export_range(1, 4) var max_number_of_players : int = 4
## If True: when player 1 disconnect, it's removed from array and player 2 becomes new player 1. 
## If False: player 1 becomes device -100 and player 2 remains the same. 
## When a new player connect, instead of add it as last player in array, it will become new player 1
@export var on_disconnect_resize_array : bool = true
@export var add_player : String = "ui_accept"
@export var remove_player : String = "ui_cancel"

## For every player (every array element), save a device (-1 is keyboard, >= 0 are joypads)
var players_devices : Array[int]

const NULL_DEVICE : int = -100

## Called when a new player is added to array
signal on_add_player(player_index : int, device : int, is_keyboard : bool)
## Called when a player is removed from array
signal on_remove_player(player_index : int, device : int, is_keyboard : bool)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(add_player):
		try_add_player(event)
	elif event.is_action_pressed(remove_player):
		try_remove_player(event)

## If it's a new device and there is still space in array, add player with this device
func try_add_player(event : InputEvent):
	#if this device is already in array, do nothing
	var device : int = get_device_index(event)
	if players_devices.has(device):
		return
	#if array doesn't resize, check if there is a player without device and set it
	if on_disconnect_resize_array == false:
		for i in range(players_devices.size()):
			if players_devices[i] == NULL_DEVICE:
				players_devices[i] = device
				on_add_player.emit(i, device, device == -1)
				return
	#be sure to not exceed size
	if players_devices.size() >= max_number_of_players:
		return
	#add a player with this device to array
	players_devices.append(device)
	on_add_player.emit(players_devices.size() - 1, device, device == -1)

## If device is in the array, remove player with this device from it
func try_remove_player(event : InputEvent):
	#remove player with this device from the array
	var device : int = get_device_index(event)
	if players_devices.has(device):
		var player_index : int = players_devices.find(device)
		#remove from array or just set device to null
		if on_disconnect_resize_array:
			players_devices.remove_at(player_index)
		else:
			players_devices[player_index] = NULL_DEVICE
		on_remove_player.emit(player_index, device, device == -1)

## Return -1 for Keyboard or Mouse, else return event.device for joypads
func get_device_index(event : InputEvent) -> int:
	if event is InputEventMouse or event is InputEventKey:
		return -1
	else:
		return event.device
