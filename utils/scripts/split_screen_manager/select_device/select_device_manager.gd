## Manage inputs and call various events
class_name SelectDeviceManager extends Node

enum UnusedColumnPosition {LEFT, RIGHT, NONE}
class ErrorResult:
	var has_error : bool
	var error_message : String

@export var connection_devices : ConnectionDevicesManager
@export_range(1, 4) var number_of_players : int = 1
## Can move device to "unused". This can be at -1 (Left) or greater than number_of_players (Right). 
## If None, every device must have a player
@export var show_unused_column : UnusedColumnPosition
@export_category("Inputs")
@export var move_left : String = "ui_left"
@export var move_right : String = "ui_right"
@export var confirm : String = "ui_accept"
@export var cancel : String = "ui_cancel"

## Key: device index (-1 is keyboard, >= 0 are joypads), Value: player index or "unused" (unused can be -1 or number_of_players)
var devices_positions : Dictionary[int, int]

const SUFFIX : String = "_temp_device"

## Called everytime a device is connected/disconnected or moved to another player
signal on_update_devices_positions(devices_positions : Dictionary[int, int], show_unused_column : UnusedColumnPosition)
## Called when press Confirm to check if there are errors
signal on_check_errors(output_error : ErrorResult)
## If confirm succeeded, return an array of devices selected for every player
signal on_confirm_succeeded(players_devices : Array[Array])
## If confirm failed, return the error
signal on_confirm_failed(error_message : String)
## Called when press Cancel
signal on_cancel()

func _ready() -> void:
	#register to event when change connected devices, and update current connected devices
	connection_devices.on_changed_devices_connection.connect(on_changed_devices_connection)
	on_changed_devices_connection()

func _process(_delta: float) -> void:
	for device in devices_positions:
		var suffix : String = get_device_suffix(device)
		#move device left
		if Input.is_action_just_pressed(move_left + suffix):
			move_device(device, false)
		#move device right
		elif Input.is_action_just_pressed(move_right + suffix):
			move_device(device, true)
		#press confirm
		elif Input.is_action_just_pressed(confirm + suffix):
			press_confirm()
		#press cancel
		elif Input.is_action_just_pressed(cancel + suffix):
			press_cancel()

func on_changed_devices_connection():
	#remove previous inputs
	for device in devices_positions:
		remove_actions(device)
	#update dictionary
	devices_positions.clear()
	if connection_devices.is_mouse_or_keyboard_available:
		devices_positions.get_or_add(-1, get_unused_column_index())
	for joypad in connection_devices.connected_joypads:
		devices_positions.get_or_add(joypad, get_unused_column_index())
	#add new inputs
	for device in devices_positions:
		duplicate_actions(device)
	#call event
	on_update_devices_positions.emit(devices_positions, show_unused_column)

func get_unused_column_index() -> int:
	if show_unused_column == UnusedColumnPosition.NONE:
		return 0
	else:
		return -1 if show_unused_column == UnusedColumnPosition.LEFT else number_of_players

## For every player, return an array of devices
func get_players_devices() -> Array[Array]:
	#create an array for every player
	var players_devices : Array[Array]
	for i in range(number_of_players):
		players_devices.append([])
	#add every device to every player in array
	for device in devices_positions:
		var player_index = devices_positions[device]
		if player_index >= 0 and player_index < number_of_players:
			players_devices[player_index].append(device)
	return players_devices

#region inputs

## Update device position to right or left
func move_device(device : int, move_device_to_right : bool):
	if move_device_to_right:
		var max_pos : int = maxi(number_of_players - 1, get_unused_column_index())
		var new_position = mini(devices_positions[device] + 1, max_pos)
		devices_positions[device] = new_position
	else:
		var min_pos : int = min(0, get_unused_column_index())
		var new_position = maxi(devices_positions[device] - 1, min_pos)
		devices_positions[device] = new_position
	#call event
	on_update_devices_positions.emit(devices_positions, show_unused_column)

## On press confirm, check if there are errors or succeed
func press_confirm():
	#check error
	var error_result = ErrorResult.new()
	on_check_errors.emit(error_result)
	#call error event
	if error_result.has_error:
		on_confirm_failed.emit(error_result.error_message)
	#or success event
	else:
		var players_devices : Array[Array] = get_players_devices()
		on_confirm_succeeded.emit(players_devices)

## On press cancel, call event
func press_cancel():
	on_cancel.emit()

#endregion

#region actions

## Duplicate necessary actions for this device
func duplicate_actions(device : int) -> void:
	var is_keyboard : bool = device == -1
	var is_joypad : bool = is_keyboard == false
	var suffix : String = get_device_suffix(device)
	if InputMap.has_action(move_left + suffix) == false:
		SplitScreenInputs.duplicate_action(move_left, move_left + suffix, device, is_joypad, is_keyboard)
		SplitScreenInputs.duplicate_action(move_right, move_right + suffix, device, is_joypad, is_keyboard)
		SplitScreenInputs.duplicate_action(confirm, confirm + suffix, device, is_joypad, is_keyboard)
		SplitScreenInputs.duplicate_action(cancel, cancel + suffix, device, is_joypad, is_keyboard)

## Remove actions for this device
func remove_actions(device : int) -> void:
	var suffix : String = get_device_suffix(device)
	if InputMap.has_action(move_left + suffix):
		SplitScreenInputs.remove_action(move_left + suffix)
		SplitScreenInputs.remove_action(move_right + suffix)
		SplitScreenInputs.remove_action(confirm + suffix)
		SplitScreenInputs.remove_action(cancel + suffix)

func get_device_suffix(device : int) -> String:
	return str(SUFFIX, device)

#endregion
