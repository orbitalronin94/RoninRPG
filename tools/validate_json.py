#!/usr/bin/env python3
"""Valida la coherencia básica de los JSON narrativos de Ronin RPG."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "game" / "data"

def load(name):
    with (DATA / name).open(encoding="utf-8") as handle:
        return json.load(handle)

def main():
    world = load("world.json")
    npcs = load("npcs.json")
    story = load("story_graph.json")
    missions = load("missions.json")

    assert len(world["factions"]) == 4, "Se esperaban 4 facciones"
    assert len(world["locations"]) == 5, "Se esperaban 5 localizaciones"
    assert len(npcs["npcs"]) == 6, "Se esperaban 6 personajes"
    node_ids = {node["id"] for node in story["nodes"]}
    mission_ids = {mission["id"] for mission in missions["missions"]}
    for node in story["nodes"]:
        for next_id in node["next_nodes"]:
            assert next_id in node_ids, f"Destino inexistente: {next_id}"
        for mission_id in node["missions"]:
            assert mission_id in mission_ids, f"Misión inexistente: {mission_id}"
    for mission in missions["missions"]:
        assert mission["node"] in node_ids, f"Nodo inexistente: {mission['node']}"
    assert "nodo_7" in node_ids and "nodo_8" in node_ids
    print("OK: JSON narrativos válidos y referencias internas coherentes.")

if __name__ == "__main__":
    main()
