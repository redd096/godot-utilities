class_name Crosshair extends Control

@export var dot_radius: float = 3.0
@export var outline_width: float = 1.5
@export var dot_color: Color = Color(1, 1, 1, 0.85)
@export var outline_color: Color = Color(0, 0, 0, 0.7)

func _draw() -> void:
	var center := size * 0.5
	# black outline circle
	draw_circle(center, dot_radius + outline_width, outline_color)
	# white dot
	draw_circle(center, dot_radius, dot_color)