class_name ScrollContainerHelper extends Node

@export var scroll_container: ScrollContainer
@export var drag_to_scroll: bool = true
@export_group("Scroll Vertical")
@export var enabled_scroll_vertical: bool = true
@export var up_input_action: String = "ui_up"
@export var down_input_action: String = "ui_down"
@export var scroll_vertical_sensitivity: float = 600
@export_group("Scroll Horizontal")
@export var enabled_scroll_horizontal: bool = true
@export var left_input_action: String = "ui_left"
@export var right_input_action: String = "ui_right"
@export var scroll_horizontal_sensitivity: float = 600

# drag with mouse click
var _dragging := false
var _drag_start := Vector2.ZERO
var _scroll_start := Vector2.ZERO

func _ready() -> void:
	scroll_container.gui_input.connect(_on_gui_input)

func _process(delta: float) -> void:
	_scroll_by_input(delta)

func _on_gui_input(event: InputEvent) -> void:
	if not drag_to_scroll:
		return
	
	# check left mouse button to start drag
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_dragging = event.pressed	# start/stop drag on left click/release
		_drag_start = event.position
		_scroll_start = Vector2(scroll_container.scroll_horizontal, scroll_container.scroll_vertical)

	# then update scroll
	if event is InputEventMouseMotion and _dragging:
		var delta: Vector2 = event.position - _drag_start
		scroll_container.scroll_vertical = _scroll_start.y - int(delta.y)

## Used to scroll with keyboard or gamepad inputs without need focus buttons
func _scroll_by_input(delta: float) -> void:
	# scroll by input vertical
	if enabled_scroll_vertical:
		var axis := Input.get_axis(up_input_action, down_input_action)
		if axis != 0.0:
			scroll_container.scroll_vertical += int(axis * scroll_vertical_sensitivity * delta)

	# scroll by input horizontal
	if enabled_scroll_horizontal:
		var axis := Input.get_axis(left_input_action, right_input_action)
		if axis != 0.0:
			scroll_container.scroll_horizontal += int(axis * scroll_horizontal_sensitivity * delta)