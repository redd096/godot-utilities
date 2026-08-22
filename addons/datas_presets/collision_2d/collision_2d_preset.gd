@tool
class_name Collision2DPreset 
extends BaseDataPreset
## Single preset to add in database resource

## Collision layer
@export_flags_2d_physics var collision_layer: int = 1

## Collision mask
@export_flags_2d_physics var collision_mask: int = 1


func apply_values(node: Object) -> bool:
    var applied: bool

    if  &"collision_layer" in node:
        node.collision_layer = collision_layer
        applied = true

    if &"collision_mask" in node:
        node.collision_mask = collision_mask
        applied = true

    return applied
