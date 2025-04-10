class_name ExampleMinimalSelectDeviceSceneManager extends Node

@export var select_device : MinimalSelectDeviceManager
@export var labels_container : Node
@export var label_in_scene : Label

## For every player (every array element), save the instantiated Label
var instantiated_labels : Array[Label]

func _ready() -> void:
	#remove placeholders (be sure to not remove instantiated labels)
	for node in labels_container.get_children():
		if instantiated_labels.has(node) == false:
			node.queue_free()
	#register to events
	select_device.on_add_player.connect(add_player_device)
	select_device.on_remove_player.connect(remove_player_device)
	#update label
	var line1 := str("Press ", select_device.add_player, " to connect device")
	var line2 := str("\nPress ", select_device.remove_player, " to disconnect device")
	label_in_scene.text = line1 + line2

## Instantiate a Label and set its text
func add_player_device(player_index : int, device : int, is_keyboard : bool):
	if select_device.on_disconnect_resize_array or player_index >= instantiated_labels.size():
		#instantiate a Label and set its text
		var label : Label = Label.new()
		label.text = get_label_text(player_index, device, is_keyboard)
		labels_container.add_child(label)
		#add to list
		instantiated_labels.append(label)
	else:
		#or just update label text
		var label : Label = instantiated_labels[player_index]
		label.text = get_label_text(player_index, device, is_keyboard)

## Destroy Label and update successive Labels if necessary
func remove_player_device(player_index : int, _device : int, _is_keyboard : bool):
	if select_device.on_disconnect_resize_array:
		#destroy label
		instantiated_labels[player_index].queue_free()
		instantiated_labels.remove_at(player_index)
		#get every label after this one
		for i in range(player_index, instantiated_labels.size()):
			var label : Label = instantiated_labels[i]
			var previous_player : String = str(i + 1)
			var previous_player_position_in_text : int = label.text.find(previous_player)
			#replace previous player_index with new one
			label.text = label.text.erase(previous_player_position_in_text, previous_player.length())
			label.text = label.text.insert(previous_player_position_in_text, str(i))
	else:
		#or just update label text
		var label : Label = instantiated_labels[player_index]
		label.text = str("Player ", player_index, " - Device: NULL")

func get_label_text(player_index : int, device : int, is_keyboard : bool) -> String:
	var device_text : String
	if is_keyboard:
		device_text = str("Keyboard (", device, ")") 
	else:
		device_text = str("Gamepad ", device + 1)
	return str("Player ", player_index, " - Device: ", device_text)
