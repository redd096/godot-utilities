extends Resource

class_name CollisionSpringArm3DDataResource

## List of model data
@export var data : Array[CollisionSpringArm3DModelData]

## Find model in the list by name
func get_model_by_name(name : StringName) -> CollisionSpringArm3DModelData:
	for model_data in data:
		if model_data.name == name:
			return model_data
	push_error("Impossible to find this name in the list: " + name)
	return null