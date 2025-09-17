#@tool
#extends EditorPlugin
#
#func _enter_tree() -> void:
	#add_autoload_singleton("InputHelper", "res://addons/input_helper/input_helper.gd")
#
#func _exit_tree():
	#remove_autoload_singleton("InputHelper")

class_name Singleton

## If this is the instance, be sure is DontDestroyOnload and return true.
## If there is another instance, destroy this node and return false.
## Normally this functions is called in _ready() for every singleton script
static func check_instance(self_obj : Node) -> bool:
	#get current instance or find in scene
	var current_instance : Object = instance(self_obj.get_class())
	#if this is the instance, set DontDestroyOnload and return true
	if current_instance == self_obj:
		dont_destroy_on_load(self_obj)
		return true
	#else, destroy and return false
	else:
		self_obj.queue_free()
		return false

## Return registered instance. If not registered, find in scene or instantiate it.
## NB instantiate only if scrit_type is != null.
## e.g. Singleton.instance("Camera2D", Camera2D) to look for Camera2D in scene, else instantiate it
## e.g. Singleton.instance("Camera2D") to look for Camera2D in scene, else return null
static func instance(type : String, script_type : Object = null) -> Variant:
	#if singleton is already registered and it's still valid, return it
	if Engine.has_singleton(type):
		var current_instance = Engine.get_singleton(type)
		if current_instance:
			return current_instance
	#if singleton isn't already registered or it is no more valid
	#try find it in scene
	var obj_instance : Object = find_object_of_type(type)
	#or instantiate it
	if obj_instance == null and script_type != null:
		print(type, " is null. It will be automatically instantiated")
		obj_instance = script_type.new()
		obj_instance.name = str(type, " (Auto Instantiated)")
	#register it
	if obj_instance:
		Engine.register_singleton(type, obj_instance)
		#if this is a Node be sure is in the tree and DontDestroyOnLoad
		if obj_instance is Node:
			dont_destroy_on_load(obj_instance)
	return obj_instance

## Equivalent of unity FindObjectOfType<type>
static func find_object_of_type(type : String) -> Variant:
	var root_node : Node = Engine.get_main_loop().root
	#get components in children but ignore root node
	var components : Array = root_node.find_children("*", str(type), true, false)
	return components[0] if components.size() > 0 else null

## Equivalent of unity DontDestroyOnLoad(GameObject)
static func dont_destroy_on_load(node : Node) -> void:
	#check if this is already child of root node
	var parent : Node = node.get_parent()
	var root : Node = Engine.get_main_loop().root
	if parent and parent == root:
		return
	#else remove from current parent
	if parent:
		parent.remove_child.call_deferred(node)
	#and set child of root node (this isn't destroyed when change scene)
	root.add_child.call_deferred(node)
