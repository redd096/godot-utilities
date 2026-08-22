@tool
class_name CanvasLayerPresetsDatabase 
extends BaseDataPresetsDatabase
## A collection of presets. Create as many database resources as needed


func get_database_type() -> String:
    return "CanvasLayerPresetsDatabase"


@export var presets: Array[CanvasLayerPreset] = []
