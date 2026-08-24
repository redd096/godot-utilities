@tool
class_name AudioStreamPlayerCustomInspector
extends BaseDataCustomInspector
## This add custom inspector (editor ui)


static func get_script_path() -> String:
	return (AudioStreamPlayerCustomInspector as Script).resource_path


func _is_supported_type(object: Object) -> bool:
	return object is AudioStreamPlayer or object is AudioStreamPlayer2D or object is AudioStreamPlayer3D

# func _is_correct_category(category: String) -> bool:
# 	return category.contains("AudioStreamPlayer")

func _get_property() -> String:
	return "stream"

func _get_ui_script_path() -> String:
	return (AudioStreamPlayerUI as Script).resource_path
