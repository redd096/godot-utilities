## Replicates Jolt's spring behavior: damped harmonic oscillator.
## Use frequency and damping like Jolt joints.
class_name SimulateJoint

## frequency: how fast the spring reaches its target.
##   - 20 = very stiff (reaches target in ~0.0125s)
##   - 10 = stiff (good for dragging)
##   - 2 = soft (reaches target in ~0.125s)
##
## damping: how much oscillation.
##   - 0 = oscillates forever
##   - 1 = critically damped (no overshoot, fastest settle)
##   - >1 = overdamped (slow settle, no overshoot)
##   For dragging, 1.0 is ideal.

## Applies the linear spring force to the rigidbody
static func apply_linear_spring_force(pivot: Node3D, target: RigidBody3D, local_anchor_point: Vector3 = Vector3.ZERO, frequency: float = 3.0, damping: float = 1.0, max_force: float = 80.0) -> void:
	# instead of have a simple (pivot.global_position - target.global_position)
	# we use the anchor point as target position
	var world_anchor_point := target.to_global(local_anchor_point)
	# calculate force
	var displacement := pivot.global_position - world_anchor_point
	var force := compute_linear_force(
		displacement,
		target.linear_velocity,
		target.mass,
		frequency,
		damping,
		max_force
	)
	# and apply (calculate position from the center of the target)
	# var force_position := world_anchor_point - target.global_position
	# target.apply_force(force, force_position)
	target.apply_central_force(force)
	# target.apply_impulse(force * delta) # alternative but seems the same

## Applies the angular spring torque to the rigidbody
static func apply_angular_spring_torque(pivot: Node3D, target: RigidBody3D, frequency: float = 3.0, damping: float = 1.0, max_torque: float = 0.0) -> void:
	# calculate necessary rotation
	var rot_diff := get_rotation_difference(
		target.global_transform.basis,
		pivot.global_transform.basis
	)
	# calculate torque
	var torque := compute_angular_torque(
		rot_diff,
		# target.global_transform.basis,
		target.angular_velocity,
		target.get_inverse_inertia_tensor().inverse(),
		frequency,
		damping,
		max_torque
	)
	# and apply
	target.apply_torque(torque)

## Sets the angular velocity of the rigidbody
static func apply_angular_spring_velocity(pivot: Node3D, target: RigidBody3D, delta: float, frequency: float = 10.0, damping: float = 1.0, rotation_speed: float = 10.0) -> void:
	# calculate necessary rotation
	var rot_diff := get_rotation_difference(
		target.global_transform.basis,
		pivot.global_transform.basis
	)
	# use angular velocity instead of apply_torque to make it easier
	var target_angular_vel := rot_diff * frequency
	var target_damp := clampf(damping * delta * rotation_speed, 0.0, 1.0)
	# blend toward it (damping)
	target.angular_velocity = target.angular_velocity.lerp(target_angular_vel, target_damp)

#region linear

## Calculates the spring force for linear movement.
## displacement: pivot.global_position - target.global_position
## velocity: current linear velocity of the rigidbody (target.linear_velocity)
## mass: mass of the rigidbody (target.mass)
## frequency: spring frequency (Hz), same as Jolt's PARAM_LINEAR_SPRING_FREQUENCY
## damping: damping ratio, same as Jolt's PARAM_LINEAR_SPRING_DAMPING
## max_force: maximum force magnitude (0 = unlimited), same as Jolt's PARAM_LINEAR_SPRING_MAX_FORCE
static func compute_linear_force(
	displacement: Vector3,
	linear_velocity: Vector3,
	mass: float,
	frequency: float,
	damping: float,
	max_force: float = 0.0
) -> Vector3:
	# k = m * (2π * f)²
	var omega := TAU * frequency
	var k := mass * omega * omega
	# c = m * 2 * d * (2π * f)
	var c := mass * 2.0 * damping * omega

	# F = k * displacement - c * velocity
	var force := k * displacement - c * linear_velocity

	# clamp to max force
	if max_force > 0.0 and force.length() > max_force:
		force = force.normalized() * max_force

	return force

