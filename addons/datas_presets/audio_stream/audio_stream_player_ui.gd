@tool
class_name AudioStreamPlayerUI
extends BaseDataUI
## Inspector UI instantiated from custom inspector


func _get_database_type() -> StringName:
	return &"AudioStreamPlayerPresetsDatabase"
