@tool
class_name Rendering3DPreset 
extends BaseDataPreset
## Single preset to add in database resource

## Rendering layer
@export_flags_3d_render var layers: int = 1


func apply_values(node: Object) -> bool:
    var applied: bool

    if  &"layers" in node:
        node.layers = layers
        applied = true

    return applied
