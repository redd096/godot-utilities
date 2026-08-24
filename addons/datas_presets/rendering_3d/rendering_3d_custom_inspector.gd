@tool
class_name Rendering3DCustomInspector
extends BaseDataCustomInspector
## This add custom inspector (editor ui)


static func get_script_path() -> String:
	return (Rendering3DCustomInspector as Script).resource_path


func _is_supported_type(object: Object) -> bool:
	return object is VisualInstance3D

# func _is_correct_category(category: String) -> bool:
# 	return category == "VisualInstance3D"

func _get_property() -> String:
	return "layers"

func _get_ui_script_path() -> String:
	return (Rendering3DUI as Script).resource_path
