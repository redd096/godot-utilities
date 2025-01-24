extends Node

class_name Collision3DDataController

## Set layer and mask to this collision object
@export var collision_object : CollisionObject3D
## Set layer and mask to this csg shape
@export var csg_shape : CSGShape3D
## Find data inside Resource by Name
@export var collision_name : StringName
## Find data inside a Resource in your project by Name
@export var collision_data : Collision3DDataResource
	
func _ready() -> void:	
	#set layer to 3 
	#(-1 because the parameter is an index but in inspector start from 1)
	#collision_object.collision_layer = 1 << (3-1)

	if (collision_object == null && csg_shape == null) || collision_data == null:
		push_error("Be sure to set the variables in inspector")
		return

	#find data by name
	for model_data in collision_data.data:
		if model_data.name == collision_name:
			#set collision and mask
			set_collision(collision_object, model_data)
			set_collision(csg_shape, model_data)
			return

	push_error("Impossible to find this name in the list: " + collision_name)

## Set collision layer and mask for this collider
func set_collision(collider, model_data : Collision3DModelData):
	if collider:
		collider.collision_layer = model_data.collision_layer
		collider.collision_mask = model_data.collision_mask
