@tool
class_name CanvasLayerCustomInspector
extends BaseDataCustomInspector
## This add custom inspector (editor ui)


static func get_script_path() -> String:
	return (CanvasLayerCustomInspector as Script).resource_path


func _is_supported_type(object: Object) -> bool:
	return object is CanvasLayer

# func _is_correct_category(category: String) -> bool:
# 	return category == "CanvasLayer"

func _get_property() -> String:
	return "layer"

func _get_ui_script_path() -> String:
	return (CanvasLayerUI as Script).resource_path
