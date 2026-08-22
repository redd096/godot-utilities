@tool
class_name ThemeVariationCustomInspector
extends BaseDataCustomInspector
## This add custom inspector (editor ui)


static func get_script_path() -> String:
	return (ThemeVariationCustomInspector as Script).resource_path


func _is_supported_type(object: Object) -> bool:
	return object is Control

# func _get_category() -> String:
# 	return "Control"

func _get_property() -> String:
	return "theme"

func _get_ui_script_path() -> String:
	return (ThemeVariationUI as Script).resource_path
