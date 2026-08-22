@tool
class_name CanvasLayerPresetsDatabase 
extends BaseDataPresetsDatabase
## A collection of presets. Create as many database resources as needed


func get_database_type() -> String:
    return "CanvasLayerPresetsDatabase"


@export var presets: Array[CanvasLayerPreset] = []:
    set(new_value):
        if presets != new_value:
            update_presets_signals(presets, new_value)
            presets = new_value
            emit_changed()
