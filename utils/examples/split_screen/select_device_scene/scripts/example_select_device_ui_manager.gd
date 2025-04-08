## Manage the UI: instantiate prefabs, move object from parent to parent, etc...
class_name ExampleSelectDeviceUIManager extends Node

@export var select_device_manager : SelectDeviceManager
@export_category("Prefabs")
@export var column_prefab : PackedScene
@export var keyboard_prefab : PackedScene
@export var joypad_prefab : PackedScene
@export var empty_device_prefab : PackedScene
@export_category("UI")
@export var columns_container : Node
@export var cancel_button : Button
@export var confirm_button : Button
@export var label_in_scene : Label
@export var use_empty_to_fill_row : bool = true

## Containers are in order as in scene from left to right
var columns : Array[ExampleColumnUI]
## If true device_elements[0] is keyboard, else it contains only joypads
var has_keyboard : bool
## Keyboard is always element 0 if available
var device_elements : Array[ExampleDeviceElementUI]
## This is just a list of every Empty instantiated to fill rows
var empty_elements : Array[Node]

signal on_recreate_columns()

func _ready() -> void:
	#register to update event
	select_device_manager.on_update_devices_positions.connect(recreate_prefabs)
	#set buttons
	cancel_button.pressed.connect(func(): if select_device_manager.is_initialized: select_device_manager.press_cancel())
	confirm_button.pressed.connect(func(): if select_device_manager.is_initialized: select_device_manager.press_confirm())
	#update label
	var line1 := str("Move device with ", select_device_manager.move_right, " and ", select_device_manager.move_left)
	var line2 := str("\nPress ", select_device_manager.confirm, " to confirm or ", select_device_manager.cancel, " to cancel")
	label_in_scene.text = line1 + line2
	#destroy placeholders (be sure to not remove instantiated columns)
	for element in columns_container.get_children():
		if columns.has(element) == false:
			element.queue_free()

## Destroy previous instances and recreate prefabs for every device
func recreate_prefabs(devices_positions : Dictionary[int, int], show_unused_column : SelectDeviceManager.UnusedColumnPosition) -> void:
	#destroy instances and reset vars
	for element in device_elements:
		element.queue_free()
	device_elements.clear()
	for empty in empty_elements:
		empty.queue_free()
	empty_elements.clear()
	has_keyboard = false
	#recreate columns
	recreate_columns(select_device_manager.number_of_players, select_device_manager.show_unused_column)
	#instantiate devices prefabs
	has_keyboard = devices_positions.has(-1)
	for device in devices_positions:
		var pos : int = devices_positions[device]
		if show_unused_column == SelectDeviceManager.UnusedColumnPosition.LEFT:
			pos += 1
		elif show_unused_column == SelectDeviceManager.UnusedColumnPosition.RIGHT:
			pos -= 1
		instantiate_element(device, device == -1, pos)

## Destroy previous instances and recreate columns for every player (and "unused" column)
func recreate_columns(number_of_players : int, show_unused_column : SelectDeviceManager.UnusedColumnPosition) -> void:
	#destroy previous instances
	for element in columns:
		element.queue_free()
	columns.clear()
	#instantiate "unused" and players columns
	if show_unused_column == SelectDeviceManager.UnusedColumnPosition.LEFT:
		instantiate_obj(column_prefab, "Unused", columns, columns_container)
	for i in range(number_of_players):
		instantiate_obj(column_prefab, str("Player ", i+1), columns, columns_container)
	if show_unused_column == SelectDeviceManager.UnusedColumnPosition.RIGHT:
		instantiate_obj(column_prefab, "Unused", columns, columns_container)
	on_recreate_columns.emit()

## Instantiate Keyboard or Joypad prefab + Empty for every other column in the row
func instantiate_element(device : int, is_keyboard : bool, column_index : int) -> void:
	#instantiate keyboard or joypad prefab
	var prefab : PackedScene = keyboard_prefab if is_keyboard else joypad_prefab
	var text : String = "Keyboard" if is_keyboard else str("Gamepad ", device + 1)
	instantiate_obj(prefab, text, device_elements, columns[column_index].elements_container)
	#instantiate Empty prefab for every other container
	if use_empty_to_fill_row:
		for i in range(0, columns.size()):
			#ignore container where instantiate the prefab
			if i == column_index:
				continue
			instantiate_obj(empty_device_prefab, "", empty_elements, columns[i].elements_container)

##instantiate obj, call update_label, add to array and set parent
func instantiate_obj(prefab : PackedScene, text : String, array : Array, parent : Node) -> void:
	var instanced_obj : Node = prefab.instantiate()
	if instanced_obj.has_method("update_label"): instanced_obj.update_label(text)
	array.append(instanced_obj)
	parent.add_child.call_deferred(instanced_obj)

### Move element in columns list (right is +1, left is -1)
#func move_element(device : int, is_keyboard : bool, move_right : bool) -> void:
	##get element (keyboard or correct joypad)
	#var element_index = 0 if is_keyboard else (device + 1 if has_keyboard else device)
	#var element : DeviceElementUI = device_elements[element_index]
	##calculate new position
	#var current_parent : Node = element.get_parent()
	#var current_pos : int = columns.find(current_parent)
	#var new_pos : int = current_pos + (1 if move_right else -1)
	##if inside the list, move to new container
	#if new_pos >= 0 and new_pos < columns.size():
		#var new_parent : Node = columns[new_pos]
		#current_parent.remove_child.call_deferred(element)
		#new_parent.add_child.call_deferred(element)
		##get Empty in the same row and move it the opposite of this element
		##(from new_pos to current_pos)
		#if use_empty_to_fill_row:
			#var empty : Node = new_parent.get_child(element_index)
			#new_parent.remove_child.call_deferred(empty)
			#current_parent.add_child.call_deferred(empty)
			##update sibling indexes			
			#new_parent.move_child.call_deferred(element, element_index)
			#current_parent.move_child.call_deferred(empty, element_index)
