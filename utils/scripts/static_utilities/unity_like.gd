class_name UnityLike

## Equivalent of unity node.GetComponentsInChildren<script_type>
static func get_components_in_children(node: Node, script_type: Object) -> Array:
	var type := _get_string_from_script_type(script_type)
	var components: Array
	# add node component
	if node.get_class() == type:
		components.append(node)
	# add every child components
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
	# get components in children but ignore root node
	return root_node.find_children("*", str(type), true, false)

## Equivalent of unity FindObjectOfType<script_type>
static func find_object_of_type(script_type: Object) -> Variant:
	var components: Array = find_objects_of_type(script_type)
	return components[0] if components.size() > 0 else null

## Equivalent of unity DontDestroyOnLoad(GameObject)
static func dont_destroy_on_load(node: Node) -> void:
	# set root as parent (this isn't destroyed when change scene)
	var root: Node = Engine.get_main_loop().root
	set_parent(node, root)

## Equivalent of unity node.SetParent(parent)
static func set_parent(node: Node, parent: Node) -> void:
	# check if this is already child of this parent
	var current_parent = node.get_parent()
	if current_parent and current_parent == parent:
		return
	# else remove from current parent
	if current_parent:
		current_parent.remove_child.call_deferred(node)
	# and set child of new parent
	parent.add_child.call_deferred(node)

## Equivalent of unity Physics.Raycast (can use node Raycast3D)
static func raycast3D(owner: Node3D, from: Vector3, to: Vector3, collision_mask: int = 4294967295, exclude: Array[RID] = []) -> Dictionary:
	var space_state := owner.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to, collision_mask, exclude)
	return space_state.intersect_ray(query)

## Equivalent of unity Physics2D.Raycast (can use node Raycast2D)
static func raycast2D(owner: Node2D, from: Vector2, to: Vector2, collision_mask: int = 4294967295, exclude: Array[RID] = []) -> Dictionary:
	var space_state := owner.get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(from, to, collision_mask, exclude)
	return space_state.intersect_ray(query)

## Equivalent of unity Physics.Spherecast (can use node ShapeCast3D)
static func spherecast3D(owner: Node3D, from: Vector3, to: Vector3, radius: float, collision_mask: int = 4294967295, exclude: Array[RID] = []) -> Array[Dictionary]:
	var space := owner.get_world_3d().direct_space_state
	# create shape
	var shape = SphereShape3D.new()
	shape.radius = radius
	# create query
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(Basis(), from)
	query.motion = to
	query.collision_mask = collision_mask
	query.exclude = exclude
	return space.intersect_shape(query)

## Return class name or filename
static func _get_string_from_script_type(script_type: Object) -> String:
	var type: String = ""
	# check if the argument is a Script resource
	if script_type is Script:
		# get the class name defined by 'class_name'
		type = script_type.get_global_name()
		# if no class_name is defined, fall back to the filename
		if type.is_empty():
			type = script_type.resource_path.get_file().get_basename()
	# otherwise, assume it's a built-in Godot class and use get_class()
	else:
		type = script_type.get_class()
	return type