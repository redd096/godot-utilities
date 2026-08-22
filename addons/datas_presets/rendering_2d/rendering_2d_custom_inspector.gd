@tool
class_name Rendering2DCustomInspector
extends BaseDataCustomInspector
## This add custom inspector (editor ui)


static func get_script_path() -> String:
	return (Rendering2DCustomInspector as Script).resource_path


func _is_supported_type(object: Object) -> bool:
	return object is CanvasItem

# func _get_category() -> String:
# 	return "CanvasItem"

func _get_property() -> String:
	return "light_mask"

func _get_ui_script_path() -> String:
	return (Rendering2DUI as Script).resource_path
