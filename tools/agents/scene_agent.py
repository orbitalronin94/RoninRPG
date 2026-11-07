"""Comprobación estática mínima de escenas y recursos del prototipo."""
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
assert (ROOT/"game/project.godot").is_file()
assert (ROOT/"game/scenes/main.tscn").is_file()
assert (ROOT/"game/scripts/main.gd").is_file()
print("scene_agent: OK — proyecto, escena principal y script presentes; no sustituye una prueba en Godot")
