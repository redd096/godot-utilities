#@tool
#extends EditorPlugin

class_name Singleton

##check if this singleton is registered, otherwise instantiate and register it
static func check_instance(name: StringName, type: Object):
	#if singleton isn't already registered
	if not Engine.has_singleton(name):
		#instantiate and register 
		var instance = type.new()
		Engine.register_singleton(name, instance)
		#add to tree if this is a Node
		if instance is Node:
			#instance.name = type.name
			Engine.get_main_loop().current_scene.add_child.call_deferred(instance)

#func _enter_tree() -> void:
	#add_autoload_singleton("InputHelper", "res://addons/input_helper/input_helper.gd")
#
#func _exit_tree():
	#remove_autoload_singleton("InputHelper")
