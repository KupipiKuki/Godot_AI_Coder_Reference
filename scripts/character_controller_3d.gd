class_name FirstPersonController3D
extends CharacterBody3D
## Reference Godot 4.7 3D Character Controller (Default Jolt Physics 3D Ready).
## Demonstrates mouse-look camera, queued physics-frame 3D raycast interaction, and get_gravity().

signal interacted_with(target: Object)

@export_group("Movement")
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.5
@export var jump_velocity: float = 4.5
@export var acceleration: float = 12.0

@export_group("Camera & Interaction")
@export_range(0.0005, 0.01, 0.0001) var mouse_sensitivity: float = 0.0025
@export var interact_distance: float = 3.0
@export_flags_3d_physics var interact_mask: int = 1

var _pending_interact: bool = false

@onready var head: Node3D = %Head
@onready var camera: Camera3D = %Camera3D


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clampf(head.rotation.x, deg_to_rad(-89.0), deg_to_rad(89.0))
	
	if event.is_action_pressed(&"ui_cancel"):
		Input.mouse_mode = (
			Input.MOUSE_MODE_VISIBLE
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
			else Input.MOUSE_MODE_CAPTURED
		)
	
	if event.is_action_pressed(&"interact"):
		_pending_interact = true


func _physics_process(delta: float) -> void:
	if _pending_interact:
		_pending_interact = false
		_try_interact_raycast()

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed(&"ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir: Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
	var wish_dir: Vector3 = (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	var target_speed: float = sprint_speed if Input.is_action_pressed(&"sprint") else walk_speed

	if wish_dir != Vector3.ZERO:
		velocity.x = move_toward(velocity.x, wish_dir.x * target_speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, wish_dir.z * target_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
		velocity.z = move_toward(velocity.z, 0.0, acceleration * delta)

	move_and_slide()


func _try_interact_raycast() -> void:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var origin: Vector3 = camera.global_position
	var end: Vector3 = origin + (-camera.global_transform.basis.z * interact_distance)
	
	var query := PhysicsRayQueryParameters3D.create(origin, end, interact_mask, [self])
	query.collide_with_areas = true
	
	var result: Dictionary = space_state.intersect_ray(query)
	if not result.is_empty():
		var collider: Object = result["collider"]
		interacted_with.emit(collider)
		if collider.has_method(&"interact"):
			collider.call(&"interact", self)
