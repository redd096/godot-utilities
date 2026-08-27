@tool
class_name Rendering2DUI
extends BaseDataUI
## Inspector UI instantiated from custom inspector


func _get_database_type() -> StringName:
	return &"Rendering2DPresetsDatabase"
