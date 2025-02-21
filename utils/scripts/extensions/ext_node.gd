class_name ExtNode

##equivalent of unity node.GetComponentsInChildren<type>
static func get_components_in_children(node : Node, type : String) -> Array:
	var components : Array
	#add node component
	if node.get_class() == type:
		components.append(node)
	#add every child components
	components.append_array(node.find_children("*", str(type)))
	return components

##equivalent of unity node.GetComponentInChildren<type>
static func get_component_in_children(node : Node, type : String) -> Variant:
	var components : Array = get_components_in_children(node, type)
	return components[0] if components.size() > 0 else null

##equivalent of unity FindObjectsOfType<type>
static func find_objects_of_type(type : String) -> Array:
	var root_node : Node = Engine.get_main_loop().current_scene
	#get components in children but ignore root node
	return root_node.find_children("*", str(type))

##equivalent of unity FindObjectOfType<type>
static func find_object_of_type(type : String) -> Variant:
	var components : Array = find_objects_of_type(type)
	return components[0] if components.size() > 0 else null
