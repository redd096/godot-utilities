extends Resource

class_name Rendering2DModelData

## Name for this Data
@export var name : StringName = "Data"
## Layer this object is in
@export_flags_2d_render var visibility_layer : int = 1
## layer this object is affected by Light2D
@export_flags_2d_render var light_mask : int = 1
