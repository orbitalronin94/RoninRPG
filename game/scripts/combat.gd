extends Node2D
## Duelo arcade 2D de samuráis. Todo el arte de esta escena se dibuja por código,
## sin recursos externos ni dependencias de terceros.

const FLOOR_Y := 386.0
const PLAYER_START_X := 265.0
const ENEMY_START_X := 695.0
const GRAVITY := 1450.0

var rng := RandomNumberGenerator.new()
var player_x := PLAYER_START_X
var player_y := FLOOR_Y
var player_vy := 0.0
var player_hp := 100
var player_ki := 50
var enemy_x := ENEMY_START_X
var enemy_hp := 100
var player_state := "idle"
var enemy_state := "idle"
var player_attack_timer := 0.0
var enemy_attack_timer := 0.0
var player_cooldown := 0.0
var enemy_cooldown := 0.0
var enemy_decision_timer := 0.7
var enemy_state_timer := 0.0
var player_hit_applied := false
var enemy_hit_applied := false
var block_held := false
var touch_left := false
var touch_right := false
var jump_requested := false
var player_facing := 1
var enemy_facing := -1
var player_special := false
var enemy_special := false
var hit_flash_player := 0.0
var hit_flash_enemy := 0.0
var hitstop := 0.0
var combo_count := 0
var combo_timer := 0.0
var round_time := 60.0
var result := ""
var result_saved := false
var status_line := "Derrota al rival para restaurar tu honor."
var sparks: Array[Dictionary] = []

func _ready() -> void:
	rng.randomize()
	get_window().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	queue_redraw()

func _process(delta: float) -> void:
	if result.is_empty():
		if hitstop > 0.0:
			hitstop = maxf(0.0, hitstop - delta)
		else:
			_update_player(delta)
			_update_enemy(delta)
			_update_actions(delta)
			round_time = maxf(0.0, round_time - delta)
			if round_time <= 0.0:
				_finish("draw")
			elif player_hp <= 0:
				_finish("loss")
			elif enemy_hp <= 0:
				_finish("win")
	_update_sparks(delta)
	hit_flash_player = maxf(0.0, hit_flash_player - delta)
	hit_flash_enemy = maxf(0.0, hit_flash_enemy - delta)
	combo_timer = maxf(0.0, combo_timer - delta)
	if combo_timer <= 0.0:
		combo_count = 0
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_touch_press(event.position)
		else:
			block_held = false
			touch_left = false
			touch_right = false
		return

	if not event is InputEventKey:
		return
	var key_event := event as InputEventKey
	if key_event.keycode == KEY_L:
		block_held = key_event.pressed
		return
	if not key_event.pressed or key_event.echo:
		return

	if not result.is_empty():
		if key_event.keycode == KEY_ESCAPE:
			_return_to_world()
		elif key_event.keycode == KEY_ENTER or key_event.keycode == KEY_SPACE:
			_reset_round()
		return

	match key_event.keycode:
		KEY_J, KEY_Z:
			_player_attack(false)
		KEY_K, KEY_X:
			_player_attack(true)
		KEY_SPACE, KEY_W, KEY_UP:
			jump_requested = true
		KEY_SHIFT:
			_dash()
		KEY_ESCAPE:
			_return_to_world()

func _touch_press(pos: Vector2) -> void:
	if not result.is_empty():
		if Rect2(280, 405, 400, 74).has_point(pos):
			_reset_round()
		elif Rect2(790, 12, 156, 56).has_point(pos):
			_return_to_world()
		return

	if Rect2(18, 438, 66, 72).has_point(pos):
		touch_left = true
	elif Rect2(88, 438, 66, 72).has_point(pos):
		touch_right = true
	elif Rect2(160, 438, 68, 72).has_point(pos):
		jump_requested = true
	elif Rect2(235, 438, 68, 72).has_point(pos):
		_dash()
	elif Rect2(638, 438, 68, 72).has_point(pos):
		block_held = true
	elif Rect2(715, 425, 94, 88).has_point(pos):
		_player_attack(false)
	elif Rect2(817, 425, 126, 88).has_point(pos):
		_player_attack(true)

