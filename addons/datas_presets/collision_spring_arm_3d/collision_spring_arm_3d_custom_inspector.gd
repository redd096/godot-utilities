@tool
class_name CollisionSpringArm3DCustomInspector
extends BaseDataCustomInspector
## This add custom inspector (editor ui)


static func get_script_path() -> String:
	return (CollisionSpringArm3DCustomInspector as Script).resource_path


func _is_supported_type(object: Object) -> bool:
	return object is SpringArm3D

# func _is_correct_category(category: String) -> bool:
# 	return category == "SpringArm3D"

func _get_property() -> String:
	return "collision_mask"

func _get_ui_script_path() -> String:
	return (CollisionSpringArm3DUI as Script).resource_path
