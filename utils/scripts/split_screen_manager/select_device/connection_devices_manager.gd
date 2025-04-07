## Manage connected devices and call event when a device connect or disconnect
class_name ConnectionDevicesManager extends Node

var connected_joypads : Array[int]
var is_mouse_or_keyboard_available : bool

signal on_changed_devices_connection()

func _ready() -> void:
	#register to event to know when joypad connect or disconnect
	Input.joy_connection_changed.connect(on_joy_connection_changed)
	#get current connected joypads
	connected_joypads = Input.get_connected_joypads()
	on_changed_devices_connection.emit()

func _unhandled_input(event: InputEvent) -> void:
	#if a mouse or keyboard event is registered, then this machine has it
	if is_mouse_or_keyboard_available == false and \
	(event is InputEventMouse or event is InputEventKey):
		is_mouse_or_keyboard_available = true
		on_changed_devices_connection.emit()

func on_joy_connection_changed(_device : int, _connected : bool):
	#when a joypad connect or disconnect, update the list
	connected_joypads = Input.get_connected_joypads()
	on_changed_devices_connection.emit()
