class_name NotificationBannerUI
extends Control
## Reference Godot 4.7 UI Animation Script.
## Demonstrates 4.7 Control.offset_transform_*, Tween.tween_await(), and interruptible Tween chains.

signal banner_dismissed

@export var display_duration: float = 2.5

var _active_tween: Tween

@onready var label: Label = %MessageLabel
@onready var close_button: Button = %CloseButton


func _ready() -> void:
	offset_transform_enabled = true
	offset_transform_pivot = size * 0.5
	modulate.a = 0.0
	hide()


func show_notification(message: String, wait_for_button: bool = false) -> void:
	label.text = message
	show()
	mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_ENABLED
	
	offset_transform_position = Vector2(0.0, -36.0)
	offset_transform_scale = Vector2(0.92, 0.92)
	modulate.a = 0.0
	
	if _active_tween and _active_tween.is_running():
		_active_tween.kill()
	
	_active_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_active_tween.set_parallel(true)
	_active_tween.tween_property(self, ^"modulate:a", 1.0, 0.25)
	_active_tween.tween_property(self, ^"offset_transform_position", Vector2.ZERO, 0.25)
	_active_tween.tween_property(self, ^"offset_transform_scale", Vector2.ONE, 0.25)
	
	if wait_for_button:
		# NEW in Godot 4.7: Pause the tween sequence directly until close_button.pressed fires!
		_active_tween.chain().tween_await(close_button.pressed)
	else:
		_active_tween.chain().tween_interval(display_duration)
	
	_active_tween.chain().tween_property(self, ^"modulate:a", 0.0, 0.2)
	_active_tween.chain().tween_callback(_on_dismiss_finished)


func dismiss_banner() -> void:
	if _active_tween and _active_tween.is_running():
		_active_tween.kill()
	
	mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
	_active_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_active_tween.tween_property(self, ^"modulate:a", 0.0, 0.2)
	_active_tween.tween_callback(_on_dismiss_finished)


func _on_dismiss_finished() -> void:
	hide()
	banner_dismissed.emit()
