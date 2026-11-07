extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const SAVE_PATH := "user://shadow_dojo.json"

var failed := false

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: ", label)
	else:
		failed = true
		push_error("FAIL: " + label)

func _remove_save() -> void:
	var absolute := ProjectSettings.globalize_path(SAVE_PATH)
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(absolute)
	if FileAccess.file_exists(SAVE_PATH + ".tmp"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH + ".tmp"))

func _run() -> void:
	_remove_save()
	var game = MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame

	game.call("_new_game")
	_check(int(game.get("mode")) == 1, "new game enters gameplay")
	_check(String(game.get("dialogue")).contains("Kōan"), "Akane speaks in a kōan")
	_check(String(game.get("dialogue")).split("\n").size() >= 3, "Akane dialogue is multiline")

	game.set("player", Vector2(142, 218))
	game.call("_interact")
	_check(bool(game.get("mika_spoken")), "first Mika interaction is recorded")
	_check(int(game.get("honor")) == 1, "Mika reward is granted once")
	_check(String(game.get("dialogue")).contains("Haiku"), "Mika first line is a haiku")
	game.call("_interact")
	_check(int(game.get("honor")) == 1, "repeating Mika interaction does not duplicate reward")
	_check(String(game.get("dialogue")).contains("Kōan"), "Mika repeat line is a kōan")

	game.set("player", Vector2(420, 218))
	game.call("_interact")
	_check(int(game.get("area")) == 1, "village exit transitions to forest")
	_check(bool(game.get("enemy_alive")), "forest transition spawns first encounter")

	game.call("_spawn", "boss")
	game.set("enemy_pos", Vector2(150, 218))
	game.set("player", Vector2(100, 218))
	game.set("facing", 1)
	game.set("enemy_hp", 1)
	game.set("attack", "heavy")
	game.call("_hit_enemy")
	_check(bool(game.get("boss_done")), "boss defeat sets completion flag")
	_check(int(game.get("mode")) == 3, "boss defeat reaches victory state")
	_check(FileAccess.file_exists(SAVE_PATH), "victory writes a save file")

	var resumed = MAIN_SCENE.instantiate()
	root.add_child(resumed)
	await process_frame
	_check(bool(resumed.get("boss_done")), "continue restores boss completion")
	_check(int(resumed.get("mode")) == 3, "completed save resumes in victory state")
	_check(bool(resumed.get("mika_spoken")), "continue restores one-time NPC flag")

	_remove_save()
	if failed:
		push_error("RONIN smoke test failed")
		quit(1)
	else:
		print("RONIN smoke test: all checks passed")
		quit(0)
