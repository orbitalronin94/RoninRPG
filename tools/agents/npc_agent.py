"""Auditor determinista de fichas de personajes."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
data=json.loads((ROOT/"game/data/npcs.json").read_text(encoding="utf-8"))["npcs"]
ids=[n["id"] for n in data]
assert len(ids)==len(set(ids)), "IDs de NPC duplicados"
assert {"kagetora","oren","yasuke","kiyohime","shiro","elder_hana","renji","taro","sayo","blind_hermit","chief_kuma","fisher_jiro"} <= set(ids)
print(f"npc_agent: OK — {len(data)} NPCs con IDs únicos")
