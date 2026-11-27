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
func death_animation(
	node_colliders: Array[CollisionShape3D],	## node colliders to disable when start ragdoll 
	node_animations: Array[AnimationTree],		## node animations to disable when start ragdoll
	node: Node3D,								## node to destroy after ragdoll
	from_hit: Vector3,							## hit global position, to know the direction for the push
	push_force: float = 3.0,					## horizontal push force 
	up_force: float = 2.0,						## vertical push force
	ragdoll_time_before_destroy: float = 10.0	## time in ragdoll before destroy the node
	) -> void:
		# horizontal impulse + vertical impulse
		var direction: Vector3 = node.global_position - from_hit
		var push: Vector3 = Vector3(direction.x, 0.0, direction.z).normalized()
		push *= push_force
		push.y = up_force

		# start ragdoll, apply impulse, wait and destroy
		start_ragdoll(node_colliders, node_animations)
		apply_impulse(push)
		await get_tree().create_timer(ragdoll_time_before_destroy).timeout
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