#endregion

#region angular

# ## Calculates the spring torque for angular correction.
# ## rotation_diff: the rotation needed to go from current to target (as a vector of axis * angle) (see get_rotation_difference())
# ## target_global_basis: global basis of the target (target.global_transform.basis)
# ## angular_velocity: current angular velocity of the rigidbody (target.angular_velocity)
# ## inertia: local rigidbody's inertia (target.get_inverse_inertia_tensor().inverse())
# ## frequency: spring frequency (Hz), same as Jolt's PARAM_ANGULAR_SPRING_FREQUENCY
# ## damping: damping ratio, same as Jolt's PARAM_ANGULAR_SPRING_DAMPING
# ## max_torque: maximum torque magnitude (0 = unlimited), same as Jolt's PARAM_ANGULAR_SPRING_MAX_FORCE
# static func compute_angular_torque(
# 	rotation_diff: Vector3,
# 	target_global_basis: Basis,
# 	angular_velocity: Vector3,
# 	inertia: Basis,
# 	frequency: float,
# 	damping: float,
# 	max_torque: float
# ) -> Vector3:
# 	var omega := TAU * frequency
# 	# convert inertia from local to global
# 	inertia = target_global_basis * inertia * target_global_basis.transposed()
# 	# F = m * ((2π * f)² * angle - 2 * d * (2π * f) * velocity)
# 	var torque := inertia * (omega * omega * rotation_diff - 2.0 * damping * omega * angular_velocity)
# 	if max_torque > 0.0 and torque.length() > max_torque:
# 		torque = torque.normalized() * max_torque
# 	return torque

## Calculates the spring torque for angular correction.
## rotation_diff: the rotation needed to go from current to target (as a vector of axis * angle) (see get_rotation_difference())
## angular_velocity: current angular velocity of the rigidbody (target.angular_velocity)
## inertia: local rigidbody's inertia (target.get_inverse_inertia_tensor().inverse())
## frequency: spring frequency (Hz), same as Jolt's PARAM_ANGULAR_SPRING_FREQUENCY
## damping: damping ratio, same as Jolt's PARAM_ANGULAR_SPRING_DAMPING
## max_torque: maximum torque magnitude (0 = unlimited), same as Jolt's PARAM_ANGULAR_SPRING_MAX_FORCE
static func compute_angular_torque(
	rotation_diff: Vector3,
	angular_velocity: Vector3,
	inertia: Basis,
	frequency: float,
	damping: float,
	max_torque: float
) -> Vector3:
	# k = m * (2π * f)²
	var omega := TAU * frequency
	var k := inertia * omega * omega
	# c = m * 2 * d * (2π * f)
	var c := inertia * 2.0 * damping * omega

	# F = k * displacement - c * velocity
	var torque := k * rotation_diff - c * angular_velocity

	# clamp to max torque
	if max_torque > 0.0 and torque.length() > max_torque:
		torque = torque.normalized() * max_torque
	
	return torque

## Helper: get the rotation difference as axis * angle (shortest path).
## Returns a Vector3 where direction = axis, length = angle in radians.
static func get_rotation_difference(current_basis: Basis, target_basis: Basis) -> Vector3:
	# relative rotation from current to target
	var relative := target_basis * current_basis.inverse()
	# convert to quaternion to extract axis-angle
	var quat := relative.get_rotation_quaternion()
	# ensure shortest path
	if quat.w < 0.0:
		quat = -quat
	# get axis and angle
	var angle := 2.0 * acos(clampf(quat.w, -1.0, 1.0))
	if angle < 0.001:
		return Vector3.ZERO
	var axis := Vector3(quat.x, quat.y, quat.z).normalized()
	return axis * angle

#endregion
