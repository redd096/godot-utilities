extends Node

class_name CollisionSpringArm3DDataController

## Set collision mask to this spring arm
@export var spring_arm : SpringArm3D
## Find data inside Resource by Name
@export var collision_name : StringName
## Find data inside a Resource in your project by Name
@export var collision_data : CollisionSpringArm3DDataResource
	
func _ready() -> void:	
	#set layer to 3 
	#(-1 because the parameter is an index but in inspector start from 1)
	#spring_arm.collision_mask = 1 << (3-1)

	if spring_arm == null || collision_data == null:
		push_error("Be sure to set the variables in inspector")
		return

	#find data by name
	for model_data in collision_data.data:
		if model_data.name == collision_name:
			#set collision mask
			set_collision(spring_arm, model_data)
			return

	push_error("Impossible to find this name in the list: " + collision_name)

## Set collision mask for this object
func set_collision(obj : SpringArm3D, model_data : CollisionSpringArm3DModelData):
	if obj:
		obj.collision_mask = model_data.collision_mask
