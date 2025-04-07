class_name SelectDeviceErrorsManager extends Node

@export var select_device_manager : SelectDeviceManager
@export_category("Only one device per column")
@export var only_one_device_per_column : bool = true
@export var error_color : Color = Color.RED
@export var ui_manager : SelectDeviceUIManager

var is_initialized : bool
var default_colors : Array[Color]

func initialize_manager() -> void:
	if is_initialized:
		return
	#save default colors
	for column in ui_manager.columns:
		default_colors.append(column.color_rect.color)
	#register to events
	select_device_manager.on_update_devices_positions.connect(on_update_devices_positions)
	select_device_manager.on_check_errors.connect(on_check_errors)
	select_device_manager.on_cancel.connect(on_cancel)
	select_device_manager.on_confirm_succeeded.connect(on_confirm_succeeded)
	select_device_manager.on_confirm_failed.connect(on_confirm_failed)
	#update var
	is_initialized = true

func deinitialize_manager() -> void:
	if is_initialized == false:
		return
	#clear colors
	default_colors.clear()
	#unregister from events
	select_device_manager.on_update_devices_positions.disconnect(on_update_devices_positions)
	select_device_manager.on_check_errors.disconnect(on_check_errors)
	select_device_manager.on_cancel.disconnect(on_cancel)
	select_device_manager.on_confirm_succeeded.disconnect(on_confirm_succeeded)
	select_device_manager.on_confirm_failed.disconnect(on_confirm_failed)
	#update var
	is_initialized = false

func on_update_devices_positions(_devices_positions : Dictionary[int, int], show_unused_column : SelectDeviceManager.UnusedColumnPosition) -> void:
	if only_one_device_per_column == false:
		return
	#check if some player has more devices and color its column
	var players_devices : Array[Array] = select_device_manager.get_players_devices()
	#be sure to ignore "unused" column
	var ignore_unused_column : int = 1 if show_unused_column == SelectDeviceManager.UnusedColumnPosition.LEFT else 0
	for i in range(players_devices.size()):
		var column_index = i + ignore_unused_column
		ui_manager.columns[column_index].color_rect.color = error_color if players_devices[i].size() > 1 else default_colors[column_index]

func on_check_errors(output_error : SelectDeviceManager.ErrorResult) -> void:
	#if some player has more devices, set error
	var players_devices : Array[Array] = select_device_manager.get_players_devices()
	for i in players_devices.size():
		var devices_count : int = players_devices[i].size()
		if devices_count > 1:
			output_error.has_error = true
			output_error.error_message += str("Player ", i, " has more than one device. [", devices_count, "] \n")

func on_cancel() -> void:
	print("Cancel!")

func on_confirm_succeeded(players_devices : Array[Array]) -> void:
	print("Confirm Success!") 
	for i in players_devices.size(): 
		var s : String = ""
		for device in players_devices[i]: 
			s += str(device, ",")
		print ("Player ", i, " has device: ", s)

func on_confirm_failed(error_message : String) -> void:
	print("Confirm Failed! \n", error_message)
