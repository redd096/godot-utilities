@tool
class_name ThemeVariationPresetsDatabase 
extends BaseDataPresetsDatabase
## A collection of presets for Control


func get_database_type() -> StringName:
    return &"ThemeVariationPresetsDatabase"


@export var presets: Array[ThemeVariationPreset] = []:
    set(new_value):
        if presets != new_value:
            update_presets_signals(presets, new_value)
            presets = new_value
            emit_changed()
