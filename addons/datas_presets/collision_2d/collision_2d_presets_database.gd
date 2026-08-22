@tool
class_name Collision2DPresetsDatabase 
extends BaseDataPresetsDatabase
## A collection of presets. Create as many database resources as needed


func get_database_type() -> String:
    return "Collision2DPresetsDatabase"


@export var presets: Array[Collision2DPreset] = []
