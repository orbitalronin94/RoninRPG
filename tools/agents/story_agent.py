"""Auditor determinista del grafo narrativo."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
g=json.loads((ROOT/"game/data/story_graph.json").read_text(encoding="utf-8"))["nodes"]
ids={n["id"] for n in g}
assert len(g)==12, "El arco principal debe tener doce nodos"
for n in g:
 for target in n["next_nodes"]: assert target in ids, f"{n['id']} apunta a nodo inexistente {target}"
print("story_agent: OK — doce nodos y destinos válidos")
