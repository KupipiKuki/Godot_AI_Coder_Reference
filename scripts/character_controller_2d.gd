class_name PlayerController2D
extends CharacterBody2D
## Reference Godot 4.7 2D Platformer Controller.
## Demonstrates static typing, built-in get_gravity(), signals, and move_and_slide().

signal jumped
signal landed(impact_speed: float)

@export_group("Movement")
@export var speed: float = 300.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0
@export var jump_velocity: float = -450.0

var _was_on_floor: bool = false
var _last_vertical_speed: float = 0.0


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed(&"ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		jumped.emit()

	var direction: float = Input.get_axis(&"ui_left", &"ui_right")
	if not is_zero_approx(direction):
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	_last_vertical_speed = velocity.y
	move_and_slide()

	if is_on_floor() and not _was_on_floor:
		landed.emit(absf(_last_vertical_speed))
	_was_on_floor = is_on_floor()
