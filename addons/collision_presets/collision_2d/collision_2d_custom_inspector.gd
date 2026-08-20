@tool
class_name Collision2DCustomInspector
extends BaseDataCustomInspector
## This add custom inspector (editor ui)


func _is_supported_type(object: Object) -> bool:
	return object is CollisionObject2D

func _get_category() -> String:
	return "collisionobject2d"

func _get_ui_script_path() -> String:
	return DataPresetsConstants.COLLISION_2D_UI_PATH