@tool
class_name CollisionSpringArm3DPresetsDatabase 
extends BaseDataPresetsDatabase
## A collection of presets for SpringArm3D


func get_database_type() -> StringName:
    return &"CollisionSpringArm3DPresetsDatabase"
    

@export var presets: Array[CollisionSpringArm3DPreset] = []:
    set(new_value):
        if presets != new_value:
            update_presets_signals(presets, new_value)
            presets = new_value
            emit_changed()
