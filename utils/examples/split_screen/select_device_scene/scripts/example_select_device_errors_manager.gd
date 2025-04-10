class_name ExampleSelectDeviceErrorsManager extends Node

@export var select_device_manager : SelectDeviceManager
@export var ui_manager : ExampleSelectDeviceUIManager
@export var error_color : Color = Color.DARK_RED
@export var only_one_device_per_column : bool = true
@export var at_least_one_player_set : bool = true

var default_colors : Array[Color]

func _ready() -> void:
	#register to events
	select_device_manager.on_update_devices_positions.connect(on_update_devices_positions)
	select_device_manager.on_check_errors.connect(on_check_errors)
	select_device_manager.on_cancel.connect(on_cancel)
	select_device_manager.on_confirm_succeeded.connect(on_confirm_succeeded)
	select_device_manager.on_confirm_failed.connect(on_confirm_failed)
	ui_manager.on_recreate_columns.connect(recalculate_default_colors)

func on_update_devices_positions(_devices_positions : Dictionary[int, int], show_unused_column : SelectDeviceManager.UnusedColumnPosition) -> void:
	var players_devices : Array[Array] = select_device_manager.get_players_devices()
	#check if some player has more devices and color its column
	if only_one_device_per_column:
		#be sure to ignore "unused" column
		var ignore_unused_column : int = 1 if show_unused_column == SelectDeviceManager.UnusedColumnPosition.LEFT else 0
		for i in range(players_devices.size()):
			var column_index = i + ignore_unused_column
			ui_manager.columns[column_index].color_rect.color = error_color if players_devices[i].size() > 1 else default_colors[column_index]
	#check if at least one player has a device, else color "unused" column
	if at_least_one_player_set:
		var unused_index : int = 0 if show_unused_column == SelectDeviceManager.UnusedColumnPosition.LEFT else ui_manager.columns.size() - 1
		var color : Color = default_colors[unused_index] if check_at_least_one_player_set(players_devices) else error_color
		ui_manager.columns[unused_index].color_rect.color = color

func on_check_errors(output_error : SelectDeviceManager.ErrorResult) -> void:
	var players_devices : Array[Array] = select_device_manager.get_players_devices()
	#if some player has more devices, set error
	if only_one_device_per_column:
		for i in players_devices.size():
			var devices_count : int = players_devices[i].size()
			if devices_count > 1:
				output_error.has_error = true
				output_error.error_message += str("Player ", i, " has more than one device. [", devices_count, "] \n")
	#if nobody has a device, set error
	if at_least_one_player_set:
		if check_at_least_one_player_set(players_devices) == false:
			output_error.has_error = true
			output_error.error_message += "There aren't players with a connected device!"

func on_cancel() -> void:
	print("SelectDeviceErrorsManager: Cancel!")

func on_confirm_succeeded(players_devices : Array[Array]) -> void:
	print("SelectDeviceErrorsManager: Confirm Success!") 
	for i in players_devices.size(): 
		var s : String = ""
		for device in players_devices[i]: 
			s += str(device, ",")
		print ("SelectDeviceErrorsManager: Player ", i, " has device: ", s)

func on_confirm_failed(error_message : String) -> void:
	print("SelectDeviceErrorsManager: Confirm Failed! \n", error_message)

## Save default colors for every ui column
func recalculate_default_colors() -> void:
	for column in ui_manager.columns:
		default_colors.append(column.color_rect.color)

## If at least one player has a device, return true. Else return false
func check_at_least_one_player_set(players_devices : Array[Array]) -> bool:
	for i in players_devices.size():
		var devices_count : int = players_devices[i].size()
		if devices_count > 0:
			return true
	return false
