@tool
class_name QuickProjectSettings
extends Node
## Editor helper for configuring common settings in a new project. [br]
## Add this script to a Node, press the desired buttons, then remove the Node.


#region inputs


@export_group("Inputs")


## Add gamepad to UI buttons
@export_tool_button("Add gamepad UI buttons")
var add_gamepad_ui_buttons: Callable = _add_gamepad_ui_buttons


const INPUTS_SETTING: String = "input/"
const ACTION_EVENTS_SETTING: String = "events"
const UI_ACCEPT_ACTION: StringName = &"ui_accept"
const UI_CANCEL_ACTION: StringName = &"ui_cancel"
const GAMEPAD_ACCEPT_BUTTON: JoyButton = JoyButton.JOY_BUTTON_A
const GAMEPAD_CANCEL_BUTTON: JoyButton = JoyButton.JOY_BUTTON_B


func _add_gamepad_ui_buttons() -> void:
	# add accept and cancel gamepad button for ui
	var changed: bool = false
	changed = _add_gamepad_button(UI_ACCEPT_ACTION, GAMEPAD_ACCEPT_BUTTON) or changed
	changed = _add_gamepad_button(UI_CANCEL_ACTION, GAMEPAD_CANCEL_BUTTON) or changed

	if changed:
		_save_project_settings("Gamepad UI buttons added")
	else:
		_warning_message("Gamepad UI buttons are already added to InputMap")


func _add_gamepad_button(action: StringName, joypad_button: JoyButton) -> bool:
	# get action from settings (instead of InputMap)
	var action_setting_path: String = INPUTS_SETTING + action
	if not ProjectSettings.has_setting(action_setting_path):
		_warning_message("There is NOT '", action, "' in InputMap. I'm creating it with InputEvent: ", joypad_button)
	var action_data: Dictionary = ProjectSettings.get_setting(action_setting_path, 
		{
			"deadzone": 0.5,
			"events": []
		}).duplicate(true)
	
	# get its events
	var events: Array = action_data.get(ACTION_EVENTS_SETTING, []).duplicate()

	# if already contains this event, return false
	if _contains_joypad_button(events, joypad_button):
		_warning_message("Action '", action, "' already contains InputEvent: ", joypad_button)
		return false
	
	# else, add this input event
	var joypad_event := InputEventJoypadButton.new()
	joypad_event.device = -1					# any gamepad
	joypad_event.button_index = joypad_button	# button index

	events.append(joypad_event)
	action_data[ACTION_EVENTS_SETTING] = events
	
	# update settings
	ProjectSettings.set_setting(action_setting_path, action_data)

	return true


func _contains_joypad_button(events: Array, joypad_button: JoyButton) -> bool:
	# check if contains a Joypad event with this button
	for event: Variant in events:
		if event is InputEventJoypadButton and event.button_index == joypad_button:
			return true

	return false

#endregion


#region canvas stretch


@export_group("Canvas stretch")


## Set stretch mode for 3D
@export_tool_button("Set canvas for 3D")
var set_canvas_for_3d: Callable = _set_canvas_for_3d


## Set stretch mode for 2D Pixel
@export_tool_button("Set canvas for 2D pixel art")
var set_canvas_for_2d_pixel_art: Callable = _set_canvas_for_2d_pixel_art


const STRETCH_MODE_SETTING: String = "display/window/stretch/mode"
const CANVAS_ITEMS_MODE: String = "canvas_items"
const VIEWPORT_MODE: String = "viewport"


func _set_canvas_for_3d() -> void:
	_set_canvas_internal(CANVAS_ITEMS_MODE, "Canvas stretch mode set to '", CANVAS_ITEMS_MODE, "' for 3D")


func _set_canvas_for_2d_pixel_art() -> void:
	_set_canvas_internal(VIEWPORT_MODE, "Canvas stretch mode set to '", VIEWPORT_MODE, "' for 2D pixel art")


func _set_canvas_internal(stretch_mode: String, ...success_message: Array) -> void:
	# update stretch mode
	var setting: String = ProjectSettings.get_setting(STRETCH_MODE_SETTING, "")
	if setting != stretch_mode:
		ProjectSettings.set_setting(STRETCH_MODE_SETTING, stretch_mode)
		_save_project_settings(success_message)
	# if not already set
	else:
		_warning_message("Canvas stretch mode is already '", stretch_mode, "'")


#endregion


func _save_project_settings(...success_message: Array) -> void:
	var save_error: Error = ProjectSettings.save()
	if save_error == OK:
		print("Quick Project Settings SUCCESS: ", success_message)
		push_warning("Project Settings saved! Reload the project to avoid cache bugs")
	else:
		push_error("Quick Project Settings ERROR: Cannot save Project Settings: ", error_string(save_error))


func _warning_message(...message: Array) -> void:
	push_warning("Quick Project Settings WARNING: ", message)
