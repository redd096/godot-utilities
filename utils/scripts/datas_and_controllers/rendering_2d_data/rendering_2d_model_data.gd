extends Resource

class_name Rendering2DModelData

## Name for this Data
@export var name : StringName = "Data"
## Used to help with editor, e.g. to know where this Data is used
@export_multiline var description: String
## Layer this object is in
@export_flags_2d_render var visibility_layer : int = 1
## layer this object is affected by Light2D
@export_flags_2d_render var light_mask : int = 1