func _update_player(delta: float) -> void:
	player_cooldown = maxf(0.0, player_cooldown - delta)
	player_facing = 1 if enemy_x >= player_x else -1
	var move_dir := 0.0
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A) or touch_left:
		move_dir -= 1.0
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D) or touch_right:
		move_dir += 1.0

	if player_y < FLOOR_Y:
		player_vy += GRAVITY * delta
		player_y += player_vy * delta
		if player_y >= FLOOR_Y:
			player_y = FLOOR_Y
			player_vy = 0.0
	elif jump_requested:
		player_vy = -510.0
		player_y = FLOOR_Y - 1.0
		jump_requested = false
	else:
		jump_requested = false

	if block_held and player_state not in ["attack", "special", "hit"]:
		player_state = "block"
	elif player_state == "block" and not block_held:
		player_state = "idle"

	if player_state not in ["attack", "special", "hit", "block"]:
		player_x += move_dir * 255.0 * delta
		if absf(move_dir) > 0.01:
			player_state = "run"
		else:
			player_state = "idle"
	player_x = clampf(player_x, 48.0, 912.0)

func _update_enemy(delta: float) -> void:
	enemy_cooldown = maxf(0.0, enemy_cooldown - delta)
	enemy_decision_timer = maxf(0.0, enemy_decision_timer - delta)
	enemy_state_timer = maxf(0.0, enemy_state_timer - delta)
	enemy_facing = -1 if enemy_x > player_x else 1

	if enemy_state == "hit" and enemy_state_timer <= 0.0:
		enemy_state = "idle"
	if enemy_state == "block" and enemy_state_timer <= 0.0:
		enemy_state = "idle"
	if enemy_state in ["attack", "special", "hit", "block"]:
		return

	var distance := absf(enemy_x - player_x)
	if distance > 122.0:
		enemy_x -= signf(enemy_x - player_x) * 78.0 * delta
		enemy_state = "run"
	elif enemy_decision_timer <= 0.0 and enemy_cooldown <= 0.0:
		enemy_decision_timer = rng.randf_range(0.28, 0.72)
		var roll := rng.randf()
		if enemy_hp < 32 and roll < 0.26:
			enemy_state = "block"
			enemy_state_timer = 0.55
		elif player_ki >= 25 and roll > 0.73:
			_enemy_attack(true)
		else:
			_enemy_attack(false)
	enemy_x = clampf(enemy_x, 48.0, 912.0)

func _update_actions(delta: float) -> void:
	if player_attack_timer > 0.0:
		player_attack_timer = maxf(0.0, player_attack_timer - delta)
		if not player_hit_applied and player_attack_timer <= 0.16:
			player_hit_applied = true
			_resolve_player_hit()
		if player_attack_timer <= 0.0:
			player_state = "block" if block_held else "idle"
			player_special = false

	if enemy_attack_timer > 0.0:
		enemy_attack_timer = maxf(0.0, enemy_attack_timer - delta)
		if not enemy_hit_applied and enemy_attack_timer <= 0.16:
			enemy_hit_applied = true
			_resolve_enemy_hit()
		if enemy_attack_timer <= 0.0:
			enemy_state = "idle"
			enemy_special = false

func _player_attack(special: bool) -> void:
	if not result.is_empty() or player_cooldown > 0.0 or player_state in ["hit", "attack", "special", "block"]:
		return
	if special and player_ki < 25:
		status_line = "Necesitas 25 de KI para el Corte del Sauce."
		return
	player_special = special
	player_state = "special" if special else "attack"
	player_attack_timer = 0.34 if special else 0.25
	player_cooldown = 0.52 if special else 0.30
	player_hit_applied = false
	if special:
		player_ki -= 25
		status_line = "¡CORTE DEL SAUCE!"
	else:
		status_line = "Corte rápido."
	_spawn_sparks(Vector2(player_x + player_facing * 42.0, player_y - 78.0), Color("#9deaff") if special else Color("#fff0c2"), 7)

