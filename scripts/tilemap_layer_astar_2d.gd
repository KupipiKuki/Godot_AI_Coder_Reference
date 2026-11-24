class_name TacticalGridManager
extends Node2D
## Reference Godot 4.7 TileMapLayer + AStarGrid2D Integration.
## Uses TileMapLayer (replacing deprecated TileMap) and chunked 4.5+ physics.

@export var ground_layer: TileMapLayer
@export var obstacle_layer: TileMapLayer
@export var cell_size: Vector2i = Vector2i(16, 16)

var astar_grid := AStarGrid2D.new()


func _ready() -> void:
	setup_grid()


func setup_grid() -> void:
	assert(ground_layer != null, "TacticalGridManager requires a 'ground_layer' TileMapLayer.")
	astar_grid.region = ground_layer.get_used_rect()
	astar_grid.cell_size = Vector2(cell_size)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	
	if obstacle_layer:
		for cell: Vector2i in obstacle_layer.get_used_cells():
			if astar_grid.is_in_boundsv(cell):
				astar_grid.set_point_solid(cell, true)


func get_world_path(start_world: Vector2, end_world: Vector2) -> PackedVector2Array:
	var start_cell: Vector2i = ground_layer.local_to_map(ground_layer.to_local(start_world))
	var end_cell: Vector2i = ground_layer.local_to_map(ground_layer.to_local(end_world))
	
	if not astar_grid.is_in_boundsv(start_cell) or not astar_grid.is_in_boundsv(end_cell):
		return PackedVector2Array()
	
	var cell_path: Array[Vector2i] = astar_grid.get_id_path(start_cell, end_cell)
	var world_points := PackedVector2Array()
	for cell: Vector2i in cell_path:
		world_points.append(ground_layer.to_global(ground_layer.map_to_local(cell)))
	return world_points
