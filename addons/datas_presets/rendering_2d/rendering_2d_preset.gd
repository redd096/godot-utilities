@tool
class_name Rendering2DPreset 
extends BaseDataPreset
## Single preset to add in database resource

## Layer this object is affected by Light2D
@export_flags_2d_render var light_mask: int = 1:
    set(new_value):
        if light_mask != new_value:
            light_mask = new_value
            emit_changed()

## Rendering layer
@export_flags_2d_render var visibility_layer: int = 1:
    set(new_value):
        if visibility_layer != new_value:
            visibility_layer = new_value
            emit_changed()


func apply_values(node: Object) -> bool:
    var applied: bool
    
    if &"light_mask" in node:
        node.light_mask = light_mask
        applied = true

    if  &"visibility_layer" in node:
        node.visibility_layer = visibility_layer
        applied = true

    return applied
