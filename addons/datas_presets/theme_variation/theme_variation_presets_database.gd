@tool
class_name ThemeVariationPresetsDatabase 
extends BaseDataPresetsDatabase
## A collection of presets. Create as many database resources as needed


func get_database_type() -> String:
    return "ThemeVariationPresetsDatabase"


@export var presets: Array[ThemeVariationPreset] = []
