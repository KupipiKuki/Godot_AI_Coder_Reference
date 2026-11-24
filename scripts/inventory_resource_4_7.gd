class_name InventoryData
extends Resource
## Reference Godot 4.7 Custom Resource.
## Demonstrates Typed Dictionaries, raw Variant exports (4.5+), Typed Arrays, and UIDs.

signal inventory_updated

@export var inventory_name: String = "Player Backpack"
@export var max_slots: int = 20

## Typed Dictionary [KeyType, ValueType] exported directly to Inspector
@export var item_counts: Dictionary[StringName, int] = {
	&"health_potion": 3,
	&"mana_potion": 1,
}

## Godot 4.5-4.7: Raw Variant export with dynamic Inspector type selector
@export var custom_metadata_payload: Variant = null

## Path-agnostic uid:// reference
@export_file("*.tres", "*.res") var fallback_item_uid: String = ""

## Typed Array of Strings/Tags
@export var unlocked_tags: Array[String] = ["starter_gear"]


func add_item(item_id: StringName, amount: int = 1) -> void:
	assert(amount > 0, "Amount to add must be positive.")
	var current: int = item_counts.get(item_id, 0)
	item_counts[item_id] = current + amount
	inventory_updated.emit()


func remove_item(item_id: StringName, amount: int = 1) -> bool:
	var current: int = item_counts.get(item_id, 0)
	if current < amount:
		return false
	
	if current == amount:
		item_counts.erase(item_id)
	else:
		item_counts[item_id] = current - amount
	
	inventory_updated.emit()
	return true


func get_item_count(item_id: StringName) -> int:
	return item_counts.get(item_id, 0)
