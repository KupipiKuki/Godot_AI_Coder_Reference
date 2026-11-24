@abstract
class_name StateBase
extends Node
## Reference Godot 4.5-4.7 @abstract Base Class for Finite State Machine States.
## Enforces compile-time implementation of enter(), exit(), update(), and physics_update().

signal transition_requested(target_state_name: StringName, msg: Dictionary)


@abstract func enter(msg: Dictionary) -> void


@abstract func exit() -> void


@abstract func update(delta: float) -> void


@abstract func physics_update(delta: float) -> void
