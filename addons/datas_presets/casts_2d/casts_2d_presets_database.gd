@tool
class_name Casts2DPresetsDatabase 
extends BaseDataPresetsDatabase
## A collection of presets for RayCast2D, ShapeCast2D


func get_database_type() -> StringName:
    return &"Casts2DPresetsDatabase"
    

@export var presets: Array[Casts2DPreset] = []:
    set(new_value):
        if presets != new_value:
            update_presets_signals(presets, new_value)
            presets = new_value
            emit_changed()
