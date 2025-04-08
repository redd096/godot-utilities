class_name SplitScreenInputs

const SUFFIX : String = "_device"

## Duplicate every action with a new suffix for this device
static func add_device(device : int, duplicate_joypad_events : bool, duplicate_keyboard_and_mouse_events : bool) -> void:
	var device_suffix = get_device_suffix(device)
	for base_action in InputMap.get_actions():
		var new_action : String = base_action + device_suffix
		duplicate_action(base_action, new_action, device, duplicate_joypad_events, duplicate_keyboard_and_mouse_events)

## Remove every action for this device
static func remove_device(device : int) -> void:
	var device_suffix = get_device_suffix(device)
	for base_action in InputMap.get_actions():
		var action_name : String = base_action + device_suffix
		remove_action(action_name)

## Return device suffix. Save it to to call actions
## e.g. Input.is_action_pressed("ui_select" + device_suffix)
static func get_device_suffix(device : int) -> String:
	return str(SUFFIX, device)

## Duplicate base_action and add device_suffix.
## Return true if the action is created
static func duplicate_action(base_action : String, new_action : String, device : int, duplicate_joypad_events : bool, duplicate_keyboard_and_mouse_events : bool) -> bool:
	#be sure this action doesn't already exists
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

## Remove action with this name (NB force action release to avoid InputMap errors). 
## Return true if the action is removed
static func remove_action(action_name : String) -> bool:
	#be sure this action exists
	if InputMap.has_action(action_name) == false:
		push_error(str("Doesn't exists an action with this name: ", action_name))
		return false
	
	#delete action (force release to avoid InputMap errors)
	Input.action_release(action_name)
	InputMap.erase_action(action_name)
	return true
