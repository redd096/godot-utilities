@tool
class_name Collision2DCustomInspector
extends EditorInspectorPlugin
## This add custom inspector (editor ui)


func _can_handle(object: Object) -> bool:
	# these are the nodes that can be used by this plugin
	return object is CollisionObject2D


func _parse_category(object: Object, category: String) -> void:
	# add preset in inspector, in Collision category
	var lower := category.to_lower()
	if lower != "collisionobject2d":
		return

	_add_preset_editor(object)


func _add_preset_editor(object: Object) -> void:
	# instantiate editor ui
	var ui_script: Script = load(DataPresetsConstants.COLLISION_2D_UI_PATH)
	var ui: Collision2DUI = ui_script.new()

	# initialize and add to inspector
	ui.set_target(object as Node)
	add_custom_control(ui)
