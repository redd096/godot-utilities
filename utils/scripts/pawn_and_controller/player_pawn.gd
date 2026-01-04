class_name PlayerPawn extends Node

var current_controller : PlayerController
signal on_possess_event
signal on_unpossess_event

## This will call possess on player_controller, to possess this pawn
func possess(player_controller : PlayerController):
	if player_controller:
		player_controller.possess(self)

## This will call unpossess on current controller, to unpossess this pawn
func unpossess():
	if current_controller:
		# if current controller for some reason doesn't have this setted as pawn, force unpossess on this pawn (copy-paste from controller unpossess)
		if current_controller.current_pawn != self:
			var previous_controller = current_controller
			current_controller = null
			on_unpossess(previous_controller)
			# call anyway unpossess on controller
			previous_controller.unpossess()
		# else call unpossess normally
		else:
			current_controller.unposses()

## Called when a controller possess this pawn
func on_possess(new_controller : PlayerController):
	on_possess_event.emit(new_controller)

## Called when a controller unpossess this pawn
func on_unpossess(previous_controller : PlayerController):
	on_unpossess_event.emit(previous_controller)
