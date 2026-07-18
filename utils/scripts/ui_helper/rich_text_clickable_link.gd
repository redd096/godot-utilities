class_name RichTextClickableLink extends Node

@export var richtextlabel: RichTextLabel
## If emulate_mouse_from_touch is true in project settings, this should be off to avoid double events (both touch and mouse)
@export var check_also_touch_events: bool = false
## On ready, checks in Project Settings and set check_also_touch_events true or false based on emulate_mouse_from_touch
@export var automatically_set_touch_events: bool = true

# workaround to avoid infinite loop when emulate_touch_from_mouse is true
var _avoid_error_with_emulate_touch_from_mouse: bool


func _ready():
	# check touch events only if emulate_mouse_from_touch is false
	if automatically_set_touch_events:
		check_also_touch_events = not ProjectSettings.get_setting("input_devices/pointing/emulate_mouse_from_touch", true)

	# register events (meta_clicked already is called when click a link, but works only with mouse)
	richtextlabel.meta_clicked.connect(_on_meta_clicked)
	richtextlabel.gui_input.connect(_on_gui_input)


func _on_meta_clicked(meta: Variant):
	# `meta` is of Variant type, so convert it to a String to avoid script errors at run-time. 
	# (copy-paste from meta_clicked documentation)
	OS.shell_open(str(meta))


func _on_gui_input(event: InputEvent) -> void:
	# use gui_input to manage also touch events
	if not check_also_touch_events:
		return
	
	# if release touch on this label
	var touch: InputEventScreenTouch = event as InputEventScreenTouch
	if touch and !touch.double_tap and touch.index == 0 and not touch.pressed:

		# if we receive event before variable is false again, this is because our InputEventMouseButton generated a InputEventScreenTouch too
		if _avoid_error_with_emulate_touch_from_mouse:
			return

		# from local to global position, because we need to send raw input
		var global_pos: Vector2 = richtextlabel.get_global_transform() * touch.position

		# create a mouse click event, to try execute meta_cliked
		var mouse_pressed := InputEventMouseButton.new()
		mouse_pressed.button_index = MOUSE_BUTTON_LEFT
		mouse_pressed.pressed = true
		mouse_pressed.position = global_pos
		mouse_pressed.global_position = global_pos
		mouse_pressed.button_mask = 1

		var mouse_released = mouse_pressed.duplicate()
		mouse_released.pressed = false
		mouse_released.button_mask = 0

		# emit event
		_avoid_error_with_emulate_touch_from_mouse = true

		Input.parse_input_event(mouse_pressed)
		Input.parse_input_event(mouse_released)
		
		await get_tree().create_timer(0.1).timeout
		_avoid_error_with_emulate_touch_from_mouse = false