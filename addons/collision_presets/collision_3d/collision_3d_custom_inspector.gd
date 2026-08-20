@tool
class_name Collision3DCustomInspector
extends EditorInspectorPlugin
## This add custom inspector (editor ui)


func _can_handle(object: Object) -> bool:
	# these are the nodes that can be used by this plugin
	return object is CollisionObject3D or object is CSGShape3D


func _parse_category(object: Object, category: String) -> void:
	# for CSGShape don't add editor ui in category. Will be added in property
	if object is CSGShape3D:
		return

	# add editor ui in inspector, in Collision category
	var lower := category.to_lower()
	if lower != "collisionobject3d":
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
	# for CSGShape3D, add editor ui in inspector, 
	# between use_collision and collision_layer properties
	if object is CSGShape3D and name == "collision_layer":
		_add_preset_editor(object)

	return false


func _add_preset_editor(object: Object) -> void:
	# instantiate editor ui
	var ui_script: Script = load(DataPresetsConstants.COLLISION_3D_UI_PATH)
	var ui: Collision3DUI = ui_script.new()

	# initialize and add to inspector
	ui.set_target(object as Node)
	add_custom_control(ui)
