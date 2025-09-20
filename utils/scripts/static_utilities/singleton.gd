#@tool
#extends EditorPlugin
#
#func _enter_tree() -> void:
	#add_autoload_singleton("InputHelper", "res://addons/input_helper/input_helper.gd")
#
#func _exit_tree():
	#remove_autoload_singleton("InputHelper")

class_name Singleton

## If this is the instance, return true (and can set DontDestroyOnLoad). 
## If there is another instance, destroy this node and return false. 
## Normally this functions is called in _ready() for every singleton script
static func check_instance(self_obj: Node, set_dont_destroy_on_load: bool = true) -> bool:
	# Get current instance or find in scene
	var script_type = self_obj.get_script()
	var current_instance : Object = instance(script_type)
	# If this is the instance, set DontDestroyOnload and return true
	if current_instance == self_obj:
		if set_dont_destroy_on_load:
			_dont_destroy_on_load(self_obj)
		return true
	# Else, destroy and return false
	else:
		self_obj.queue_free()
		return false

## Return registered instance. If not registered, find in scene or instantiate it. 
## e.g. Singleton.instance(Camera2D, true) to look for Camera2D in scene, else instantiate it
## e.g. Singleton.instance(Camera2D, false) to look for Camera2D in scene, else return null
static func instance(script_type: Object, auto_instantiate: bool = false) -> Variant:
	# If singleton is already registered and it's still valid, return it
	var type := _get_string_from_script_type(script_type)
	if Engine.has_singleton(type):
		var current_instance = Engine.get_singleton(type)
		if current_instance:
			return current_instance
	# If singleton isn't already registered or it is no more valid
	# try find it in scene
	var obj_instance : Object = _find_object_of_type(script_type)
	# or instantiate it
	if obj_instance == null and auto_instantiate:
		print(type, " is null. It will be automatically instantiated")
		obj_instance = script_type.new()
		obj_instance.name = str(type, " (Auto Instantiated)")
	# Register it
	if obj_instance:
		Engine.register_singleton(type, obj_instance)
	return obj_instance

## Return class name or filename
static func _get_string_from_script_type(script_type: Object) -> String:
	var type : String = ""
	# Check if the argument is a Script resource
	if script_type is Script:
		# Get the class name defined by 'class_name'
		type = script_type.get_global_name()
		# If no class_name is defined, fall back to the filename
		if type.is_empty():
			type = script_type.resource_path.get_file().get_basename()
	# Otherwise, assume it's a built-in Godot class and use get_class()
	else:
		type = script_type.get_class()
	return type

## Equivalent of unity FindObjectOfType<type>
static func _find_object_of_type(script_type: Object) -> Variant:
	var type := _get_string_from_script_type(script_type)
	var root_node : Node = Engine.get_main_loop().root
	# Get components in children but ignore root node
	var components : Array = root_node.find_children("*", str(type), true, false)
	return components[0] if components.size() > 0 else null

## Equivalent of unity DontDestroyOnLoad(GameObject)
static func _dont_destroy_on_load(node : Node) -> void:
	# Check if this is already child of root node
	var parent : Node = node.get_parent()
	var root : Node = Engine.get_main_loop().root
	if parent and parent == root:
		return
	# Else remove from current parent
	if parent:
		parent.remove_child.call_deferred(node)
	# And set child of root node (this isn't destroyed when change scene)
	root.add_child.call_deferred(node)
