"""Auditor determinista de misiones y referencias al arco."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
D=ROOT/"game/data"
g=json.loads((D/"story_graph.json").read_text(encoding="utf-8"))["nodes"]
m=json.loads((D/"missions.json").read_text(encoding="utf-8"))["missions"]
node_ids={n["id"] for n in g}; mission_ids={x["id"] for x in m}
assert len(m)==20, f"Se esperaban 20 misiones, hay {len(m)}"
for n in g:
 for mid in n["missions"]: assert mid in mission_ids, f"Misión inexistente: {mid}"
for x in m: assert x["node"] in node_ids, f"Nodo inexistente: {x['node']}"
print("mission_agent: OK — veinte misiones y referencias válidas")
