class_name Rendering2DDataController extends Node

## If true, obj will be set to self
@export var obj_is_self: bool = true
## Set layer to this object
@export var obj: CanvasItem
## Find data inside Resource by Name
@export var model_data_name: StringName
## Resource used to find model data by Name
@export var data_resource: Rendering2DDataResource

# set layer to 3 
# (-1 because the parameter is an index but in inspector start from 1)
# obj.visibility_layer = 1 << (3-1)
	

func _ready() -> void:
	# set obj
	if obj_is_self:
		obj = self as Variant

	if obj == null || data_resource == null:
		push_error("Be sure to set the variables in inspector")
		return
	
	# find data by name
	var model_data := data_resource.get_model_by_name(model_data_name)
	
	# apply
	if model_data:
		apply(model_data)


func apply(model_data: Rendering2DModelData):
	obj.visibility_layer = model_data.visibility_layer
	obj.light_mask = model_data.light_mask
