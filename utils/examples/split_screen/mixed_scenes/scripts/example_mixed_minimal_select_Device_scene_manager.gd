class_name ExampleMixedMinimalSelectDeviceSceneManager extends Node

@export_range(1, 4) var number_of_players : int = 1
@export var split_screen_manager : SplitScreenManager
@export var select_device : MinimalSelectDeviceManager

func _ready() -> void:
	#register to events
	select_device.on_add_player.connect(add_player_device)
	select_device.on_remove_player.connect(remove_player_device)
	#update split screen
	split_screen_manager.number_of_players = number_of_players
	split_screen_manager.auto_start = false
	split_screen_manager.update_split_screen()
	#and select_device_manager
	select_device.max_number_of_players = number_of_players
	#by default, remove every device in scene
	for player : ExamplePlayerSplitScreen in split_screen_manager.players:
		player.update_device(-2)

## Find first player without device and add to it
func add_player_device(player_index : int, device : int, _is_keyboard : bool):
	for player : ExamplePlayerSplitScreen in split_screen_manager.players:
		if player.player_index < -1:
			player.update_device(device)
			break

## Remove device
func remove_player_device(_player_index : int, device : int, _is_keyboard : bool):
	for player : ExamplePlayerSplitScreen in split_screen_manager.players:
		if player.player_index == device:
			player.update_device(-2)
			break
