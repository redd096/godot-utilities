@tool
class_name CanvasLayerPreset 
extends BaseDataPreset
## Single preset to add in database resource

## Canvas layer
@export var layer: int = 1:
    set(new_value):
        if layer != new_value:
            layer = new_value
            emit_changed()


func apply_values(node: Object) -> bool:
    var applied: bool

    if  &"layer" in node:
        node.layer = layer
        applied = true

    return applied
