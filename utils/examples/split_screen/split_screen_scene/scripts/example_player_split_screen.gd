class_name ExamplePlayerSplitScreen extends Node

## -2 is null, -1 is only keyboard, from 0 to number of players is the joypad index
@export var player_index : int
## If there is only one player, ignore player index and use inputs set in editor. 
## So works with both mouse and joypad
@export var single_player_use_every_device : bool = true
@export var body : CharacterBody3D
@export var camera : Camera3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var input_suffix : String

func _ready() -> void:
	#set default device
	update_device(player_index)

func update_device(device : int) -> void:
	#save suffix
	player_index = device
	input_suffix = SplitScreenInputs.get_device_suffix(player_index)
	#if already in gameplay scene and there is only one player, 
	#use both mouse and keyboard set by default in project
	if single_player_use_every_device:
		var split_screen_manager : SplitScreenManager = Singleton.instance(SplitScreenManager)
		if (split_screen_manager and split_screen_manager.number_of_players == 1):
			input_suffix = ""

func _physics_process(delta: float) -> void:	
	# Add the gravity.
	if not body.is_on_floor():
		body.velocity += body.get_gravity() * delta

	# Handle jump.
	var jump_pressed : bool = Input.is_action_just_pressed("ui_select" + input_suffix) if player_index >= -1 else false
	if jump_pressed and body.is_on_floor():
		body.velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left" + input_suffix, "ui_right" + input_suffix, "ui_up" + input_suffix, "ui_down" + input_suffix) if player_index >= -1 else Vector2.ZERO
	var direction := (body.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		body.velocity.x = direction.x * SPEED
		body.velocity.z = direction.z * SPEED
	else:
		body.velocity.x = move_toward(body.velocity.x, 0, SPEED)
		body.velocity.z = move_toward(body.velocity.z, 0, SPEED)

	body.move_and_slide()
