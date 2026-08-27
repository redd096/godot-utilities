@tool
class_name Casts3DAndSpringArmPresetsDatabase 
extends BaseDataPresetsDatabase
## A collection of presets for RayCast3D, ShapeCast3D and SpringArm3D


func get_database_type() -> StringName:
    return &"Casts3DAndSpringArmPresetsDatabase"
    

@export var presets: Array[Casts3DAndSpringArmPreset] = []:
    set(new_value):
        if presets != new_value:
            update_presets_signals(presets, new_value)
            presets = new_value
            emit_changed()
