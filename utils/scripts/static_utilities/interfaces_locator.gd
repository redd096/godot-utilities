class_name InterfacesLocator

# key: node that implement interfaces
# value: Dictionary[Object, Variant]
# 	where key: script_type, value: result
static var _interfaces: Dictionary#[Object, Dictionary] # for now untyped to avoid godot error when erase freed node

# avoid too much memory
const MAX_COUNT: int = 100
static var _nodes: Array[Object]


## Add interface to node. Look for it in children
static func implement_interface(node: Object, script_type: Object) -> void:
	var found: Variant = _get_component_in_children(node, script_type) if node is Node else null
	implement_specific_interface(node, script_type, found)


## Add specific interface to node
static func implement_specific_interface(node: Object, script_type: Object, interface: Variant) -> void:
	if not _interfaces.has(node):
		_create_new_dictionary(node)
	_interfaces[node][script_type] = interface


## Return the required interface, to use its functions. [br]
## If not in dictionary, try to find it in children. [br]
## If there isn't, return null
static func get_interface(node: Object, script_type: Object) -> Variant:
	if not _interfaces.has(node):
		implement_interface(node, script_type)
	return _interfaces[node].get(script_type)


static func _create_new_dictionary(node: Object) -> void:
	# create dictionary
	_interfaces[node] = {}

	# remove oldest from dictionary and array to avoid too much memory
	# (array is necessary only to know who is the oldest)
	_nodes.append(node)
	if _nodes.size() > MAX_COUNT:
		_interfaces.erase(_nodes.pop_front())



#region copy-paste from unity_like


## Equivalent of unity node.GetComponentInChildren<script_type>
static func _get_component_in_children(node: Node, script_type: Object) -> Variant:
	if is_instance_of(node, script_type):
		return node
	return _find_first_children_component_recursive(node, script_type)


## Find first child with component recursively
static func _find_first_children_component_recursive(node: Node, script_type: Object) -> Variant:
	for child in node.get_children():
		# check child
		if is_instance_of(child, script_type):
			return child
		# check child childrens
		var child_component = _find_first_children_component_recursive(child, script_type)
		if child_component:
			return child_component
	return null


#endregion
