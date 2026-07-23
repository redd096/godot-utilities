class_name ControlThemeDataResource extends Resource

## List of model data
@export var data: Array[ControlThemeModelData]

## Find model in the list by name
func get_model_by_name(name: StringName) -> ControlThemeModelData:
	for model_data in data:
		if model_data.name == name:
			return model_data
	push_error("Impossible to find this name in the list: " + name)
	return null
