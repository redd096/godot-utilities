@tool
@abstract
class_name BaseDataPreset 
extends Resource
## Single preset to add in database resource


## Preset name shown in the inspector
@export var name: String = ""

## Unique identifier, so renaming a preset does not break nodes that already reference it
@export_storage var id: String = ""
#export_storage is like @export but hidden in inspector

## Optional note about what the preset is for or where it is used
@export_multiline var description: String = ""


## Apply values to node. [br]
## Return true if some variable is changed after apply
@abstract
func apply_values(node: Object) -> bool
