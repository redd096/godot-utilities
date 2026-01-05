extends Node

class_name Rendering3DDataController

## Set layer to this object
@export var rendering_object : VisualInstance3D
## Find data inside Resource by Name
@export var rendering_name : StringName
## Find data inside a Resource in your project by Name
@export var rendering_data : Rendering3DDataResource
	
func _ready() -> void:
	# set layer to 3 
	# (-1 because the parameter is an index but in inspector start from 1)
	# rendering_object.layers = 1 << (3-1)

	if rendering_object == null || rendering_data == null:
		push_error("Be sure to set the variables in inspector")
		return
	
	# find data by name
	var model_data := rendering_data.get_model_by_name(rendering_name)
	# set layer
	if model_data:
		set_rendering(rendering_object, model_data)

## Set layer for this object
func set_rendering(obj : VisualInstance3D, model_data : Rendering3DModelData):
	if obj:
		obj.layers = model_data.rendering_layer
