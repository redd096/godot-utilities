class_name RagdollComponent extends Node

## [codeblock lang=text]
## How to create ragdoll:
## - select Skeleton3D in the unit
## - on topbar appear a "Skeleton3D" button, click it
## - then click Create Physical Skeleton
## - it will create a PhysicalBoneSimulator3D, and for every bone a PhysicalBone3D and a CollisionShape3D
## - edit them as you like
## - set on_ready_disable_ragdoll true or unflag PhysicalBoneSimulator3D.Active (to disable joint and collision in Play)
## [/codeblock]


@export var on_ready_disable_ragdoll: bool = true
@export var ragdoll: PhysicalBoneSimulator3D


## On start, disable ragdoll
func _ready() -> void:
	if on_ready_disable_ragdoll:
		stop_ragdoll()


## Start ragdoll and after few seconds, destroy this unit
func death_animation(node_colliders: Array[CollisionShape3D], node_animations: Array[AnimationTree], node: Node3D,
	impulse: Vector3 = Vector3(0.0, 2.0, 3.0), 
	ragdoll_time_before_destroy: float = 10.0) -> void:
		# start ragdoll and disable node colliders
		start_ragdoll(node_colliders, node_animations)
		apply_impulse(node.global_basis * impulse)
		# wait few seconds
		await get_tree().create_timer(ragdoll_time_before_destroy).timeout
		# then destroy node
		node.queue_free()




## Start ragdoll (enable PhysicalBoneSimulator3D and every joint and collision in it) [br]
## and disable every collider and animation passed as parameter (e.g. disable the player collider and starts its ragdoll instead)
func start_ragdoll(colliders: Array[CollisionShape3D] = [], animations: Array[AnimationTree] = []) -> void:
	# disable elements
	for c: CollisionShape3D in colliders:
		c.disabled = true
	for a: AnimationTree in animations:
		a.active = false
	
	# and start ragdoll
	ragdoll.active = true						# enable joints colliders
	ragdoll.physical_bones_start_simulation()	# start physics simulation


## Stop ragdoll (disable PhysicalBoneSimulator3D and every joint and collision in it) [br]
## and enable every collider and animation passed as parameter (e.g. re-enable player collider and stop its ragdoll)
func stop_ragdoll(colliders: Array[CollisionShape3D] = [], animations: Array[AnimationTree] = []) -> void:
	# stop ragdoll
	ragdoll.physical_bones_stop_simulation()	# stop physics simulation
	ragdoll.active = false						# disable joints colliders

	# and re-enable elements
	for c: CollisionShape3D in colliders:
		c.disabled = false
	for a: AnimationTree in animations:
		a.active = true


## Apply the same impulse (global space) to every physical bone, so the whole body is pushed together
func apply_impulse(impulse: Vector3) -> void:
	for bone: Node in ragdoll.get_children():
		if bone is PhysicalBone3D:
			bone.apply_central_impulse(impulse)