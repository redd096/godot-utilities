## ScrollContainer + drag with mouse or touch to scroll + scroll with keyboard or gamepad
class_name ScrollContainerHelper extends ScrollContainer


@export_group("Drag to Scroll")
## Can user drag with mouse or touch to scroll?
@export var enabled_drag_to_scroll: bool = true
## If emulate_mouse_from_touch is true in ProjectSettings, this should be off to avoid double events (both touch and mouse)
@export var check_also_touch_events: bool = false
## On ready, checks in ProjectSettings and set check_also_touch_events true or false based on emulate_mouse_from_touch
@export var automatically_set_touch_events: bool = true

@export_subgroup("Ignore Mouse Filter")
## If true, ignore MOUSE_FILTER of other Control nodes and use _input event. If false, use ScrollContainer's gui_input event
@export var ignore_mouse_filter: bool = true
## Consume input when read from _input event
@export var ignore_mouse_filter_consume_input: bool = true
## Consume input only when start drag. Drag is considered started when mouse move more than this threshold
@export var ignore_mouse_filter_consume_threshold: Vector2 = Vector2(3, 3)


@export_group("Scroll Horizontal")
## User can scroll with inputs (e.g. right analog stick or keyboard arrows), also without focus buttons
@export var enabled_scroll_horizontal: bool = true
@export var left_input_action: String = "ui_left"
@export var right_input_action: String = "ui_right"
@export var scroll_horizontal_sensitivity: float = 600


@export_group("Scroll Vertical")
## User can scroll with inputs (e.g. right analog stick or keyboard arrows), also without focus buttons
@export var enabled_scroll_vertical: bool = true
@export var up_input_action: String = "ui_up"
@export var down_input_action: String = "ui_down"
@export var scroll_vertical_sensitivity: float = 600


# "Drag to Scroll" drag with mouse or touch
var _dragging: bool
var _drag_start: Vector2
var _scroll_start: Vector2i
var _scrolled_enough_to_consume_input: bool


func _ready() -> void:
	# check touch events only if emulate_mouse_from_touch is false
	if automatically_set_touch_events:
		check_also_touch_events = not ProjectSettings.get_setting("input_devices/pointing/emulate_mouse_from_touch", true)


func _gui_input(event: InputEvent) -> void:
	# used to "Drag to Scroll", this could be affected by MOUSE_FILTER of other Control nodes
	_on_gui_input_update_drag_to_scroll(event)


func _input(event: InputEvent) -> void:
	# used to "Drag to Scroll", this is NEVER affected by MOUSE_FILTER of other Control nodes
	_on_input_update_drag_to_scroll(event)


func _process(delta: float) -> void:
	# used to "Scroll Horizontal or Vertical" with keyboard or gamepad inputs, also without focus buttons
	_scroll_by_input(delta)


#region drag to scroll


## Used to "Drag to Scroll", this could be affected by MOUSE_FILTER of other Control nodes
func _on_gui_input_update_drag_to_scroll(event: InputEvent) -> void:
	if enabled_drag_to_scroll and not ignore_mouse_filter:
		_update_drag_to_scroll(event)


## Used to "Drag to Scroll", this is NEVER affected by MOUSE_FILTER of other Control nodes
func _on_input_update_drag_to_scroll(event: InputEvent) -> void:
	if enabled_drag_to_scroll and ignore_mouse_filter and _is_necessary_input(event):
		# if it is left button pressed, be sure it is only inside scroll container
		if _is_left_click(event) and event.pressed:
			var rect := _get_content_global_rect()
			var mouse_pos := _get_global_point_position(event.position)
			if not rect.has_point(mouse_pos):
				return
		_update_drag_to_scroll(event)


## This is the effective "Drag to Scroll"
func _update_drag_to_scroll(event: InputEvent) -> void:
	# check left mouse button to start/stop drag
	if _is_left_click(event):
		_dragging = event.pressed	# start/stop drag on left click/release
		_drag_start = event.position
		_scroll_start = Vector2i(scroll_horizontal, scroll_vertical)
		
		# consume release if necessary
		if not event.pressed and ignore_mouse_filter and ignore_mouse_filter_consume_input and _scrolled_enough_to_consume_input:
			accept_event()
		_scrolled_enough_to_consume_input = false

	# then update scroll
	if _is_drag_input(event) and _dragging:
		var delta: Vector2 = event.position - _drag_start
		scroll_horizontal = (_scroll_start.x - delta.x) as int
		scroll_vertical = (_scroll_start.y - delta.y) as int

		if absf(delta.x) > ignore_mouse_filter_consume_threshold.x or absf(delta.y) > ignore_mouse_filter_consume_threshold.y:
			_scrolled_enough_to_consume_input = true



func _is_necessary_input(event: InputEvent) -> bool:
	return event is InputEventMouse \
		or (check_also_touch_events and (event is InputEventScreenTouch or event is InputEventScreenDrag))

func _is_left_click(event: InputEvent) -> bool:
	return (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT) \
		or (check_also_touch_events and event is InputEventScreenTouch and event.index == 0)

func _is_drag_input(event: InputEvent) -> bool:
	return event is InputEventMouseMotion \
		or (check_also_touch_events and event is InputEventScreenDrag)


func _get_content_global_rect() -> Rect2:
	# scrollContainer rect minus the scrollbars
	var rect := get_global_rect()
	var horizontal_scrollbar := get_h_scroll_bar()
	var vertical_scrollbar := get_v_scroll_bar()
	if horizontal_scrollbar.visible:
		rect.size.y -= horizontal_scrollbar.size.y
	if vertical_scrollbar.visible:
		rect.size.x -= vertical_scrollbar.size.x
	return rect

func _get_global_point_position(pos: Vector2) -> Vector2:
	# the same as get_global_mouse_position() but works with every position (e.g. for touch)
	return get_viewport().canvas_transform.affine_inverse() * pos


#endregion


#region scroll horizontal or vertical


## Used to "Scroll Horizontal or Vertical" with keyboard or gamepad inputs, also without focus buttons
func _scroll_by_input(delta: float) -> void:

	# scroll by input horizontal
	if enabled_scroll_horizontal:
		var axis := Input.get_axis(left_input_action, right_input_action)
		if axis != 0.0:
			scroll_horizontal += int(axis * scroll_horizontal_sensitivity * delta)

	# scroll by input vertical
	if enabled_scroll_vertical:
		var axis := Input.get_axis(up_input_action, down_input_action)
		if axis != 0.0:
			scroll_vertical += int(axis * scroll_vertical_sensitivity * delta)


#endregion