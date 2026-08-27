@tool
class_name CanvasLayerUI
extends BaseDataUI
## Inspector UI instantiated from custom inspector


func _get_database_type() -> StringName:
	return &"CanvasLayerPresetsDatabase"
