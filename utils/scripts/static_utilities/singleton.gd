#@tool
#extends EditorPlugin
#
#func _enter_tree() -> void:
	#add_autoload_singleton("InputHelper", "res://addons/input_helper/input_helper.gd")
#
#func _exit_tree():
	#remove_autoload_singleton("InputHelper")

## Call Singleton.instance(Camera2D) to get Camera2D as it has a static instance variable
class_name Singleton

## If this is the instance (or there aren't instances and this is set now as instance), return true (and can set DontDestroyOnLoad). 
## If there is already another instance, destroy this object if destroyCopies is true. 
## Normally this function is called in _ready() for every singleton script
static func check_instance(obj: Node, set_dont_destroy_on_load: bool = true, destroy_copies: bool = true) -> bool:
	# Get current instance or find in scene
	var script_type = obj.get_script()
	var current_instance: Object = instance(script_type)
	# If this is the instance, return true
	if current_instance == obj:
		# And set DontDestroyOnLoad
		if set_dont_destroy_on_load:
			_dont_destroy_on_load(obj)
		return true
	# Else, destroy and return false
	else:
		if destroy_copies:
			obj.queue_free()
		return false

## Return instance for this type. If there isn't, find in scene or instantiate it
## e.g. Singleton.instance(Camera2D, true) to look for Camera2D in scene, else instantiate it
## e.g. Singleton.instance(Camera2D, false) to look for Camera2D in scene, else return null
static func instance(script_type: Object, auto_instantiate: bool = false) -> Variant:
	# If there is an instance and it's still valid, return it
	var type := _get_string_from_script_type(script_type)
	if Engine.has_singleton(type):
		var current_instance = Engine.get_singleton(type)
		if current_instance:
			return current_instance
	# If there isn't an instance ot it's not valid, try find in scene
	var obj_instance: Object = _find_object_of_type(script_type)
	# or instantiate it
	if obj_instance == null and auto_instantiate:
		obj_instance = script_type.new()
		obj_instance.name = str(type, " (Auto Instantiated)")
	# Then register it
	if obj_instance:
		Engine.register_singleton(type, obj_instance)
	return obj_instance

#region copy-paste from unity_like

## Return class name or filename
static func _get_string_from_script_type(script_type: Object) -> String:
	var type: String = ""
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
	var root_node: Node = Engine.get_main_loop().root
	# Get components in children but ignore root node
	var components: Array = root_node.find_children("*", str(type), true, false)
	return components[0] if components.size() > 0 else null

## Equivalent of unity DontDestroyOnLoad(GameObject)
static func _dont_destroy_on_load(node: Node) -> void:
	# Set root as parent (this isn't destroyed when change scene)
	var root: Node = Engine.get_main_loop().root
	# Check if this is already child of this parent
	var current_parent = node.get_parent()
	if current_parent and current_parent == root:
		return
	# Else remove from current parent
	if current_parent:
		current_parent.remove_child.call_deferred(node)
	# And set child of new parent
	root.add_child.call_deferred(node)

#endregion
