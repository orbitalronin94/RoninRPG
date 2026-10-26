"""Auditor determinista de mundo y facciones; no llama a modelos externos."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
data=json.loads((ROOT/"game/data/world.json").read_text(encoding="utf-8"))
assert len(data["factions"]) == 7, "Deben existir siete facciones"
assert len(data["locations"]) == 9, "Deben existir nueve zonas"
assert len({x["id"] for x in data["factions"]}) == len(data["factions"]), "IDs de facción duplicados"
print("world_agent: OK — siete facciones, nueve zonas")
