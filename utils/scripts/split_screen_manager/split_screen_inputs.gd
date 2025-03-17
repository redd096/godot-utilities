class_name SplitScreenInputs

const SUFFIX : String = "_device"

## Duplicate every action with a new suffix for this device
static func add_device(device : int, duplicate_joypad_events : bool, duplicate_keyboard_and_mouse_events : bool):
	var device_suffix = get_device_suffix(device)
	for base_action in InputMap.get_actions():
		duplicate_action(base_action, device, device_suffix, duplicate_joypad_events, duplicate_keyboard_and_mouse_events)

## Return device suffix. Save it to to call actions
## e.g. Input.is_action_pressed("ui_select" + device_suffix)
static func get_device_suffix(device : int) -> String:
	return str(SUFFIX, device)

## Duplicate base_action and add device_suffix.
## Return true if the action is created
static func duplicate_action(base_action : String, device : int, device_suffix : String, duplicate_joypad_events : bool, duplicate_keyboard_and_mouse_events : bool) -> bool:
	#be sure this action doesn't already exists
	var new_action = base_action + device_suffix
	if InputMap.has_action(new_action):
		push_error(str("Already exists an action with this name: ", new_action))
		return false
	
	#create action
	var deadzone = InputMap.action_get_deadzone(base_action)
	InputMap.add_action(new_action, deadzone)
	
	#add every event to the new action
	for event in InputMap.action_get_events(base_action):
		#but only correct events (joypad or mouse)
		if (duplicate_joypad_events and (event is InputEventJoypadButton or event is InputEventJoypadMotion)) \
		or (duplicate_keyboard_and_mouse_events and (event is InputEventMouse or event is InputEventKey)):
			var new_event = event.duplicate()
			new_event.device = device
			InputMap.action_add_event(new_action, new_event)
			
	return true
