class_name ExtNode

## Equivalent of unity node.GetComponentsInChildren<type>
static func get_components_in_children(node : Node, type : String) -> Array:
	var components : Array
	#add node component
	if node.get_class() == type:
		components.append(node)
	#add every child components
	components.append_array(node.find_children("*", str(type)))
	return components

## Equivalent of unity node.GetComponentInChildren<type>
static func get_component_in_children(node : Node, type : String) -> Variant:
	var components : Array = get_components_in_children(node, type)
	return components[0] if components.size() > 0 else null

## Equivalent of unity FindObjectsOfType<type>
static func find_objects_of_type(type : String) -> Array:
	var root_node : Node = Engine.get_main_loop().current_scene
	#get components in children but ignore root node
	return root_node.find_children("*", str(type))

## Equivalent of unity FindObjectOfType<type>
static func find_object_of_type(type : String) -> Variant:
	var components : Array = find_objects_of_type(type)
	return components[0] if components.size() > 0 else null

## Equivalent of unity DontDestroyOnLoad(GameObject)
static func dont_destroy_on_load(node : Node) -> void:
	#remove from current parent
	if node.get_parent():
		node.get_parent().remove_child.call_deferred(node)
	#set child of Root node (this isn't destroyed when change scene)
	Engine.get_main_loop().root.add_child().call_deferred(node)
