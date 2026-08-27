@tool
class_name AudioStreamPlayerPresetsDatabase 
extends BaseDataPresetsDatabase
## A collection of presets for AudioStreamPlayer, AudioStreamPlayer2D and AudioStreamPlayer3D


func get_database_type() -> StringName:
    return &"AudioStreamPlayerPresetsDatabase"


@export var presets: Array[AudioStreamPlayerPreset] = []:
    set(new_value):
        if presets != new_value:
            update_presets_signals(presets, new_value)
            presets = new_value
            emit_changed()
