class_name MinimalSelectDeviceSceneManager extends Node

@export var select_device : MinimalSelectDeviceManager
@export var labels_container : Node

## Key: player_index, Value: instantiated Label
var instantiated_labels : Dictionary[int, Label]

func _ready() -> void:
	#remove placeholders (be sure to not remove instantiated labels)
	for node in labels_container.get_children():
		if instantiated_labels.values().has(node) == false:
			node.queue_free()

## Instantiate a Label and set its text
func add_player_device(player_index : int, device : int, is_keyboard : bool):
	var label : Label = Label.new()
	var device_text : String = str("Keyboard (", device, ")") if is_keyboard else str("Gamepad ", device + 1)
	label.text = str("Player ", player_index, " - Device: ", device_text)
	#add to dictionary
	instantiated_labels.get_or_add(player_index, label)

## Destroy Label 
func remove_player_device(player_index : int, _device : int, _is_keyboard : bool):
	instantiated_labels[player_index].queue_free()
	instantiated_labels.erase(player_index)