func _enemy_attack(special: bool) -> void:
	if enemy_cooldown > 0.0:
		return
	enemy_special = special
	enemy_state = "special" if special else "attack"
	enemy_attack_timer = 0.36 if special else 0.27
	enemy_cooldown = 0.86 if special else 0.68
	enemy_hit_applied = false

func _resolve_player_hit() -> void:
	var distance := absf(enemy_x - player_x)
	var reach := 226.0 if player_special else 116.0
	if distance > reach:
		status_line = "El rival esquivó el alcance."
		return
	var damage := rng.randi_range(23, 31) if player_special else rng.randi_range(10, 16)
	if enemy_state == "block":
		damage = maxi(2, int(round(float(damage) * 0.24)))
		status_line = "El rival bloqueó parte del golpe."
	else:
		status_line = "¡Impacto! El rival pierde %d HP." % damage
		enemy_state = "hit"
		enemy_state_timer = 0.20
		enemy_attack_timer = 0.0
		enemy_special = false
	enemy_hp = maxi(0, enemy_hp - damage)
	player_ki = mini(100, player_ki + 8)
	combo_count += 1
	combo_timer = 1.15
	hitstop = 0.035
	hit_flash_enemy = 0.12
	_spawn_sparks(Vector2(enemy_x - player_facing * 12.0, FLOOR_Y - 78.0), Color("#ffe7a0"), 13)

func _resolve_enemy_hit() -> void:
	var distance := absf(enemy_x - player_x)
	var reach := 205.0 if enemy_special else 124.0
	if distance > reach:
		status_line = "El rival falló el ataque."
		return
	var damage := rng.randi_range(19, 26) if enemy_special else rng.randi_range(8, 14)
	if block_held or player_state == "block":
		damage = maxi(1, int(round(float(damage) * 0.18)))
		status_line = "Bloqueo perfecto: daño reducido."
	else:
		status_line = "¡Te han alcanzado! -%d HP." % damage
		player_state = "hit"
		player_vy = minf(player_vy, -45.0)
		player_attack_timer = 0.0
		player_special = false
	player_hp = maxi(0, player_hp - damage)
	hitstop = 0.045
	hit_flash_player = 0.14
	_spawn_sparks(Vector2(player_x + enemy_facing * 12.0, player_y - 78.0), Color("#ff8d83"), 12)

func _dash() -> void:
	if not result.is_empty() or player_state in ["attack", "special", "hit"]:
		return
	player_x = clampf(player_x + player_facing * 74.0, 48.0, 912.0)
	player_ki = mini(100, player_ki + 3)
	_spawn_sparks(Vector2(player_x - player_facing * 16.0, player_y - 28.0), Color("#8fe7e4"), 5)
	status_line = "Paso veloz."

func _spawn_sparks(pos: Vector2, tint: Color, amount: int) -> void:
	for i in range(amount):
		var angle := rng.randf_range(0.0, TAU)
		var speed := rng.randf_range(85.0, 280.0)
		sparks.append({
			"position": pos,
			"velocity": Vector2(cos(angle), sin(angle)) * speed,
			"life": rng.randf_range(0.14, 0.38),
			"color": tint
		})

func _update_sparks(delta: float) -> void:
	for i in range(sparks.size() - 1, -1, -1):
		var particle: Dictionary = sparks[i]
		var pos: Vector2 = particle["position"]
		var velocity: Vector2 = particle["velocity"]
		var life := float(particle["life"]) - delta
		particle["position"] = pos + velocity * delta
		particle["life"] = life
		if life <= 0.0:
			sparks.remove_at(i)
		else:
			sparks[i] = particle

func _finish(outcome: String) -> void:
	if not result.is_empty():
		return
	result = outcome
	result_saved = true
	if outcome == "win":
		status_line = "Victoria. Honor +5. El camino del rōnin continúa."
	elif outcome == "loss":
		status_line = "Derrota. Recupera el aliento y vuelve a intentarlo."
	else:
		status_line = "El duelo termina sin vencedor."
	_persist_result(outcome)

