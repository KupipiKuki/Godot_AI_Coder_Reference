class_name FogOfWarCanvas47
extends Sprite2D
## Reference Godot 4.7 DrawableTexture2D Script.
## Demonstrates GPU texture initialization and runtime brush blitting without a SubViewport.

@export var map_size: Vector2i = Vector2i(512, 512)
@export var fog_color: Color = Color(0.04, 0.05, 0.08, 0.94)
@export var reveal_brush: Texture2D

var drawable_fog: DrawableTexture2D


func _ready() -> void:
	drawable_fog = DrawableTexture2D.new()
	drawable_fog.setup(
		map_size.x,
		map_size.y,
		DrawableTexture2D.DRAWABLE_FORMAT_RGBA8_UNORM,
		fog_color
	)
	texture = drawable_fog


func reveal_at_local_pos(local_pos: Vector2) -> void:
	if not drawable_fog or not reveal_brush:
		return
	var brush_size: Vector2i = Vector2i(reveal_brush.get_size())
	var dest_pos: Vector2i = Vector2i(local_pos.round()) - (brush_size / 2)
	drawable_fog.blit_rect(reveal_brush, Rect2i(Vector2i.ZERO, brush_size), dest_pos)
