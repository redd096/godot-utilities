extends Node

class_name Player

@export var player_index : int
@export var body : CharacterBody3D
@export var camera : Camera3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var input_suffix : String

func _ready() -> void:
	#save input_suffix for multiple gamepad. If lower than 0 is keyboard, so ignore suffix
	if player_index >= 0:
		input_suffix = SplitScreenInputs.get_device_suffix(player_index)
	else:
		input_suffix = ""

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not body.is_on_floor():
		body.velocity += body.get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept" + input_suffix) and body.is_on_floor():
		body.velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left" + input_suffix, "ui_right" + input_suffix, "ui_up" + input_suffix, "ui_down" + input_suffix)
	var direction := (body.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		body.velocity.x = direction.x * SPEED
		body.velocity.z = direction.z * SPEED
	else:
		body.velocity.x = move_toward(body.velocity.x, 0, SPEED)
		body.velocity.z = move_toward(body.velocity.z, 0, SPEED)

	body.move_and_slide()
