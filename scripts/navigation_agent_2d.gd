class_name NavEnemy2D
extends CharacterBody2D
## Reference Godot 4.7 NavigationAgent2D Pathfinding & Avoidance Script.

@export var movement_speed: float = 140.0
@export var target_node: Node2D

var _nav_ready: bool = false

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D


func _ready() -> void:
	nav_agent.path_desired_distance = 8.0
	nav_agent.target_desired_distance = 12.0
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	
	# Wait one physics frame for NavigationServer2D to sync map data
	await get_tree().physics_frame
	_nav_ready = true


func set_movement_target(target_pos: Vector2) -> void:
	nav_agent.target_position = target_pos


func _physics_process(_delta: float) -> void:
	if not _nav_ready:
		return
	
	if is_instance_valid(target_node):
		nav_agent.target_position = target_node.global_position
	
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var next_path_pos: Vector2 = nav_agent.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_path_pos) * movement_speed
	
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)


func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()
