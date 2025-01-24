class_name SplitScreenInputs

const suffix : String = "_device"
static var actions : Dictionary = {}

## Duplicate every Joypad action with a new suffix for this device
static func add_device(device : int):
	var device_suffix = get_device_suffix(device)
	for base_action in InputMap.get_actions():
		duplicate_action(base_action, device, device_suffix)

## Return device suffix. Save it to to call actions
## e.g. Input.is_action_pressed("ui_select" + device_suffix)
static func get_device_suffix(device : int) -> String:
	return str(suffix, device)

## If this base_action has Joypad events, duplicate it and add device_suffix.
## Return true if the action is created
static func duplicate_action(base_action : String, device : int, device_suffix : String) -> bool:
	#be sure this action doesn't already exists
	var new_action = base_action + device_suffix
	var is_action_created = false
	if InputMap.has_action(new_action):
		push_error(str("Already exists an action with this name: ", new_action))
		return is_action_created

	for event in InputMap.action_get_events(base_action):
		#be sure this action has joypad input events
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			#create action
			if is_action_created == false:
				is_action_created = true
				var deadzone = InputMap.action_get_deadzone(base_action)
				InputMap.add_action(new_action, deadzone)							
			#and add every joypad event to the new one
			var new_event = event.duplicate()
			new_event.device = device			
			InputMap.action_add_event(new_action, new_event)
			
	return is_action_created
