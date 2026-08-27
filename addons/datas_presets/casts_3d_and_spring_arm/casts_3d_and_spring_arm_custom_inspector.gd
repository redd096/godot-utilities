@tool
class_name Casts3DAndSpringArmCustomInspector
extends BaseDataCustomInspector
## This add custom inspector (editor ui)


static func get_script_path() -> String:
	return (Casts3DAndSpringArmCustomInspector as Script).resource_path


func _is_supported_type(object: Object) -> bool:
	return object is RayCast3D or object is ShapeCast3D or object is SpringArm3D

# func _is_correct_category(category: String) -> bool:
# 	return category == "RayCast3D" or category == "ShapeCast3D" or category == "SpringArm3D" 

func _get_property() -> String:
	return "collision_mask"

func _get_ui_script_path() -> String:
	return (Casts3DAndSpringArmUI as Script).resource_path
