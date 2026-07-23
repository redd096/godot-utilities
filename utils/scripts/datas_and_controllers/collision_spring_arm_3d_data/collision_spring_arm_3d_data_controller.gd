class_name CollisionSpringArm3DDataController extends Node

## If true, obj will be set to self
@export var obj_is_self: bool = true
## Set collision mask to this spring arm
@export var obj: SpringArm3D
## Find data inside Resource by Name
@export var model_data_name: StringName
## Resource used to find model data by Name
@export var data_resource: CollisionSpringArm3DDataResource

# set layer to 3 
# (-1 because the parameter is an index but in inspector start from 1)
# obj.collision_mask = 1 << (3-1)


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


func apply(model_data: CollisionSpringArm3DModelData):
	obj.collision_mask = model_data.collision_mask
