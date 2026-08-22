@tool
class_name CanvasLayerPreset 
extends BaseDataPreset
## Single preset to add in database resource

## Canvas layer
@export var layer: int = 1


func apply_values(node: Object) -> bool:
    var applied: bool

    if  &"layer" in node:
        node.layer = layer
        applied = true

    return applied
