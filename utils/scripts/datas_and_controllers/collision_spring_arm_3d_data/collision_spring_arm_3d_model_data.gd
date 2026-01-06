extends Resource

class_name CollisionSpringArm3DModelData

## Name for this Data
@export var name : StringName = "Data"
## Used to help with editor, e.g. to know where this Data is used
@export_multiline var description: String
## Layer this object interact with
@export_flags_3d_physics var collision_mask : int = 1
