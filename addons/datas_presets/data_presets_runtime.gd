extends Node
## Autoload - Applies presets at runtime to supported nodes


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
	# if DataPresetsAPI.can_handle_this_object(node): # not necessary, because if not handled can't have metas set
	DataPresetsAPI.apply_node_preset(node)

	# and every child
	for child: Node in node.get_children():
		_apply_preset_recursively(child)
