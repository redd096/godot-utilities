class_name ScrollContainerHelper extends Node

@export var scroll_container: ScrollContainer
@export_group("Drag to Scroll")
## Can user drag with mouse or touch to scroll?
@export var enabled_drag_to_scroll: bool = true
## If true, ignore MOUSE_FILTER_STOP of other Control nodes
@export var ignore_mouse_filter_stop: bool = true
@export_group("Scroll Vertical")
## User can scroll with inputs (e.g. right analog stick or keyboard arrows)
@export var enabled_scroll_vertical: bool = true
@export var up_input_action: String = "ui_up"
@export var down_input_action: String = "ui_down"
@export var scroll_vertical_sensitivity: float = 600
@export_group("Scroll Horizontal")
## User can scroll with inputs (e.g. right analog stick or keyboard arrows)
@export var enabled_scroll_horizontal: bool = true
@export var left_input_action: String = "ui_left"
@export var right_input_action: String = "ui_right"
@export var scroll_horizontal_sensitivity: float = 600

# drag with mouse click
var _dragging := false
var _drag_start := Vector2.ZERO
var _scroll_start := Vector2.ZERO

func _ready() -> void:
	# used to drag to scroll, this could be disabled by MOUSE_FILTER_STOP of other Control nodes
	scroll_container.gui_input.connect(_on_gui_input)

func _input(event: InputEvent) -> void:
	# used to drag to scroll, this is NEVER affected by MOUSE_FILTER_STOP of other Control nodes
	_on_input_update_drag_to_scroll(event)

func _process(delta: float) -> void:
	_scroll_by_input(delta)

#region drag to scroll

func _on_gui_input(event: InputEvent) -> void:
	if enabled_drag_to_scroll and not ignore_mouse_filter_stop:
		_update_drag_to_scroll(event)

func _on_input_update_drag_to_scroll(event: InputEvent) -> void:
	if enabled_drag_to_scroll and ignore_mouse_filter_stop and event is InputEventMouse:
		# if it is left button pressed, be sure it is only inside scroll container
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var rect := _get_content_global_rect()
			var mouse_pos := scroll_container.get_global_mouse_position()
			if not rect.has_point(mouse_pos):
				return
		_update_drag_to_scroll(event)

## Used to scroll with mouse drag
func _update_drag_to_scroll(event: InputEvent) -> void:
		# check left mouse button to start/stop drag
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = event.pressed	# start/stop drag on left click/release
			_drag_start = event.position
			_scroll_start = Vector2(scroll_container.scroll_horizontal, scroll_container.scroll_vertical)

		# then update scroll
		if event is InputEventMouseMotion and _dragging:
			var delta: Vector2 = event.position - _drag_start
			scroll_container.scroll_horizontal = (_scroll_start.x - delta.x) as int
			scroll_container.scroll_vertical = (_scroll_start.y - delta.y) as int

func _get_content_global_rect() -> Rect2:
	# scrollContainer rect minus the scrollbars
	var rect := scroll_container.get_global_rect()
	var v_scrollbar := scroll_container.get_v_scroll_bar()
	var h_scrollbar := scroll_container.get_h_scroll_bar()
	if v_scrollbar.visible:
		rect.size.x -= v_scrollbar.size.x
	if h_scrollbar.visible:
		rect.size.y -= h_scrollbar.size.y
	return rect

#endregion

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
