@tool
class_name AudioStreamPlayerPresetsDatabase 
extends BaseDataPresetsDatabase
## A collection of presets. Create as many database resources as needed


func get_database_type() -> String:
    return "AudioStreamPlayerPresetsDatabase"


@export var presets: Array[AudioStreamPlayerPreset] = []:
    set(new_value):
        if presets != new_value:
            update_presets_signals(presets, new_value)
            presets = new_value
            emit_changed()
