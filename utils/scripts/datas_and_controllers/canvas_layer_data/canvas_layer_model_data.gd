extends Resource

class_name CanvasLayerModelData

## Name for this Data
@export var name : StringName = "Data"
## Used to help with editor, e.g. to know where this Data is used
@export_multiline var description: String
## Visibility layer. Higher values are renderized in front
@export var layer : int = 1
