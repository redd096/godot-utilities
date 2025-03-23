extends Node

class_name CanvasLayerDataController

## Set layer to this object
@export var canvas_layer : CanvasLayer
## Find data inside Resource by Name
@export var rendering_name : StringName
## Find data inside a Resource in your project by Name
@export var rendering_data : CanvasLayerDataResource
	
func _ready() -> void:
	if canvas_layer == null || rendering_data == null:
		push_error("Be sure to set the variables in inspector")
		return

	#find data by name
	for model_data in rendering_data.data:
		if model_data.name == rendering_name:
			#set layer
			set_rendering(canvas_layer, model_data)
			return

	push_error("Impossible to find this name in the list: " + rendering_name)

## Set layer for this object
func set_rendering(obj : CanvasLayer, model_data : CanvasLayerModelData):
	if obj:
		obj.layer = model_data.layer
