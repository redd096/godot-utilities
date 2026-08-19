@tool
class_name CollisionPresetsInspector
extends EditorInspectorPlugin
## This add preset ui (presets editor) in inspector


func _can_handle(object: Object) -> bool:
	# these are the nodes that can be used by this plugin
	return object is CollisionObject3D or object is CollisionObject2D or object is CSGShape3D


func _parse_category(object: Object, category: String) -> void:
	if object is CSGShape3D:
		return

	# for CollisionObject3D and CollisionObject2D, add preset in inspector, 
	# in Collision category
	var lower := category.to_lower()
	if lower != "collisionobject3d" and lower != "collisionobject2d":
		return

	_add_preset_editor(object)


func _parse_property(
	object: Object,
	type: Variant.Type,
	name: String,
	hint_type: PropertyHint,
	hint_string: String,
	usage_flags: int,
	wide: bool
) -> bool:
	# for CSGShape3D, add preset in inspector, 
	# between use_collision and collision_layer properties
	if object is CSGShape3D and name == "collision_layer":
		_add_preset_editor(object)

	return false


func _add_preset_editor(object: Object) -> void:
	# instantiate preset editor
	var ui_script: Script = load(CollisionPresetsConstants.EDITOR_SCRIPT_PATH)
	var ui: CollisionPresetsEditor = ui_script.new()

	# and add to inspector
	ui.set_target(object as Node)
	add_custom_control(ui)
