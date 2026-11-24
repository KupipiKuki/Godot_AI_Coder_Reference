@tool
class_name PropSpawnerTool
extends Node2D
## Reference Godot 4.7 @tool Script.
## Demonstrates @export_tool_button and the Godot 4.7 PackedVector2Array property setter rule.

@export var spawn_scene: PackedScene
@export_range(1, 50, 1) var spawn_count: int = 5
@export var spawn_radius: float = 128.0

@export_tool_button("Spawn Props in Circle", "Node2D") var spawn_action: Callable = _spawn_props
@export_tool_button("Clear Spawned Props", "Remove") var clear_action: Callable = _clear_props


func _spawn_props() -> void:
	if not spawn_scene:
		push_warning("PropSpawnerTool: Assign a 'spawn_scene' before spawning!")
		return
	
	_clear_props()
	
	var preview_line := Line2D.new()
	preview_line.name = "RadiusPreviewLine"
	preview_line.width = 2.0
	preview_line.closed = true
	
	# Godot 4.7 PackedVector2Array Setter Rule: build local PackedVector2Array, then assign whole property
	var ring_points := PackedVector2Array()
	for i: int in range(spawn_count):
		var angle: float = (TAU / float(spawn_count)) * float(i)
		var pos: Vector2 = Vector2(cos(angle), sin(angle)) * spawn_radius
		ring_points.append(pos)
		
		var instance := spawn_scene.instantiate() as Node2D
		if instance:
			instance.name = "Prop_%d" % i
			instance.position = pos
			add_child(instance)
			if Engine.is_editor_hint() and get_tree().edited_scene_root:
				instance.owner = get_tree().edited_scene_root
	
	preview_line.points = ring_points
	add_child(preview_line)
	if Engine.is_editor_hint() and get_tree().edited_scene_root:
		preview_line.owner = get_tree().edited_scene_root


func _clear_props() -> void:
	for child: Node in get_children():
		child.queue_free()
