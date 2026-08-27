@tool
@abstract
class_name BaseDataPresetsDatabase 
extends Resource
## A collection of presets. Create as many database resources as needed


@abstract
func get_database_type() -> StringName


# @export var presets: Array[BaseDataPreset] = []:
#     set(new_value):
#         if presets != new_value:
#             update_presets_signals(presets, new_value)
#             presets = new_value
#             emit_changed()


func update_presets_signals(old_value: Array, new_value: Array):
    # unregister from previous presets
    for preset in old_value:
        if preset and preset.changed.is_connected(emit_changed):
            preset.changed.disconnect(emit_changed)
    
    # register new presets, so if any preset is modified in inspector, this database will emit "changed" event
    for preset in new_value:
        if preset and not preset.changed.is_connected(emit_changed):
            preset.changed.connect(emit_changed)
