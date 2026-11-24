# AGENTS.md — Godot 4.7 Master AI Scripting & Development System

This repository provides a complete, structured JSON knowledge base, CLI lookup utility (`godot_ref.py`), and golden reference script suite for **Godot Engine 4.7 (GDScript 2.0)**. It is engineered for both frontier LLMs and local coding models to generate 100% error-free, strictly typed Godot 4.7 code and scenes.

---

## 1. File Index & Routing Map

### Core Context (Load on ALL GDScript Tasks)
* `godot_4_7_basics.json` — Canonical 16-part script layout, GDScript 2.0 annotations (`@export`, `@onready`, `@tool`, `@export_tool_button`), **4.5+ `@abstract` classes/methods**, **4.5+ variadic functions (`...args: Array`)**, **4.5+ raw `Variant` exports**, **`uid://` preloading**, Typed Dictionaries (`Dictionary[K, V]`), and 4.7 strict override return-path rules.
* `godot_4_7_functions.json` — Lifecycle virtual methods (`_ready`, `_physics_process`, `_unhandled_input`), **`Tween.tween_await(signal)` (new in 4.7)**, interruptible `Tween.chain()` rules, and `Resource.duplicate_deep()`.
* `godot_4_7_cross_reference.json` — **CRITICAL Anti-Hallucination Layer.** Enforces the 5 battle-tested Godot 4.7 guardrails and maps deprecated 3.x/4.0 APIs to exact 4.7 replacements.

### Specialized Subsystem Modules (`modules/` — Load On-Demand by Task)
* `modules/godot_4_7_physics_2d_3d.json` — **Default Jolt Physics 3D (4.6/4.7)**, **4.7 `CollisionShape2D.one_way_collision_direction`**, **4.5+ chunked `TileMapLayer` physics**, the **Melee `AttackArea` Radius Math Rule** (`radius >= Attacker_Radius + Target_Radius + 6.0`), and `_physics_process` raycast queries.
* `modules/godot_4_7_world_nav_anim.json` — **Strictly Convex `NavigationPolygon` Rule**, `NavigationAgent2D/3D` first-frame physics sync (`await get_tree().physics_frame`), 2.5D normal-mapped `CanvasTexture` lighting, and the **4.6/4.7 `SkeletonModifier3D` IK Suite**.
* `modules/godot_4_7_ui_and_audio.json` — **4.7 `Control.offset_transform_*` properties**, **4.5+ `mouse_behavior_recursive` & `focus_behavior_recursive`**, **4.7 built-in `VirtualJoystick` node**, **4.7 `RichTextLabel` `em` image sizing**, and interruptible UI banner tweens.
* `modules/godot_4_7_net_shader_arch.json` — **4.7 `DrawableTexture2D` resource**, **4.7 `AreaLight3D`**, **4.5+ `.gdshader` `stencil_mode`**, High-level Multiplayer (`@rpc`, `ENetMultiplayerPeer`), and `@abstract` FSM architecture.
* `modules/godot_4_7_tscn_tres_format.json` — Strict 6-part `.tscn` section ordering, `node_paths=PackedStringArray(...)`, `unique_name_in_owner = true`, `Polygon2D` visual requirement for physics nodes, and exact `project.godot` physical keycodes.
* `modules/godot_4_7_editor_plugins.json` — `@tool`, `@export_tool_button`, `EditorInterface` singleton, and `EditorUndoRedoManager`.
* `modules/godot_4_7_testing_debugging.json` — **The 3-Step Headless CLI Workflow** (`--import` -> `-s` -> `--quit-after 600`) and **All 5 Headless Testing Guardrails**.

### Golden Reference Scripts (`scripts/`)
* `scripts/character_controller_2d.gd` — 2D platformer controller with `get_gravity()` and `move_and_slide()`.
* `scripts/character_controller_3d.gd` — 3D FPS controller (Jolt 3D default ready) with physics-frame raycasting.
* `scripts/inventory_resource_4_7.gd` — Custom `Resource` with Typed Dictionaries, raw `Variant` export, and `uid://`.
* `scripts/editor_tool_4_7.gd` — `@tool` script using `@export_tool_button` and the **4.7 PackedArray property setter rule**.
* `scripts/async_tween_ui_4_7.gd` — UI banner using **4.7 `offset_transform_*`**, **`Tween.tween_await()`**, and `mouse_behavior_recursive`.
* `scripts/state_base_abstract_4_7.gd` — **4.5–4.7 `@abstract class_name StateBase`** enforcing virtual state methods at compile time.
* `scripts/finite_state_machine_4_7.gd` — Node-based Finite State Machine paired with `StateBase` and Typed Dictionaries.
* `scripts/navigation_agent_2d.gd` — `NavigationAgent2D` pathfinding with avoidance and physics frame sync.
* `scripts/tilemap_layer_astar_2d.gd` — `TileMapLayer` + `AStarGrid2D` tactical grid pathfinding.
* `scripts/multiplayer_manager_4_7.gd` — ENet lobby, `@rpc` synchronization, and **4.5+ variadic logging (`...details: Array`)**.
* `scripts/drawable_fog_of_war_4_7.gd` — **4.7 `DrawableTexture2D`** runtime GPU texture painting without a `SubViewport`.
* `scripts/unit_test_harness_4_7.gd` — Zero-warning headless `SceneTree` unit test suite.

---

## 2. Non-Negotiable Godot 4.7 Coding Rules for AI Agents

1. **PackedArray Property Setters (4.7 Breaking):** NEVER mutate a single element of a `Packed*Array` property in-place (`line.points[0] = v` does NOT fire the setter in 4.7). Always copy to a local variable, mutate, and reassign (`var pts := line.points; pts[0] = v; line.points = pts`).
2. **GDScript Lambda Primitive Capture Rule:** Closures capture local primitives (`bool`, `int`, `float`) by VALUE. Always use a local `Dictionary` (`var probe: Dictionary[StringName, Variant] = {&"ok": false}`) inside signal lambdas.
3. **Physics Space-State Timing:** NEVER query `get_world_2d/3d().direct_space_state` inside `_process()` or `_input()`. Queue a flag and query inside `_physics_process()`.
4. **UI Tweening in Containers (4.7 Standard):** Set `offset_transform_enabled = true` and tween `offset_transform_position` / `offset_transform_scale` / `offset_transform_rotation` instead of `position` or `scale` on Controls inside Containers.
5. **Headless CLI Verification:** Always run `godot --headless --path <dir> --import` before executing `-s` test scripts so `.godot/global_script_class_cache.cfg` is populated.
