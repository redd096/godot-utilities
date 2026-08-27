@tool
class_name Casts2DPreset 
extends BaseDataPreset
## Single preset to add in database resource. Use this for Raycast2D and ShapeCast2D

## See [member Raycast2D.collision_mask], [member ShapeCast2D.collision_mask]
@export_flags_2d_physics var collision_mask: int = 1:
    set(new_value):
        if collision_mask != new_value:
            collision_mask = new_value
            emit_changed()


func apply_values(node: Object) -> bool:
    var applied: bool

    if &"collision_mask" in node:
        node.collision_mask = collision_mask
        applied = true

    return applied