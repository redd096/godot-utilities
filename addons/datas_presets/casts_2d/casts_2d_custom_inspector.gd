@tool
class_name Casts2DCustomInspector
extends BaseDataCustomInspector
## This add custom inspector (editor ui)


static func get_script_path() -> String:
	return (Casts2DCustomInspector as Script).resource_path


func _is_supported_type(object: Object) -> bool:
	return object is RayCast2D or object is ShapeCast2D

# func _is_correct_category(category: String) -> bool:
# 	return category == "RayCast2D" or category == "ShapeCast2D"

func _get_property() -> String:
	return "collision_mask"

func _get_ui_script_path() -> String:
	return (Casts2DUI as Script).resource_path
