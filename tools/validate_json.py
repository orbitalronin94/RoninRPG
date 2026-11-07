#!/usr/bin/env python3
"""Valida coherencia de los datos narrativos de Ronin RPG."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "game" / "data"

def load(name):
    with (DATA / name).open(encoding="utf-8") as handle:
        return json.load(handle)

def main():
    world = load("world.json")
    npcs = load("npcs.json")["npcs"]
    story = load("story_graph.json")["nodes"]
    missions = load("missions.json")["missions"]
    yokai = load("yokai.json")["encounters"]
    crafting = load("crafting.json")["recipes"]
    systems = load("systems.json")

    assert len(world["factions"]) == 7, "Se esperaban 7 facciones"
    assert len(world["locations"]) == 9, "Se esperaban 9 localizaciones"
    assert len(npcs) >= 12, "Faltan personajes principales/secundarios"
    assert len(story) == 12, "El arco debe tener 12 nodos"
    assert len(missions) == 20, "Se esperaban 20 misiones (12 principales + 8 secundarias)"
    assert len(yokai) == 10, "Se esperaban 10 encuentros yōkai"
    assert len(crafting) >= 5, "Faltan recetas de crafteo"
    assert len(systems["endings"]) == 6, "Deben existir seis finales"
    node_ids = {node["id"] for node in story}
    mission_ids = {mission["id"] for mission in missions}
    assert len(node_ids) == len(story), "IDs de nodo duplicados"
    assert len(mission_ids) == len(missions), "IDs de misión duplicados"
    for node in story:
        for next_id in node["next_nodes"]:
            assert next_id in node_ids, f"Destino inexistente: {next_id}"
        for mission_id in node["missions"]:
            assert mission_id in mission_ids, f"Misión inexistente: {mission_id}"
    for mission in missions:
        assert mission["node"] in node_ids, f"Nodo inexistente: {mission['node']}"
    print("OK: JSON válidos; 7 facciones, 9 zonas, 12 nodos, 20 misiones, 10 yōkai y 6 finales.")

if __name__ == "__main__":
    main()
