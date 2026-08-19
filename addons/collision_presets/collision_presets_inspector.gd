@tool
class_name CollisionPresetsInspector
extends EditorInspectorPlugin


func _can_handle(object: Object) -> bool:
	return object is CollisionObject3D or object is CollisionObject2D or object is CSGShape3D


func _parse_category(object: Object, category: String) -> void:
	# CollisionObject2D/3D keep the preset controls at the beginning of their
	# collision category. CSGShape3D is handled in _parse_property() so its
	# controls can sit directly below "Use Collision".
	if object is CSGShape3D:
		return

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
	# Godot parses collision_layer immediately after use_collision for CSGShape3D.
	# Adding the control while collision_layer is being parsed places it between
	# "Use Collision" and "Collision Layer".
	if object is CSGShape3D and name == "collision_layer":
		_add_preset_editor(object)

	return false


func _add_preset_editor(object: Object) -> void:
	var ui_script: Script = load(
		get_script().resource_path.get_base_dir().path_join("collision_presets_editor.gd")
	)
	var ui: CollisionPresetsEditor = ui_script.new()
	ui.set_target(object as Node)
	add_custom_control(ui)
