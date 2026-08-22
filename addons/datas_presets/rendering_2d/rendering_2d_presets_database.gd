@tool
class_name Rendering2DPresetsDatabase 
extends BaseDataPresetsDatabase
## A collection of presets. Create as many database resources as needed


func get_database_type() -> String:
    return "Rendering2DPresetsDatabase"


@export var presets: Array[Rendering2DPreset] = []
