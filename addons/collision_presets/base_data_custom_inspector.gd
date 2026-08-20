@tool
@abstract
class_name BaseDataCustomInspector
extends EditorInspectorPlugin
## This add custom inspector (editor ui)


@abstract
func _is_supported_type(object: Object) -> bool

@abstract
func _get_category() -> String

@abstract
func _get_ui_script_path() -> String


func _can_handle(object: Object) -> bool:
	# these are the nodes that can be used by this plugin
	return _is_supported_type(object)


func _parse_category(object: Object, category: String) -> void:
	# add editor ui in inspector, in selected category
	var lower := category.to_lower()
	if lower != _get_category():
		return

	_add_preset_editor(object)


func _add_preset_editor(object: Object) -> void:
	# instantiate editor ui
	var ui_script: Script = load(_get_ui_script_path())
	var ui: BaseDataUI = ui_script.new()

	# initialize and add to inspector
	ui.set_target(object as Node)
	add_custom_control(ui)
