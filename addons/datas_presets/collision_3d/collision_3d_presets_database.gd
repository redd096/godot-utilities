@tool
class_name Collision3DPresetsDatabase 
extends BaseDataPresetsDatabase
## A collection of presets for CollisionObject3D and CSGShape3D


func get_database_type() -> StringName:
    return &"Collision3DPresetsDatabase"
    

@export var presets: Array[Collision3DPreset] = []:
    set(new_value):
        if presets != new_value:
            update_presets_signals(presets, new_value)
            presets = new_value
            emit_changed()
