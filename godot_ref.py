#!/usr/bin/env python3
"""Zero-dependency CLI search and context retrieval tool for the Godot 4.7 Master AI Library."""
import argparse
import json
import os
import sys

CORE_FILES = [
    "godot_4_7_basics.json",
    "godot_4_7_functions.json",
    "godot_4_7_cross_reference.json",
]

MODULE_FILES = [
    "modules/godot_4_7_physics_2d_3d.json",
    "modules/godot_4_7_world_nav_anim.json",
    "modules/godot_4_7_ui_and_audio.json",
    "modules/godot_4_7_net_shader_arch.json",
    "modules/godot_4_7_tscn_tres_format.json",
    "modules/godot_4_7_editor_plugins.json",
    "modules/godot_4_7_testing_debugging.json",
]


def load_json(base_dir: str, rel_path: str) -> dict:
    full_path = os.path.join(base_dir, rel_path)
    if not os.path.exists(full_path):
        return {}
    with open(full_path, "r", encoding="utf-8") as f:
        return json.load(f)


def search_tree(data, query: str, path: str = ""):
    matches = []
    q = query.lower()
    if isinstance(data, dict):
        for k, v in data.items():
            cur_path = f"{path}.{k}" if path else k
            if q in k.lower():
                matches.append((cur_path, v))
            else:
                matches.extend(search_tree(v, query, cur_path))
    elif isinstance(data, list):
        for idx, item in enumerate(data):
            cur_path = f"{path}[{idx}]"
            matches.extend(search_tree(item, query, cur_path))
    elif isinstance(data, str):
        if q in data.lower():
            matches.append((path, data))
    return matches


def main() -> None:
    parser = argparse.ArgumentParser(description="Query the Godot 4.7 AI Reference Library.")
    parser.add_argument("--list", action="store_true", help="List all JSON modules and reference scripts.")
    parser.add_argument("--search", type=str, help="Keyword search across all Godot 4.7 JSON files.")
    parser.add_argument("--module", type=str, help="Print a specific JSON file or module by partial name.")
    parser.add_argument("--script", type=str, help="Print a golden reference .gd script by partial name.")
    args = parser.parse_args()

    base_dir = os.path.dirname(os.path.abspath(__file__))

    if args.list:
        print("=== Core JSON Schemas ===")
        for c in CORE_FILES:
            print(" -", c)
        print("\n=== Subsystem Modules ===")
        for m in MODULE_FILES:
            print(" -", m)
        scripts_path = os.path.join(base_dir, "scripts")
        if os.path.isdir(scripts_path):
            print("\n=== Golden Reference Scripts (scripts/) ===")
            for s in sorted(os.listdir(scripts_path)):
                print(" - scripts/" + s)
        return

    if args.module:
        target = args.module.lower()
        for rel in CORE_FILES + MODULE_FILES:
            if target in rel.lower():
                print(json.dumps(load_json(base_dir, rel), indent=2))
                return
        print(f"No module matching '{args.module}' found.", file=sys.stderr)
        sys.exit(1)

    if args.script:
        scripts_path = os.path.join(base_dir, "scripts")
        target = args.script.lower()
        if os.path.isdir(scripts_path):
            for s in sorted(os.listdir(scripts_path)):
                if target in s.lower():
                    with open(os.path.join(scripts_path, s), "r", encoding="utf-8") as f:
                        print(f.read())
                    return
        print(f"No script matching '{args.script}' found.", file=sys.stderr)
        sys.exit(1)

    if args.search:
        for rel in CORE_FILES + MODULE_FILES:
            data = load_json(base_dir, rel)
            hits = search_tree(data, args.search)
            if hits:
                print(f"\n--- Matches in {rel} ---")
                for key_path, val in hits:
                    print(f"[{key_path}]: {json.dumps(val, indent=2)}")
        return

    parser.print_help()


if __name__ == "__main__":
    main()
