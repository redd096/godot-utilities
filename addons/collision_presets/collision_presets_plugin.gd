@tool
class_name CollisionPresetsPlugin
extends EditorPlugin
## This is the plugin executed by godot when activated in project

var inspector_plugin: CollisionPresetsInspector


func _enter_tree() -> void:
	# add presets inspector
	inspector_plugin = load(CollisionPresetsConstants.INSPECTOR_SCRIPT_PATH).new()
	add_inspector_plugin(inspector_plugin)

	# add autoload (presets runtime)
	if not ProjectSettings.has_setting("autoload/%s" % CollisionPresetsConstants.AUTOLOAD_NAME):
		add_autoload_singleton(
			CollisionPresetsConstants.AUTOLOAD_NAME,
			CollisionPresetsConstants.AUTOLOAD_PATH
		)


func _exit_tree() -> void:
	# remove presets inspector
	if inspector_plugin != null:
		remove_inspector_plugin(inspector_plugin)

	# remove autoload (presets runtime)
	if ProjectSettings.has_setting("autoload/%s" % CollisionPresetsConstants.AUTOLOAD_NAME):
		remove_autoload_singleton(CollisionPresetsConstants.AUTOLOAD_NAME)
