@tool
class_name CollisionPresetsPlugin
extends EditorPlugin

var inspector_plugin: CollisionPresetsInspector


func _enter_tree() -> void:
	inspector_plugin = load(CollisionPresetsConstants.INSPECTOR_SCRIPT_PATH).new()
	add_inspector_plugin(inspector_plugin)

	if not ProjectSettings.has_setting("autoload/%s" % CollisionPresetsConstants.AUTOLOAD_NAME):
		add_autoload_singleton(
			CollisionPresetsConstants.AUTOLOAD_NAME,
			CollisionPresetsConstants.AUTOLOAD_PATH
		)


func _exit_tree() -> void:
	if inspector_plugin != null:
		remove_inspector_plugin(inspector_plugin)

	if ProjectSettings.has_setting("autoload/%s" % CollisionPresetsConstants.AUTOLOAD_NAME):
		remove_autoload_singleton(CollisionPresetsConstants.AUTOLOAD_NAME)
