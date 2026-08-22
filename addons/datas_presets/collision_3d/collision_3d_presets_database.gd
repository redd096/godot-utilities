@tool
class_name Collision3DPresetsDatabase 
extends BaseDataPresetsDatabase
## A collection of presets. Create as many database resources as needed


func get_database_type() -> String:
    return "Collision3DPresetsDatabase"
    

@export var presets: Array[Collision3DPreset] = []
