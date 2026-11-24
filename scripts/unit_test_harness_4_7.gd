class_name TestZombieSurvival
extends SceneTree
## Godot 4.7 Headless Unit & Integration Test Suite Harness.
##
## Step 1 (Generate global class cache):
##   godot --headless --path <project_dir> --import
## Step 2 (Run test suite):
##   godot --headless --path <project_dir> -s res://test_zombie_survival.gd

var _tests_passed: int = 0
var _tests_failed: int = 0


func _init() -> void:
	_run_suite.call_deferred()


func _run_suite() -> void:
	print_rich("[color=cyan][b]=== STARTING HEADLESS TEST SUITE (GODOT 4.7) ===[/b][/color]")
	await process_frame
	var initial_orphan_count: int = int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))

	_test_dictionary_reference_probe()
	await _test_deferred_collision_toggle()

	await process_frame
	_verify_orphan_nodes(initial_orphan_count)
	_finish_and_exit()


func _test_dictionary_reference_probe() -> void:
	var probe: Dictionary[StringName, Variant] = {&"triggered": false, &"value": 0}
	var cb: Callable = func(v: int) -> void:
		probe[&"triggered"] = true
		probe[&"value"] = v
	cb.call(42)
	_assert_true(bool(probe[&"triggered"]), "Dictionary probe captures signal/lambda state by reference")
	_assert_approx(float(probe[&"value"]), 42.0, "Dictionary probe stores payload accurately")


func _test_deferred_collision_toggle() -> void:
	var body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(32.0, 32.0)
	shape.shape = rect
	body.add_child(shape)
	root.add_child(body)
	await process_frame

	shape.set_deferred("disabled", true)
	await process_frame
	_assert_true(shape.disabled, "CollisionShape2D disabled after set_deferred + await process_frame")
	body.free()


func _verify_orphan_nodes(initial_orphan_count: int) -> void:
	var final_orphan_count: int = int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))
	var leaked_nodes: int = final_orphan_count - initial_orphan_count
	if leaked_nodes <= 0:
		print_rich("[color=green][b]PASSED:[/b] Zero orphan node memory leaks detected (Delta: %d).[/color]" % leaked_nodes)
		_tests_passed += 1
	else:
		push_error("FAILED: Leaked %d orphan nodes!" % leaked_nodes)
		_tests_failed += 1


func _assert_true(condition: bool, test_name: String) -> void:
	if condition:
		print_rich("  [color=green]✓ PASS:[/color] %s" % test_name)
		_tests_passed += 1
	else:
		push_error("  ✗ FAIL: %s" % test_name)
		_tests_failed += 1


func _assert_approx(actual: float, expected: float, test_name: String) -> void:
	if is_equal_approx(actual, expected):
		print_rich("  [color=green]✓ PASS:[/color] %s (Value: %.2f)" % [test_name, actual])
		_tests_passed += 1
	else:
		push_error("  ✗ FAIL: %s (Expected: %.2f, Got: %.2f)" % [test_name, expected, actual])
		_tests_failed += 1


func _finish_and_exit() -> void:
	print_rich("\n[color=cyan][b]=== TEST SUITE RESULTS ===[/b][/color]")
	print_rich("Passed: [color=green]%d[/color] | Failed: [color=red]%d[/color]" % [_tests_passed, _tests_failed])
	if _tests_failed == 0:
		quit(0)
	else:
		quit(1)
