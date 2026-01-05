## Basic class for a State of a StateMachine
class_name State extends Node

var state_machine: StateMachine

func _enter_state() -> void:
	pass

func _process_state(_delta: float) -> void:
	pass

func _exit_state() -> void:
	pass