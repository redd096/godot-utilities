## Basic class for a StateMachine
class_name StateMachine extends Node

var current_state: State
signal on_set_state(new_state: State)

func _process(delta: float) -> void:
	current_state._update(delta)

## Exit from current state and enter new state
func set_state(new_state: State) -> void:
	if current_state:
		current_state._exit()

	# Set new state
	current_state = new_state

	if current_state:
		current_state.state_machine = self
		current_state._enter()
	
	# Call event
	emit_signal("on_set_state", current_state)
