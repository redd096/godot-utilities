## Basic class for a StateMachine
class_name StateMachine extends Node

var current_state: State
signal on_exit_state(state: State)
signal on_enter_state(state: State)
signal on_set_state(prev_state: State, new_state: State)

func _process(delta: float) -> void:
	if current_state:
		current_state._process_state(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state._physics_process_state(delta)

## Exit from current state and enter new state
func set_state(new_state: State) -> void:
	if current_state:
		current_state._exit_state()
		on_exit_state.emit(current_state)

	# set new state
	var prev_state := current_state
	current_state = new_state

	if current_state:
		current_state.state_machine = self
		current_state._enter_state()
		on_enter_state.emit(current_state)
	
	# call event
	on_set_state.emit(prev_state, current_state)
