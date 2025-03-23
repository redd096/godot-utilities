class_name UnityLike

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
	#check if this is already child of root node
	var parent : Node = node.get_parent()
	var root : Node = Engine.get_main_loop().root
	if parent and parent == root:
		return
	#else remove from current parent
	if parent:
		parent.remove_child.call_deferred(node)
	#and set child of root node (this isn't destroyed when change scene)
	root.add_child.call_deferred(node)
