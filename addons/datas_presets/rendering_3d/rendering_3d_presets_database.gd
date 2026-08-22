@tool
class_name Rendering3DPresetsDatabase 
extends BaseDataPresetsDatabase
## A collection of presets. Create as many database resources as needed


func get_database_type() -> String:
    return "Rendering3DPresetsDatabase"


@export var presets: Array[Rendering3DPreset] = []
