class_name MarginContainerSafeArea extends Node

@export var margin_container: MarginContainer

func _ready() -> void:
	# current margins
	var left: int = margin_container.get_theme_constant("margin_left")
	var top: int = margin_container.get_theme_constant("margin_top")
	var right: int = margin_container.get_theme_constant("margin_right")
	var bottom: int = margin_container.get_theme_constant("margin_bottom")
	
	# safe area
	var safe_area: Rect2i = DisplayServer.get_display_safe_area()
	var screen_size: Vector2i = DisplayServer.screen_get_size()
	var safe_left = safe_area.position.x
	var safe_top = safe_area.position.y
	var safe_right = screen_size.x - safe_area.end.x
	var safe_bottom = screen_size.y - safe_area.end.y

	# current margins + safe margins
	margin_container.add_theme_constant_override("margin_left", left + safe_left)
	margin_container.add_theme_constant_override("margin_top", top + safe_top)
	margin_container.add_theme_constant_override("margin_right", right + safe_right)
	margin_container.add_theme_constant_override("margin_bottom", bottom + safe_bottom)
