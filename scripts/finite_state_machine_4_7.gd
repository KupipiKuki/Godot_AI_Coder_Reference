class_name FiniteStateMachine
extends Node
## Reference Godot 4.7 Node-Based State Machine using @abstract StateBase & Typed Dictionaries.

signal state_changed(old_state: StringName, new_state: StringName)

@export var initial_state: StateBase

var current_state: StateBase
var _states: Dictionary[StringName, StateBase] = {}


func _ready() -> void:
	for child: Node in get_children():
		if child is StateBase:
			var state_node: StateBase = child
			_states[state_node.name] = state_node
			state_node.transition_requested.connect(transition_to)
	
	if initial_state:
		current_state = initial_state
		current_state.enter({})


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


func transition_to(target_state_name: StringName, msg: Dictionary = {}) -> void:
	if not _states.has(target_state_name):
		push_error("FiniteStateMachine: State '%s' does not exist!" % target_state_name)
		return
	
	var next_state: StateBase = _states[target_state_name]
	if next_state == current_state:
		return
	
	var old_name: StringName = current_state.name if current_state else &""
	if current_state:
		current_state.exit()
	
	current_state = next_state
	current_state.enter(msg)
	state_changed.emit(old_name, current_state.name)
