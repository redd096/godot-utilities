#@tool
#extends EditorPlugin
#
#func _enter_tree() -> void:
	#add_autoload_singleton("InputHelper", "res://addons/input_helper/input_helper.gd")
#
#func _exit_tree():
	#remove_autoload_singleton("InputHelper")

class_name Singleton

## Return registered instance. If not registered, find in scene or instantiate it. 
## NB instantiate only if scrit_type is != null. 
## e.g. Singleton.instance("Camera2D", Camera2D) to look for Camera2D in scene, else instantiate it
## e.g. Singleton.instance("Camera") to look for Camera2D in scene, else return null
static func instance(type : String, script_type : Object = null) -> Variant:
	#if singleton is already registered, return it
	if Engine.has_singleton(type):
		return Engine.get_singleton(type)
	#if singleton isn't already registered
	else:
		#try find it in scene
		var obj_instance : Object = find_object_of_type(type)
		#or instantiate it
		if obj_instance == null and script_type != null:
			print(type, " is null. It will be automatically instantiated")
			obj_instance = script_type.new()
			obj_instance.name = str(type, " (Auto Instantiated)")
			#add to tree if this is a Node (under root to have it as DontDestroyOnLoad)
			if obj_instance is Node:
				Engine.get_main_loop().root.add_child.call_deferred(obj_instance)
		#register it
		if obj_instance:
			Engine.register_singleton(type, obj_instance)
		return obj_instance

## Equivalent of unity FindObjectOfType<type>
static func find_object_of_type(type : String) -> Variant:
	var root_node : Node = Engine.get_main_loop().current_scene
	#get components in children but ignore root node
	var components : Array = root_node.find_children("*", str(type))
	return components[0] if components.size() > 0 else null
