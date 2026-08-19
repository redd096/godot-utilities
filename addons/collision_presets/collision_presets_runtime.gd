class_name CollisionPresetsRuntime
extends Node
## Applies collision presets at runtime to every CollisionObject3D, CSGShape and CollisionObject2D


func _ready() -> void:
	# from root, check every child to apply presets
	var root := get_tree().root
	if root != null:
		_apply_preset_recursively(root)

	# register to event when a new node is added to the tree
	get_tree().node_added.connect(_on_node_added)


func _on_node_added(node: Node) -> void:
	# when a new node is added to the tree, apply presets to it and its childs
	_apply_preset_recursively(node)


func _apply_preset_recursively(node: Node) -> void:
	# apply preset to node
	if node is CollisionObject3D or node is CSGShape3D or node is CollisionObject2D:
		CollisionPresetsAPI.apply_node_preset(node)

	# and every child
	for child: Node in node.get_children():
		_apply_preset_recursively(child)
