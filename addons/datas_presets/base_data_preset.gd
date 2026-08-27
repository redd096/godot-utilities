@tool
@abstract
class_name BaseDataPreset 
extends Resource
## Single preset to add in database resource


## Preset name shown in the inspector
@export var name: String = "":
    set(new_value):
        if name != new_value:
            name = new_value
            emit_changed()

## Unique identifier, so renaming a preset does not break nodes that already reference it
@export_storage var id: int = ResourceUID.INVALID_ID:
    set(new_value):
        if id != new_value:
            id = new_value
            emit_changed()
#export_storage is like @export but hidden in inspector

## Optional note about what the preset is for or where it is used
@export_multiline var description: String = "":
    set(new_value):
        if description != new_value:
            description = new_value
            emit_changed()


## Apply values to node. [br]
## Return true if some variable is changed after apply
@abstract
func apply_values(node: Object) -> bool
