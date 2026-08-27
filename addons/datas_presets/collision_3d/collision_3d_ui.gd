@tool
class_name Collision3DUI
extends BaseDataUI
## Inspector UI instantiated from custom inspector


func _get_database_type() -> StringName:
	return &"Collision3DPresetsDatabase"


# not necessary, already the CSGShape3D renderize it only when use_collision is true

# func set_target(object: Object) -> void:
# 	super.set_target(object)	

# 	# preset ui is showed only when use_collision is true in CSGShape3D
# 	# so activate process to continue check use_collision
# 	if target is CSGShape3D:
# 		set_process(true)
# 	# for other nodes, can deactivate process because is always showed
# 	else:
# 		set_process(false)


# func _process(_delta: float) -> void:
# 	# check if use_collision change, to show or hide preset ui
# 	if is_instance_valid(target) and target is CSGShape3D:
# 		visible = (target as CSGShape3D).use_collision