func _persist_result(outcome: String) -> void:
	var data: Dictionary = {}
	if FileAccess.file_exists("user://decisions.json"):
		var file_read := FileAccess.open("user://decisions.json", FileAccess.READ)
		if file_read != null:
			var parsed = JSON.parse_string(file_read.get_as_text())
			file_read.close()
			if parsed is Dictionary:
				data = parsed
	if outcome == "win":
		data["duel_wins"] = int(data.get("duel_wins", 0)) + 1
		data["honor"] = clampi(int(data.get("honor", 50)) + 5, 0, 100)
	elif outcome == "loss":
		data["honor"] = clampi(int(data.get("honor", 50)) - 2, 0, 100)
	var file_write := FileAccess.open("user://decisions.json", FileAccess.WRITE)
	if file_write != null:
		file_write.store_string(JSON.stringify(data, "\t"))
		file_write.close()

func _reset_round() -> void:
	player_x = PLAYER_START_X
	player_y = FLOOR_Y
	player_vy = 0.0
	player_hp = 100
	player_ki = 50
	enemy_x = ENEMY_START_X
	enemy_hp = 100
	player_state = "idle"
	enemy_state = "idle"
	player_attack_timer = 0.0
	enemy_attack_timer = 0.0
	player_cooldown = 0.0
	enemy_cooldown = 0.0
	enemy_decision_timer = 0.6
	enemy_state_timer = 0.0
	player_hit_applied = false
	enemy_hit_applied = false
	player_special = false
	enemy_special = false
	block_held = false
	result = ""
	result_saved = false
	combo_count = 0
	combo_timer = 0.0
	round_time = 60.0
	status_line = "El duelo comienza. ¡Encuentra tu apertura!"
	sparks.clear()

func _return_to_world() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _draw() -> void:
	_draw_stage()
	_draw_fighter(player_x, player_y, player_facing, true, player_state, hit_flash_player)
	_draw_fighter(enemy_x, FLOOR_Y, enemy_facing, false, enemy_state, hit_flash_enemy)
	_draw_sparks()
	_draw_hud()
	_draw_controls()
	if not result.is_empty():
		_draw_result()

func _draw_stage() -> void:
	draw_rect(Rect2(0, 0, 960, 540), Color("#10182b"))
	draw_rect(Rect2(0, 0, 960, 240), Color("#202b49"))
	draw_circle(Vector2(480, 154), 76, Color(0.98, 0.49, 0.34, 0.10))
	draw_circle(Vector2(480, 154), 56, Color("#ef9b73"))
	draw_circle(Vector2(480, 154), 45, Color("#f5b38b"))
	for i in range(14):
		var x := float((i * 83 + 19) % 950)
		var y := float((i * 47 + 22) % 220)
		draw_circle(Vector2(x, y), 1.5, Color(0.9, 0.92, 1.0, 0.55))
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, 274), Vector2(112, 198), Vector2(205, 252),
		Vector2(315, 188), Vector2(420, 272), Vector2(535, 205),
		Vector2(660, 267), Vector2(788, 190), Vector2(960, 268),
		Vector2(960, 350), Vector2(0, 350)
	]), Color("#26364b"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, 310), Vector2(160, 255), Vector2(278, 300),
		Vector2(420, 246), Vector2(560, 308), Vector2(720, 252),
		Vector2(860, 298), Vector2(960, 270), Vector2(960, 390),
		Vector2(0, 390)
	]), Color("#1d2c3b"))
	# Torii silhouetted against the sunset.
	draw_rect(Rect2(92, 220, 15, 128), Color("#7c393c"))
	draw_rect(Rect2(42, 213, 116, 13), Color("#a74b4a"))
	draw_rect(Rect2(32, 205, 136, 9), Color("#c26759"))
	draw_rect(Rect2(65, 240, 70, 8), Color("#7c393c"))
	# Bamboo and lanterns.
	for bx in [12.0, 188.0, 770.0, 940.0]:
		draw_line(Vector2(bx, 240), Vector2(bx + 4, 340), Color("#42604d"), 5.0)
		for by in [260.0, 292.0, 322.0]:
			draw_line(Vector2(bx - 8, by), Vector2(bx + 5, by - 9), Color("#58775a"), 3.0)
	draw_rect(Rect2(0, 340, 960, 200), Color("#29313a"))
	draw_rect(Rect2(0, 340, 960, 8), Color("#d2a16d"))
	for i in range(9):
		var y := 354.0 + float(i * i) * 2.0
		draw_line(Vector2(0, y), Vector2(960, y), Color(0.75, 0.61, 0.47, 0.18), 1.0)
	for x in range(-80, 1040, 120):
		draw_line(Vector2(480, 344), Vector2(float(x), 540), Color(0.75, 0.61, 0.47, 0.14), 1.0)
	# Low-contrast floor calligraphy-like strokes.
	for i in range(16):
		var x := float((i * 137 + 24) % 940)
		var y := 365.0 + float((i * 31) % 130)
		draw_line(Vector2(x, y), Vector2(x + 18, y - 3), Color(0.89, 0.72, 0.52, 0.10), 2.0)

