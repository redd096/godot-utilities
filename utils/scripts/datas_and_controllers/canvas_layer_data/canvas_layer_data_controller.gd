extends Node

class_name CanvasLayerDataController

## Set layer to this object
@export var canvas_layer : CanvasLayer
## Find data inside Resource by Name
@export var rendering_name : StringName
## Find data inside a Resource in your project by Name
@export var rendering_data : CanvasLayerDataResource
	
func _ready() -> void:
	# set layer to 3 
	# (-1 because the parameter is an index but in inspector start from 1)
	# canvas_layer.layer = 1 << (3-1)

	if canvas_layer == null || rendering_data == null:
		push_error("Be sure to set the variables in inspector")
		return

	# find data by name
	var model_data := rendering_data.get_model_by_name(rendering_name)
	#set layer
	if model_data:
		set_rendering(canvas_layer, model_data)

## Set layer for this object
func set_rendering(obj : CanvasLayer, model_data : CanvasLayerModelData):
	if obj:
		obj.layer = model_data.layer
