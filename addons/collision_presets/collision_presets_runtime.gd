extends Node
## Applies linked collision presets at runtime so resource edits remain authoritative.


func _ready() -> void:
	var root := get_tree().root
	if root != null:
		_process_branch(root)

	get_tree().node_added.connect(_on_node_added)


func _on_node_added(node: Node) -> void:
	if node is CollisionObject3D or node is CollisionObject2D or node is CSGShape3D:
		CollisionPresetsAPI.apply_node_preset(node)


func _process_branch(node: Node) -> void:
	if node is CollisionObject3D or node is CollisionObject2D or node is CSGShape3D:
		CollisionPresetsAPI.apply_node_preset(node)

	for child: Node in node.get_children():
		_process_branch(child)
