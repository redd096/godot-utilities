@tool
class_name Collision3DCustomInspector
extends BaseDataCustomInspector
## This add custom inspector (editor ui)


static func get_script_path() -> String:
	return (Collision3DCustomInspector as Script).resource_path


func _is_supported_type(object: Object) -> bool:
	return object is CollisionObject3D or object is CSGShape3D

func _get_category() -> String:
	return "collisionobject3d"

func _get_ui_script_path() -> String:
	return (Collision3DUI as Script).resource_path


func _parse_category(object: Object, category: String) -> void:
	# for CSGShape don't add editor ui in category. Will be added in property
	if object is CSGShape3D:
		return

	super._parse_category(object, category)


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
