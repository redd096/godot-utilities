@tool
class_name Rendering3DPreset 
extends BaseDataPreset
## Single preset to add in database resource. Use this for VisualInstance3D

## See [member VisualInstance3D.layers]
@export_flags_3d_render var layers: int = 1:
    set(new_value):
        if layers != new_value:
            layers = new_value
            emit_changed()


func apply_values(node: Object) -> bool:
    var applied: bool

    if  &"layers" in node:
        node.layers = layers
        applied = true

    return applied
