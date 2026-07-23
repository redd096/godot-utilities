class_name Collision3DDataController extends Node

## If true, obj will be set to self
@export var obj_is_self: bool = true
## Set layer and mask to this collision object
@export var obj: CollisionObject3D
## And/Or Set layer and mask to this csg shape
@export var csg_shape: CSGShape3D
## Find data inside Resource by Name
@export var model_data_name: StringName
## Resource used to find model data by Name
@export var data_resource: Collision3DDataResource

# set layer to 3 
# (-1 because the parameter is an index but in inspector start from 1)
# obj.collision_layer = 1 << (3-1)
	

func _ready() -> void:
	# set obj
	if obj_is_self:
		obj = self as Variant

	if (obj == null && csg_shape == null) || data_resource == null:
		push_error("Be sure to set the variables in inspector")
		return

	# find data by name
	var model_data := data_resource.get_model_by_name(model_data_name)
	
	# apply
	if model_data:
		apply(model_data)


func apply(model_data: Collision3DModelData):
	if obj:
		obj.collision_layer = model_data.collision_layer
		obj.collision_mask = model_data.collision_mask
	if csg_shape:
		csg_shape.collision_layer = model_data.collision_layer
		csg_shape.collision_mask = model_data.collision_mask
