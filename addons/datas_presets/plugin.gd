@tool
extends EditorPlugin
## This is the plugin executed by godot when activated in project (see plugin.cfg)


var custom_inspectors: Array[EditorInspectorPlugin]


func _enter_tree() -> void:
	# add custom inspectors
	_add_custom_inspector(AudioStreamPlayerCustomInspector.get_script_path())
	_add_custom_inspector(CanvasLayerCustomInspector.get_script_path())
	_add_custom_inspector(Collision2DCustomInspector.get_script_path())
	_add_custom_inspector(Collision3DCustomInspector.get_script_path())
	_add_custom_inspector(CollisionSpringArm3DCustomInspector.get_script_path())
	_add_custom_inspector(Rendering2DCustomInspector.get_script_path())
	_add_custom_inspector(Rendering3DCustomInspector.get_script_path())
	_add_custom_inspector(ThemeVariationCustomInspector.get_script_path())

	# add autoload (runtime)
	if not ProjectSettings.has_setting("autoload/%s" % DataPresetsConstants.AUTOLOAD_NAME):
		add_autoload_singleton(
			DataPresetsConstants.AUTOLOAD_NAME,
			DataPresetsConstants.AUTOLOAD_PATH
		)


func _exit_tree() -> void:
	# remove custom inspectors
	for custom_insp in custom_inspectors:
		if custom_insp != null:
			remove_inspector_plugin(custom_insp)
	custom_inspectors.clear()

	# remove autoload (runtime)
	if ProjectSettings.has_setting("autoload/%s" % DataPresetsConstants.AUTOLOAD_NAME):
		remove_autoload_singleton(DataPresetsConstants.AUTOLOAD_NAME)


func _add_custom_inspector(custom_inspector_path: String):
	var custom_insp = load(custom_inspector_path).new()
	add_inspector_plugin(custom_insp)
	custom_inspectors.append(custom_insp)