func _draw_fighter(x: float, ground_y: float, facing: int, is_player: bool, state: String, flash: float) -> void:
	var base := Vector2(x, ground_y)
	var robe := Color("#234f7d") if is_player else Color("#6b293b")
	var robe_light := Color("#4b8db2") if is_player else Color("#a3484e")
	var trim := Color("#e7d3a2") if is_player else Color("#e7b76b")
	var skin := Color("#d5a07d")
	var hair := Color("#17202a") if is_player else Color("#211821")
	if flash > 0.0:
		robe = Color("#fff5e7")
		robe_light = Color("#fff5e7")
		skin = Color("#fff5e7")
	var lean := 0.0
	if state in ["attack", "special"]:
		lean = float(facing) * 9.0
	elif state == "hit":
		lean = -float(facing) * 8.0
	elif state == "run":
		lean = float(facing) * 3.0
	# Ground shadow and feet.
	draw_circle(base + Vector2(0, 1), 31, Color(0.02, 0.03, 0.05, 0.36))
	draw_line(base + Vector2(-14, -5), base + Vector2(-2, -2), Color("#171a22"), 8.0)
	draw_line(base + Vector2(4, -3), base + Vector2(18, -6), Color("#171a22"), 8.0)
	# Legs and split hakama.
	draw_colored_polygon(PackedVector2Array([
		base + Vector2(-15, -36), base + Vector2(1, -36),
		base + Vector2(9, -6), base + Vector2(-4, -4),
		base + Vector2(-18, -23)
	]), robe)
	draw_colored_polygon(PackedVector2Array([
		base + Vector2(1, -36), base + Vector2(16, -37),
		base + Vector2(21, -8), base + Vector2(8, -5),
		base + Vector2(-2, -23)
	]), robe_light)
	# Kimono torso silhouette.
	draw_colored_polygon(PackedVector2Array([
		base + Vector2(-17 + lean, -86), base + Vector2(12 + lean, -87),
		base + Vector2(25 + lean, -45), base + Vector2(12, -28),
		base + Vector2(-17, -33), base + Vector2(-25 + lean, -54)
	]), robe)
	draw_colored_polygon(PackedVector2Array([
		base + Vector2(-2 + lean, -84), base + Vector2(12 + lean, -80),
		base + Vector2(4, -39), base + Vector2(-6, -35),
		base + Vector2(-11 + lean, -61)
	]), robe_light)
	# Obi and gold seam.
	draw_line(base + Vector2(-17, -48), base + Vector2(17, -48), trim, 5.0)
	draw_line(base + Vector2(-7, -80), base + Vector2(7, -48), Color("#f4e6c5"), 2.0)
	# Arms, animated on attack frames.
	var arm_start := base + Vector2(10 + lean, -76)
	var arm_end := base + Vector2(float(facing) * (29.0 if state in ["attack", "special"] else 20.0), -64)
	draw_line(arm_start, arm_end, robe, 12.0)
	draw_circle(arm_end, 6.0, skin)
	draw_line(base + Vector2(-14, -75), base + Vector2(-25, -55), robe, 10.0)
	# Head, hair, headband and determined eyes.
	draw_circle(base + Vector2(0, -104), 15, skin)
	draw_colored_polygon(PackedVector2Array([
		base + Vector2(-15, -105), base + Vector2(-12, -120),
		base + Vector2(2, -126), base + Vector2(15, -116),
		base + Vector2(15, -107), base + Vector2(5, -113),
		base + Vector2(-4, -112)
	]), hair)
	draw_line(base + Vector2(-13, -108), base + Vector2(13, -109), trim, 3.0)
	draw_line(base + Vector2(float(facing) * 3, -102), base + Vector2(float(facing) * 9, -101), Color("#24202a"), 2.0)
	# Katana and its bright edge.
	var sword_start := base + Vector2(float(facing) * 17.0, -70.0)
	var sword_end := base + Vector2(float(facing) * (100.0 if state in ["attack", "special"] else 52.0), -103.0 if state in ["attack", "special"] else -86.0)
	if state == "block":
		sword_end = base + Vector2(float(facing) * 28.0, -122.0)
	draw_line(sword_start, sword_start + Vector2(float(facing) * 10.0, 2.0), Color("#342b2a"), 7.0)
	draw_line(sword_start + Vector2(float(facing) * 8.0, 0), sword_end, Color("#e0e6ec"), 4.0)
	draw_line(sword_start + Vector2(float(facing) * 8.0, -2), sword_end + Vector2(0, -2), Color("#ffffff"), 1.5)
	if state == "special":
		var arc_start := -1.05 if facing > 0 else PI - 1.05
		var arc_end := 1.05 if facing > 0 else PI + 1.05
		draw_arc(base + Vector2(float(facing) * 30.0, -85.0), 74.0, arc_start, arc_end, 24, Color(0.43, 0.91, 1.0, 0.86), 7.0)
		draw_arc(base + Vector2(float(facing) * 30.0, -85.0), 88.0, arc_start, arc_end, 24, Color(0.72, 0.97, 1.0, 0.35), 13.0)
		draw_circle(base + Vector2(float(facing) * 26.0, -82.0), 18, Color(0.35, 0.86, 1.0, 0.18))

