extends Resource

class_name Collision2DModelData

## Name for this Data
@export var name : StringName = "Data"
## Layer this object is in
@export_flags_2d_physics var collision_layer : int = 1
## Layer this object interact with
@export_flags_2d_physics var collision_mask : int = 1
