class_name UnityLike

## Equivalent of unity node.GetComponentsInChildren<script_type>
static func get_components_in_children(node: Node, script_type: Object) -> Array:
	var type := _get_string_from_script_type(script_type)
	var components: Array
	# Add node component
	if node.get_class() == type:
		components.append(node)
	# Add every child components
	components.append_array(node.find_children("*", str(type)))
	return components

## Equivalent of unity node.GetComponentInChildren<script_type>
static func get_component_in_children(node: Node, script_type: Object) -> Variant:
	var components: Array = get_components_in_children(node, script_type)
	return components[0] if components.size() > 0 else null

## Equivalent of unity FindObjectsOfType<script_type>
static func find_objects_of_type(script_type: Object) -> Array:
	var type := _get_string_from_script_type(script_type)
	var root_node: Node = Engine.get_main_loop().root
	# Get components in children but ignore root node
	return root_node.find_children("*", str(type), true, false)

## Equivalent of unity FindObjectOfType<script_type>
static func find_object_of_type(script_type: Object) -> Variant:
	var components: Array = find_objects_of_type(script_type)
	return components[0] if components.size() > 0 else null

## Equivalent of unity DontDestroyOnLoad(GameObject)
static func dont_destroy_on_load(node: Node) -> void:
	# Set root as parent (this isn't destroyed when change scene)
	var root: Node = Engine.get_main_loop().root
	set_parent(node, root)

## Equivalent of unity node.SetParent(parent)
static func set_parent(node: Node, parent: Node) -> void:
	# Check if this is already child of this parent
	var current_parent = node.get_parent()
	if current_parent and current_parent == parent:
		return
	# Else remove from current parent
	if current_parent:
		current_parent.remove_child.call_deferred(node)
	# And set child of new parent
	parent.add_child.call_deferred(node)

## Return class name or filename
static func _get_string_from_script_type(script_type: Object) -> String:
	var type: String = ""
	# Check if the argument is a Script resource
	if script_type is Script:
		# Get the class name defined by 'class_name'
		type = script_type.get_global_name()
		# If no class_name is defined, fall back to the filename
		if type.is_empty():
			type = script_type.resource_path.get_file().get_basename()
	# Otherwise, assume it's a built-in Godot class and use get_class()
	else:
		type = script_type.get_class()
	return type