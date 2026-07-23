class_name ControlThemeDataController extends Node

## If true, obj will be set to self
@export var obj_is_self: bool = true
## Set theme to this object
@export var obj: Control
## Find data inside Resource by Name
@export var model_data_name: StringName
## Resource used to find model data by Name
@export var data_resource: ControlThemeDataResource
	
	
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


func apply(model_data: ControlThemeModelData):
	obj.theme = model_data.theme
	obj.theme_type_variation = model_data.theme_type_variation
