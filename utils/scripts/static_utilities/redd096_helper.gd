class_name Redd096Helper

## Create a parent for this node. 
## e.g. create Camera parent to do CameraShake on it and avoid conflict with camera movements
static func create_parent(node: Node3D) -> Node:
	var new_parent: Node3D = Node3D.new()
	var old_parent: Node3D = node.get_parent()
	# add new parent as child of old parent, and remove node from old parent
	if old_parent:
		old_parent.add_child.call_deferred(new_parent)
		old_parent.remove_child.call_deferred(node)
	# add node as child of new parent
	new_parent.add_child.call_deferred(node)
	return new_parent


## How I manage menus in pause, like pause menu or shops that stop game
static func pause_for_ui(ui_node: Control) -> void:
	# make ui works also when paused
	ui_node.process_mode = Node.PROCESS_MODE_ALWAYS
	# pause game
	ui_node.get_tree().paused = true
	# Engine.time_scale = 0
	# show mouse
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# and select first item in ui
	try_focus(ui_node)


## How I resume menus after pause_for_ui
static func resume_for_ui(ui_node: Node) -> void:
	# reset process mode
	ui_node.process_mode = Node.PROCESS_MODE_INHERIT
	# resume game
	ui_node.get_tree().paused = false
	# Engine.time_scale = 1
	# hide mouse
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


## Try focus on this node, or first focusable child
static func try_focus(control: Control) -> bool:
	# if can't receive focus
	if control.focus_mode == Control.FOCUS_NONE:
		# try find next valid focus
		var next: Control = control.find_next_valid_focus()
		# and be sure is still child of this object
		if next and check_is_child_recursive(control, next):
			next.grab_focus()
			return true

		# if can't find next valid focus, return false
		return false
	
	# else, can focus this
	control.grab_focus()
	return true


## Check if node_to_find is child of node_parent (or child of children, recursively)
static func check_is_child_recursive(node_parent: Node, node_to_find: Node) -> bool:
	# try find in childrens
	for child in node_parent.get_children():
		if child == node_to_find:
			return true
		# else, check recursive in every children of children
		if check_is_child_recursive(child, node_to_find):
			return true
	return false