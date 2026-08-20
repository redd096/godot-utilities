class_name Collision3DPreset 
extends BaseDataPreset
## Single preset to add in database resource

## Collision layer
@export_flags_3d_physics var layer: int = 1

## Collision mask
@export_flags_3d_physics var mask: int = 1


func apply_values(node: Object) -> bool:
    var applied: bool

    if  &"collision_layer" in node:
        node.collision_layer = layer
        applied = true

    if &"collision_mask" in node:
        node.collision_mask = mask
        applied = true

    return applied