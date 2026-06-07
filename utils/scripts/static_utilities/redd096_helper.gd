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
