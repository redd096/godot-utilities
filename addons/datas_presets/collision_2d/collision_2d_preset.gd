@tool
class_name Collision2DPreset 
extends BaseDataPreset
## Single preset to add in database resource. Use this for CollisionObject2D

## See [member CollisionObject2D.collision_layer]
@export_flags_2d_physics var collision_layer: int = 1:
    set(new_value):
        if collision_layer != new_value:
            collision_layer = new_value
            emit_changed()

## See [member CollisionObject2D.collision_mask]
@export_flags_2d_physics var collision_mask: int = 1:
    set(new_value):
        if collision_mask != new_value:
            collision_mask = new_value
            emit_changed()


func apply_values(node: Object) -> bool:
    var applied: bool

    if  &"collision_layer" in node:
        node.collision_layer = collision_layer
        applied = true

    if &"collision_mask" in node:
        node.collision_mask = collision_mask
        applied = true

    return applied
