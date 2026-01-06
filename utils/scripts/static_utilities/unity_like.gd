class_name UnityLike

## Equivalent of unity DontDestroyOnLoad(node)
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

#region get component

## Equivalent of unity node.GetComponent<script_type>
static func get_component(node: Node, script_type: Object) -> Variant:
	if _has_component(node, script_type):
		return node
	return null

## Equivalent of unity node.GetComponentsInParent<script_type>
static func get_components_in_parent(node: Node, script_type: Object) -> Array:
	var components: Array
	# check node and parents and find every component
	var parent: Node = node
	while parent:
		if _has_component(parent, script_type):
			components.append(parent)
		parent = parent.get_parent()
	return components

## Equivalent of unity node.GetComponentInParent<script_type>
static func get_component_in_parent(node: Node, script_type: Object) -> Variant:
	# check node and parents until find component
	var parent: Node = node
	while parent:
		if _has_component(parent, script_type):
			return parent
		parent = parent.get_parent()	
	return null

## Equivalent of unity node.GetComponentsInChildren<script_type>
static func get_components_in_children(node: Node, script_type: Object) -> Array:
	var components: Array
	# add node component
	if _has_component(node, script_type):
		components.append(node)
	# add every child components
	# components.append_array(node.find_children("*", str(type)))
	_find_children_components_recursive(node, script_type, components)
	return components

## Equivalent of unity node.GetComponentInChildren<script_type>
static func get_component_in_children(node: Node, script_type: Object) -> Variant:
	# var components: Array = get_components_in_children(node, script_type)
	# return components[0] if components.size() > 0 else null
	if _has_component(node, script_type):
		return node
	return _find_first_children_component_recursive(node, script_type)

#endregion

#region find object of type

## Equivalent of unity FindObjectsOfType<script_type>
static func find_objects_of_type(script_type: Object) -> Array:
	var root_node: Node = Engine.get_main_loop().root
	# get components in children but ignore root node
	# return root_node.find_children("*", str(type), true, false)
	return _find_children_components_recursive(root_node, script_type, [])

## Equivalent of unity FindObjectOfType<script_type>
static func find_object_of_type(script_type: Object) -> Variant:
	# var components: Array = find_objects_of_type(script_type)
	# return components[0] if components.size() > 0 else null
	var root_node: Node = Engine.get_main_loop().root
	return _find_first_children_component_recursive(root_node, script_type)

#endregion

#region raycast

# https://docs.godotengine.org/en/stable/tutorials/physics/ray-casting.html

# every dicitonary contains:
# {
#    position: Vector2 # point in world space for collision
#    normal: Vector2 # normal in world space for collision
#    collider: Object # Object collided or null (if unassociated)
#    collider_id: ObjectID # Object it collided against
#    rid: RID # RID it collided against
#    shape: int # shape index of collider
#    metadata: Variant() # metadata of collider
# }

## Equivalent of unity Physics.Raycast (can use node Raycast3D)
static func raycast3D(owner: Node3D, from: Vector3, to: Vector3, collision_mask: int = 4294967295, exclude: Array[RID] = []) -> Dictionary:
	var space_state := owner.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to, collision_mask, exclude)
	return space_state.intersect_ray(query)

## Equivalent of unity Physics.Raycast (can use node Raycast3D)
static func raycast3D_with_query(owner: Node3D, query: PhysicsRayQueryParameters3D) -> Dictionary:
	var space_state := owner.get_world_3d().direct_space_state
	return space_state.intersect_ray(query)

## Equivalent of unity Physics2D.Raycast (can use node Raycast2D)
static func raycast2D(owner: Node2D, from: Vector2, to: Vector2, collision_mask: int = 4294967295, exclude: Array[RID] = []) -> Dictionary:
	var space_state := owner.get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(from, to, collision_mask, exclude)
	return space_state.intersect_ray(query)

## Equivalent of unity Physics2D.Raycast (can use node Raycast2D)
static func raycast2D_with_query(owner: Node2D, query: PhysicsRayQueryParameters2D) -> Dictionary:
	var space_state := owner.get_world_2d().direct_space_state
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

## Equivalent of unity Physics.Spherecast (can use node ShapeCast3D) - this can have different shapes
static func shapecast3D_with_query(owner: Node3D, query: PhysicsShapeQueryParameters3D) -> Array[Dictionary]:
	var space := owner.get_world_3d().direct_space_state
	return space.intersect_shape(query)

## Equivalent of unity Physics.Spherecast (can use node ShapeCast3D)
static func circlecast2D(owner: Node2D, from: Vector2, to: Vector2, radius: float, collision_mask: int = 4294967295, exclude: Array[RID] = []) -> Array[Dictionary]:
	var space := owner.get_world_2d().direct_space_state
	# create shape
	var shape = CircleShape2D.new()
	shape.radius = radius
	# create query
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0, from)
	query.motion = to
	query.collision_mask = collision_mask
	query.exclude = exclude
	return space.intersect_shape(query)

## Equivalent of unity Physics.Spherecast (can use node ShapeCast3D) - this can have different shapes
static func shapecast2D_with_query(owner: Node2D, query: PhysicsShapeQueryParameters2D) -> Array[Dictionary]:
	var space := owner.get_world_2d().direct_space_state
	return space.intersect_shape(query)

#endregion

#region private api

## Check if this node has this component or inherits
static func _has_component(node: Node, script_type: Object) -> bool:
	return is_instance_of(node, script_type)
	# if script_type is Script:
	# 	var node_script = node.get_script()
	# 	return node_script != null and _check_inherits(node_script, script_type)
	# else:
	# 	return node.is_class(script_type.get_class())

## Find children with component recursively. 
# Alternative to node.find_children("*", str(_get_string_from_script_type(script_type))), 
# that probably works only with godot classes and not with custom scripts
static func _find_children_components_recursive(node: Node, script_type: Object, result: Array) -> Array:
	for child in node.get_children():
		if _has_component(child, script_type):
			result.append(child)
		_find_children_components_recursive(child, script_type, result)
	return result

## Find first child with component recursively
static func _find_first_children_component_recursive(node: Node, script_type: Object) -> Variant:
	for child in node.get_children():
		# check child
		if _has_component(child, script_type):
			return child
		# check child childrens
		var child_component = _find_first_children_component_recursive(child, script_type)
		if child_component:
			return child_component
	return null

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

#endregion
