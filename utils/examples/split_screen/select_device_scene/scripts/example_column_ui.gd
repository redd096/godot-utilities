class_name ExampleColumnUI extends Node

@export var color_rect : ColorRect
@export var label : Label
@export var elements_container : Node

func update_label(text : String) -> void:
	label.text = text