func _draw_sparks() -> void:
	for particle in sparks:
		var pos: Vector2 = particle["position"]
		var velocity: Vector2 = particle["velocity"]
		var tint: Color = particle["color"]
		draw_line(pos, pos - velocity * 0.035, tint, 2.0)

func _draw_hud() -> void:
	draw_rect(Rect2(18, 14, 924, 100), Color(0.025, 0.035, 0.065, 0.84))
	draw_string(ThemeDB.fallback_font, Vector2(34, 36), "KAGETORA", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#f7e7c8"))
	draw_string(ThemeDB.fallback_font, Vector2(926, 36), "RONIN DE KANEGAWA", HORIZONTAL_ALIGNMENT_RIGHT, -1, 17, Color("#f7e7c8"))
	_draw_bar(Rect2(34, 46, 365, 19), player_hp, Color("#d94c51"), Color("#682d39"))
	_draw_bar(Rect2(561, 46, 365, 19), enemy_hp, Color("#d94c51"), Color("#682d39"))
	draw_string(ThemeDB.fallback_font, Vector2(34, 83), "HP %d / 100" % player_hp, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#f3dfc4"))
	draw_string(ThemeDB.fallback_font, Vector2(926, 83), "HP %d / 100" % enemy_hp, HORIZONTAL_ALIGNMENT_RIGHT, -1, 13, Color("#f3dfc4"))
	_draw_bar(Rect2(34, 91, 220, 8), player_ki, Color("#48c7dc"), Color("#203747"), 100.0)
	draw_string(ThemeDB.fallback_font, Vector2(480, 78), "%02d" % int(ceil(round_time)), HORIZONTAL_ALIGNMENT_CENTER, 0, 28, Color("#ffe7ae"))
	draw_string(ThemeDB.fallback_font, Vector2(480, 101), "RONIN DUEL", HORIZONTAL_ALIGNMENT_CENTER, 0, 10, Color("#c8b9a0"))
	if combo_count >= 2 and combo_timer > 0.0:
		draw_string(ThemeDB.fallback_font, Vector2(305, 150), "%d HIT COMBO" % combo_count, HORIZONTAL_ALIGNMENT_CENTER, 350, 20, Color("#ffe49c"))
	draw_rect(Rect2(18, 392, 924, 32), Color(0.02, 0.025, 0.04, 0.72))
	draw_string(ThemeDB.fallback_font, Vector2(32, 413), status_line, HORIZONTAL_ALIGNMENT_LEFT, 890, 14, Color("#f4e8d5"))

func _draw_bar(rect: Rect2, value: int, fill: Color, back: Color, max_value: float = 100.0) -> void:
	draw_rect(rect, back)
	var ratio := clampf(float(value) / max_value, 0.0, 1.0)
	var fill_width := rect.size.x * ratio
	if fill_width > 0.0:
		draw_rect(Rect2(rect.position, Vector2(fill_width, rect.size.y)), fill)
	draw_rect(rect, Color(1.0, 0.91, 0.72, 0.5), false, 1.0)

func _draw_controls() -> void:
	_draw_button(Rect2(18, 438, 66, 72), "◀", Color("#374a60"))
	_draw_button(Rect2(88, 438, 66, 72), "▶", Color("#374a60"))
	_draw_button(Rect2(160, 438, 68, 72), "JUMP", Color("#46525d"))
	_draw_button(Rect2(235, 438, 68, 72), "DASH", Color("#46525d"))
	_draw_button(Rect2(638, 438, 68, 72), "GUARD", Color("#34564e"), block_held)
	_draw_button(Rect2(715, 425, 94, 88), "SLASH", Color("#7a3941"))
	_draw_button(Rect2(817, 425, 126, 88), "SPECIAL\n25 KI", Color("#286879"))
	draw_string(ThemeDB.fallback_font, Vector2(22, 532), "A/D o ◀ ▶ · J/Z: corte · K/X: especial · L: bloquear · Shift: dash · Esc: salir", HORIZONTAL_ALIGNMENT_LEFT, 916, 12, Color("#c4c8cb"))

func _draw_button(rect: Rect2, label: String, tint: Color, active: bool = false) -> void:
	var fill := tint.lightened(0.28) if active else tint
	draw_rect(rect, Color(0.015, 0.02, 0.03, 0.55))
	draw_rect(Rect2(rect.position + Vector2(2, 2), rect.size - Vector2(4, 4)), fill)
	draw_rect(rect, Color(0.9, 0.82, 0.68, 0.65), false, 1.0)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(0, rect.size.y * 0.57), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 13, Color("#fff0d7"))

func _draw_result() -> void:
	draw_rect(Rect2(0, 0, 960, 540), Color(0.01, 0.015, 0.03, 0.72))
	var headline := "VICTORIA" if result == "win" else ("DERROTA" if result == "loss" else "EMPATE")
	var headline_color := Color("#ffe3a1") if result == "win" else Color("#f08c89")
	draw_string(ThemeDB.fallback_font, Vector2(480, 228), headline, HORIZONTAL_ALIGNMENT_CENTER, 0, 48, headline_color)
	draw_string(ThemeDB.fallback_font, Vector2(480, 268), status_line, HORIZONTAL_ALIGNMENT_CENTER, 760, 17, Color("#f7e7d0"))
	draw_rect(Rect2(280, 405, 400, 74), Color("#733841"))
	draw_rect(Rect2(284, 409, 392, 66), Color("#a94d4d"))
	draw_string(ThemeDB.fallback_font, Vector2(480, 437), "OTRA RONDA", HORIZONTAL_ALIGNMENT_CENTER, 0, 18, Color("#fff0d7"))
	draw_string(ThemeDB.fallback_font, Vector2(480, 461), "ENTER / toca aquí", HORIZONTAL_ALIGNMENT_CENTER, 0, 13, Color("#ffe0b3"))
	draw_string(ThemeDB.fallback_font, Vector2(926, 35), "ESC: VOLVER", HORIZONTAL_ALIGNMENT_RIGHT, -1, 12, Color("#ffe0b3"))
