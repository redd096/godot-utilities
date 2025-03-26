extends Node

class_name SplitScreenManager 
## Split screen in _ready() function. If false, you have to call manually update_split_screen()
@export var auto_start : bool = true
## Number of players for this game
@export_range(1, 4) var number_of_players : int = 1
## True = split up and down, False = split left and right
@export var prefer_vertical : bool = true
## If false, set Camera child of SubViewport. If true, set Camera's Parent child of SubViewport
@export var keep_camera_parent : bool
## Your players in scene and in the correct order (player 1, player 2, etc...). If they exceed the number of players, they are destroyed
@export var players : Array[Node]
## Your cameras in scene and in the correct order (cam for player 1, cam for player 2, etc...). If they aren't set, will try to get camera inside the player
@export var cameras : Array[Node]
## If cameras is null or empty, try get Camera2D or Camera3D in players childs
@export var is_camera_2d : bool

## Screen rect for every camera
var viewports_rects : Array[Rect2]

func _ready() -> void:
	if auto_start:
		update_split_screen()

func update_split_screen() -> void:
	var players_ok = destroy_exceed_players()
	var cameras_ok = get_cameras()
	var rects_ok = get_viewports_rects()
	if (players_ok && cameras_ok && rects_ok):
		set_cameras()
		add_inputs()

## Destroy players exceed number_of_players
func destroy_exceed_players() -> bool:
	#be sure there is the correct number of players
	if number_of_players > players.size():
		push_error(str("Need ", number_of_players, " players but they are ", players.size()))
		return false
		
	for i in range(number_of_players, players.size()):
		players[i].process_mode = Node.PROCESS_MODE_DISABLED
		players[i].queue_free()
	
	return true

## Be sure to have cameras
func get_cameras() -> bool:
	#if null, find cameras in players
	if cameras == null || cameras.size() == 0:
		cameras = SplitScreenViewports.get_child_cameras(number_of_players, players, is_camera_2d)
		return cameras.size() == number_of_players
	#else, be sure there is the correct number of cameras
	elif number_of_players > cameras.size():
		push_error(str("Need ", number_of_players, " cameras but they are ", cameras.size()))
		return false
		
	return true

## Get viewport rect for every camera
func get_viewports_rects() -> bool:
	viewports_rects = SplitScreenViewports.get_viewports_rects(number_of_players, prefer_vertical)
	return viewports_rects.size() == number_of_players

## Split vertical and horizontal
func set_cameras():
	for i in number_of_players:
		SplitScreenViewports.set_camera_viewport(cameras[i], viewports_rects[i], str("Camera Player ", i), keep_camera_parent)

## Duplicate inputs for every player
func add_inputs():
	#create a copy of joypad inputs for every device
	for i in range(number_of_players):
		SplitScreenInputs.add_device(i, true, false)
	#create also a copy of mouse and keyboard inputs with device suffix -1
	SplitScreenInputs.add_device(-1, false, true)
