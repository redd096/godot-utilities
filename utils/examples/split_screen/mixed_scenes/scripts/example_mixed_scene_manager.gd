class_name ExampleMixedSceneManager extends Node

@export_range(1, 4) var number_of_players : int = 1
@export var label_in_scene : Label
@export_category("Split Screen")
@export var split_screen_manager : SplitScreenManager
@export var open_menu : String = "ui_cancel"
@export_category("Select Device")
@export var select_device_container : Control
@export var select_device_manager : SelectDeviceManager
@export var label_select_device : Label

var is_in_game : bool
var enabled_players : Array[int]

func _ready() -> void:
	#register to events
	select_device_manager.on_confirm_succeeded.connect(on_confirm_succeeded)
	select_device_manager.on_cancel.connect(on_cancel)
	#update split screen
	split_screen_manager.number_of_players = number_of_players
	split_screen_manager.auto_start = false
	split_screen_manager.update_split_screen()
	#and select_device_manager
	select_device_manager.number_of_players = number_of_players
	select_device_manager.initialize_on_ready = false
	select_device_manager.process_mode = Node.PROCESS_MODE_DISABLED #because maybe it isn't still initialized
	#start from game
	back_to_game()
	#update label
	label_in_scene.text = str("Press ", open_menu, " to change devices")

func _unhandled_input(event: InputEvent) -> void:
	if is_in_game:
		#if any player press "open_menu" do it
		for i in number_of_players:
			var player : ExamplePlayerSplitScreen = split_screen_manager.players[i]
			if player.player_index >= -1 and event.is_action_pressed(open_menu + player.input_suffix):
				open_select_device_menu()
				break

func open_select_device_menu():
	#wait one frame to avoid same input trigger open_select_device_menu() and cancel()
	is_in_game = false
	await get_tree().process_frame
	#disable players
	for i in number_of_players:
		split_screen_manager.players[i].process_mode = Node.PROCESS_MODE_DISABLED
	#and show select device menu
	select_device_container.show()
	select_device_manager.initialize_manager()
	label_select_device.show()

func back_to_game():
	#re-enable players
	for i in number_of_players:
		split_screen_manager.players[i].process_mode = Node.PROCESS_MODE_INHERIT
	#and disable select_device scene
	select_device_container.hide()
	select_device_manager.deinitialize_manager()
	label_select_device.hide()
	#wait one frame to avoid same input trigger open_select_device_menu() and cancel()
	await get_tree().process_frame
	is_in_game = true

func on_confirm_succeeded(players_devices : Array[Array]):
	#update players input_suffix
	for i in players_devices.size():
		var device = players_devices[i][0] if players_devices[i].size() > 0 else -2
		split_screen_manager.players[i].update_device(device)
	#and back to game
	back_to_game()

func on_cancel():
	#and back to game without change devices
	back_to_game()
