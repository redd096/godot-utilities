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
