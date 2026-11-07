extends Node2D
## Shadow Dojo prototype: side-view action combat with original procedural pixel art.

const W := 480.0
const H := 270.0
const FLOOR := 218.0
const SAVE := "user://shadow_dojo.json"

enum Mode { TITLE, GAME, PAUSE, WIN, LOSE }
enum Area { VILLAGE, FOREST }

var mode := Mode.TITLE
var area := Area.VILLAGE
var player := Vector2(82, FLOOR)
var velocity := Vector2.ZERO
var facing := 1
var hp := 100
var max_hp := 100
var xp := 0
var level := 1
var gold := 0
var honor := 0
var boss_done := false
var save_exists := false
var mika_spoken := false
var enemy := ""
var enemy_pos := Vector2(380, FLOOR)
var enemy_hp := 0
var enemy_max := 0
var enemy_state := "approach"
var enemy_clock := 0.0
var enemy_alive := false
var attack := ""
var attack_clock := 0.0
var attack_cd := 0.0
var hit_done := false
var dodge_clock := 0.0
var dodge_cd := 0.0
var invuln := 0.0
var guard := false
var flash := 0.0
var message := "Habla con Mika y cruza al bosque de bambú."
var dialogue := ""
var touch := {}
var tap := ""

func _ready() -> void:
	get_window().title = "RONIN: SHADOW DOJO"
	_load_save()

func _process(dt: float) -> void:
	flash = maxf(0, flash - dt)
	if mode == Mode.GAME:
		if tap == "jump":
			_jump()
			tap = ""
		elif tap == "dodge":
			_dodge()
			tap = ""
		_update_player(dt)
		_update_attack(dt)
		_update_enemy(dt)
		if tap == "interact":
			_interact()
		tap = ""
	elif mode == Mode.TITLE and tap == "start":
		_new_game()
		tap = ""
	elif mode == Mode.TITLE and tap == "continue":
		_continue_game()
		tap = ""
	elif mode == Mode.PAUSE and tap == "resume":
		mode = Mode.GAME
		tap = ""
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		if mode == Mode.TITLE:
			tap = "continue" if event.position.x > 240.0 else "start"
			return
		if mode == Mode.PAUSE:
			mode = Mode.GAME
			return
		if mode == Mode.WIN or mode == Mode.LOSE:
			mode = Mode.TITLE
			return
		var a := _touch_action(event.position)
		if a != "":
			touch[event.index] = a
			if a == "light" or a == "heavy" or a == "interact" or a == "jump" or a == "dodge":
				tap = a
			elif a == "pause":
				mode = Mode.PAUSE
	elif event is InputEventScreenTouch and not event.pressed:
		touch.erase(event.index)
	elif event is InputEventScreenDrag:
		var a := _touch_action(event.position)
		if a == "":
			touch.erase(event.index)
		else:
			touch[event.index] = a
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if mode == Mode.GAME: mode = Mode.PAUSE
			elif mode == Mode.PAUSE: mode = Mode.GAME
			else: mode = Mode.TITLE
		elif mode == Mode.TITLE and (event.keycode == KEY_ENTER or event.keycode == KEY_SPACE):
			_new_game()
		elif mode == Mode.TITLE and event.keycode == KEY_C:
			_continue_game()
		elif mode == Mode.PAUSE and event.keycode == KEY_ENTER:
			mode = Mode.GAME
		elif mode == Mode.GAME:
			if event.keycode == KEY_J: tap = "light"
			elif event.keycode == KEY_K: tap = "heavy"
			elif event.keycode == KEY_L: _dodge()
			elif event.keycode == KEY_W or event.keycode == KEY_SPACE: _jump()
			elif event.keycode == KEY_E: tap = "interact"

func _down(action: String) -> bool:
	return touch.values().has(action)

func _touch_action(p: Vector2) -> String:
	if p.y < 200.0:
		if p.x > 438.0 and p.y < 42.0: return "pause"
		if p.x > 430.0 and p.y > 160.0: return "interact"
		return ""
	if p.x < 62: return "left"
	if p.x < 118: return "right"
	if p.x >= 220 and p.x < 280: return "jump"
	if p.x > 434: return "heavy"
	if p.x > 388: return "light"
	if p.x > 338: return "dodge"
	if p.x > 286: return "guard"
	return "interact"

func _update_player(dt: float) -> void:
	var axis := 0.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT) or _down("left"): axis -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT) or _down("right"): axis += 1
	guard = Input.is_key_pressed(KEY_I) or _down("guard")
	if dodge_clock > 0:
		player.x += facing * 220 * dt
		dodge_clock = maxf(0, dodge_clock - dt)
		invuln = maxf(invuln, 0.07)
	else:
		player.x += axis * 118 * dt
		if player.y < FLOOR:
			velocity.y += 560 * dt
			player.y += velocity.y * dt
			if player.y >= FLOOR:
				player.y = FLOOR
				velocity.y = 0
	if axis != 0: facing = 1 if axis > 0 else -1
	player.x = clampf(player.x, 18, 462)
	attack_cd = maxf(0, attack_cd - dt)
	dodge_cd = maxf(0, dodge_cd - dt)
	invuln = maxf(0, invuln - dt)

func _jump() -> void:
	if player.y >= FLOOR:
		velocity.y = -205

func _dodge() -> void:
	if dodge_cd <= 0 and dodge_clock <= 0:
		dodge_clock = 0.22
		dodge_cd = 0.72
		invuln = 0.25

func _update_attack(dt: float) -> void:
	if tap == "light" or tap == "heavy":
		if attack_cd <= 0 and not guard:
			attack = tap
			attack_clock = 0.28 if tap == "light" else 0.43
			attack_cd = 0.34 if tap == "light" else 0.58
			hit_done = false
		tap = ""
	if attack_clock > 0:
		attack_clock -= dt
		if not hit_done and attack_clock <= (0.12 if attack == "light" else 0.19):
			hit_done = true
			_hit_enemy()
		if attack_clock <= 0: attack = ""

func _hit_enemy() -> void:
	if not enemy_alive: return
	var dx := enemy_pos.x - player.x
	if absf(dx) > (66 if attack == "light" else 82) or signf(dx) != float(facing): return
	var dmg := 18 if attack == "light" else 31
	if enemy == "boss" and enemy_state != "recover": dmg = int(dmg * 0.72)
	enemy_hp = maxi(0, enemy_hp - dmg)
	flash = 0.12
	if enemy_hp == 0: _enemy_defeated()
	else:
		enemy_state = "recover"
		enemy_clock = 0.42

func _spawn(kind: String) -> void:
	enemy = kind
	enemy_alive = true
	enemy_pos = Vector2(380, FLOOR)
	enemy_state = "approach"
	if kind == "grunt":
		enemy_hp = 48
		message = "Yokai menor: observa su anticipación y contraataca."
	elif kind == "archer":
		enemy_hp = 42
		message = "Yurei arquera: mantén la presión y evita su proyectil."
	else:
		enemy_hp = 170
		message = "Jefa: Guardiana del Sello. Sus golpes son lentos y devastadores."
	enemy_max = enemy_hp

func _update_enemy(dt: float) -> void:
	if not enemy_alive: return
	if enemy_state == "recover":
		enemy_clock -= dt
		if enemy_clock <= 0: enemy_state = "approach"
	elif enemy_state == "telegraph":
		enemy_clock -= dt
		if enemy_clock <= 0:
			enemy_state = "strike"
			enemy_clock = 0.16
	elif enemy_state == "strike":
		enemy_clock -= dt
		if enemy_clock <= 0:
			_enemy_strike()
			enemy_state = "recover"
			enemy_clock = 0.82 if enemy == "boss" else 0.68
	else:
		var dx := player.x - enemy_pos.x
		var dist := absf(dx)
		var reach := 118.0 if enemy == "archer" else (88.0 if enemy == "boss" else 74.0)
		if dist > reach:
			var speed := 34.0 if enemy == "archer" else (45.0 if enemy == "boss" else 56.0)
			if enemy != "archer" or dist > 150: enemy_pos.x += signf(dx) * speed * dt
		else:
			enemy_state = "telegraph"
			enemy_clock = 0.85 if enemy == "boss" else 0.68
		enemy_pos.x = clampf(enemy_pos.x, 24, 456)

func _enemy_strike() -> void:
	var reach := 140.0 if enemy == "archer" else (94.0 if enemy == "boss" else 78.0)
	if absf(player.x - enemy_pos.x) > reach or invuln > 0: return
	var dmg := 9 if enemy == "archer" else (15 if enemy == "boss" else 12)
	if guard and signf(enemy_pos.x - player.x) == float(facing): dmg = maxi(1, int(dmg * 0.25))
	hp = maxi(0, hp - dmg)
	flash = 0.18
	if hp <= 0: mode = Mode.LOSE

func _enemy_defeated() -> void:
	enemy_alive = false
	if enemy == "grunt":
		xp += 25
		gold += 8
		_spawn("archer")
	elif enemy == "archer":
		xp += 35
		gold += 12
		_spawn("boss")
	else:
		xp += 100
		gold += 40
		honor += 10
		boss_done = true
		_level_up()
		_save()
		mode = Mode.WIN
		message = "El sello ha sido purificado. La aldea está a salvo."

func _level_up() -> void:
	while xp >= level * 50:
		xp -= level * 50
		level += 1
		max_hp += 8
		hp = mini(max_hp, hp + 18)

func _interact() -> void:
	if area == Area.VILLAGE:
		if absf(player.x - 142) < 52:
			dialogue = "Mika · Haiku\nCampana sin voz\nla luna oye pasos\nno mires atrás"
			if not mika_spoken:
				honor += 1
				mika_spoken = true
				message = "Mika te entrega un talismán. Honor +1."
			else:
				dialogue = "Mika · Kōan\nSi el bosque guarda silencio,\n¿quién escucha tus pasos?"
		elif player.x > 398:
			area = Area.FOREST
			player.x = 36
			dialogue = ""
			_spawn("grunt")
			_save()
		else: message = "Acércate a Mika o a la salida oriental."
	else:
		message = "El camino se abrirá cuando derrotes a la Guardiana."

func _new_game() -> void:
	area = Area.VILLAGE
	player = Vector2(82, FLOOR)
	velocity = Vector2.ZERO
	hp = 100
	max_hp = 100
	xp = 0
	level = 1
	gold = 0
	honor = 0
	boss_done = false
	mika_spoken = false
	enemy_alive = false
	dialogue = "Akane · Kōan\nSi nadie abrió el sello,\n¿por qué mi espada recuerda\nla mano que la traicionó?"
	message = "Habla con Mika y cruza al bosque de bambú."
	mode = Mode.GAME
	_save()

func _save() -> void:
	var data := {"schema": 1, "area": int(area), "x": player.x, "hp": hp, "max_hp": max_hp, "xp": xp, "level": level, "gold": gold, "honor": honor, "boss_done": boss_done, "mika_spoken": mika_spoken}
	var f := FileAccess.open(SAVE + ".tmp", FileAccess.WRITE)
	if f == null: return
	f.store_string(JSON.stringify(data))
	f.close()
	var source := ProjectSettings.globalize_path(SAVE + ".tmp")
	var target := ProjectSettings.globalize_path(SAVE)
	var err := DirAccess.rename_absolute(source, target)
	if err == OK:
		save_exists = true
	else:
		push_error("No se pudo confirmar el guardado: %s" % error_string(err))

func _continue_game() -> void:
	if not save_exists:
		message = "Todavía no hay una partida guardada."
		return
	_load_save()
	if boss_done:
		mode = Mode.WIN
	else:
		mode = Mode.GAME
		if area == Area.FOREST:
			_spawn("grunt")

func _load_save() -> void:
	if not FileAccess.file_exists(SAVE): return
	save_exists = true
	var f := FileAccess.open(SAVE, FileAccess.READ)
	if f == null: return
	var d = JSON.parse_string(f.get_as_text())
	f.close()
	if not d is Dictionary or int(d.get("schema", 0)) != 1: return
	area = Area.FOREST if int(d.get("area", 0)) == 1 else Area.VILLAGE
	player.x = clampf(float(d.get("x", 82)), 18, 462)
	hp = clampi(int(d.get("hp", 100)), 1, 300)
	max_hp = clampi(int(d.get("max_hp", 100)), 1, 300)
	xp = maxi(0, int(d.get("xp", 0)))
	level = clampi(int(d.get("level", 1)), 1, 99)
	gold = maxi(0, int(d.get("gold", 0)))
	honor = clampi(int(d.get("honor", 0)), -100, 100)
	boss_done = bool(d.get("boss_done", false))
	mika_spoken = bool(d.get("mika_spoken", false))
	if boss_done: mode = Mode.WIN

func _draw() -> void:
	_draw_scene()
	if mode == Mode.TITLE:
		_draw_title()
	elif mode == Mode.GAME or mode == Mode.PAUSE or mode == Mode.WIN or mode == Mode.LOSE:
		_draw_actor(player, true)
		if enemy_alive: _draw_enemy()
		_draw_hud()
		_draw_controls()
		if mode == Mode.PAUSE: _overlay("PAUSA", "Esc / Enter para continuar")
		elif mode == Mode.WIN: _overlay("SELLO PURIFICADO", "La aldea está a salvo · Esc para volver")
		elif mode == Mode.LOSE: _overlay("DERROTA", "Akane volverá a intentarlo · Esc para volver")

func _draw_scene() -> void:
	if area == Area.VILLAGE:
		draw_rect(Rect2(0,0,W,H), Color("#182b35"))
		draw_rect(Rect2(0,112,W,158), Color("#344b3e"))
		_draw_moon()
		_draw_house(24,100)
		_draw_house(360,105)
		for x in range(0,480,42): _draw_tree(float(x),145)
	else:
		draw_rect(Rect2(0,0,W,H), Color("#101c2b"))
		draw_rect(Rect2(0,130,W,140), Color("#1b352e"))
		_draw_moon()
		for x in range(-8,500,38): _draw_bamboo(float(x))
		draw_rect(Rect2(220,168,42,42), Color("#493b4d"))
		draw_rect(Rect2(230,158,22,10), Color("#8b555b"))
	draw_rect(Rect2(0,FLOOR,W,H-FLOOR), Color("#514637"))
	for x in range(0,480,16): draw_rect(Rect2(x,FLOOR,8,2), Color("#716044"))

func _draw_moon() -> void:
	draw_rect(Rect2(395,39,14,14), Color("#e5d8a7"))
	draw_rect(Rect2(399,36,10,4), Color("#e5d8a7"))

func _draw_house(x: float,y: float) -> void:
	draw_rect(Rect2(x+12,y,54,58), Color("#b99a73"))
	draw_rect(Rect2(x+5,y-5,68,7), Color("#6e4641"))
	draw_rect(Rect2(x+22,y+26,8,32), Color("#3c2c2b"))
	draw_rect(Rect2(x+47,y+26,8,32), Color("#3c2c2b"))

func _draw_tree(x: float,y: float) -> void:
	draw_rect(Rect2(x+8,y+12,6,34), Color("#4a382f"))
	draw_rect(Rect2(x,y,22,18), Color("#345642"))
	draw_rect(Rect2(x+5,y-6,18,12), Color("#456a4d"))

func _draw_bamboo(x: float) -> void:
	draw_rect(Rect2(x+10,70,4,82), Color("#557b53"))
	draw_rect(Rect2(x+7,98,10,2), Color("#8eaa69"))
	draw_rect(Rect2(x+10,128,9,2), Color("#8eaa69"))
	draw_rect(Rect2(x-8,88,18,3), Color("#3e6548"))
	draw_rect(Rect2(x+12,112,18,3), Color("#3e6548"))

func _draw_actor(p: Vector2, is_player: bool) -> void:
	var x := roundf(p.x)
	var y := roundf(p.y)
	var torso := Color("#344b70") if is_player else Color("#6f9a83")
	if not is_player:
		if enemy == "archer": torso = Color("#8b82a6")
		elif enemy == "boss": torso = Color("#8f3e56")
	if is_player and flash > 0: torso = Color("#d66a64")
	if not is_player and flash > 0: torso = Color("#f0e1b9")
	var scale := 1.0 if is_player or enemy != "boss" else 1.5
	draw_rect(Rect2(x-8*scale,y-12*scale,7*scale,12*scale), Color("#272b39"))
	draw_rect(Rect2(x+2*scale,y-12*scale,7*scale,12*scale), Color("#272b39"))
	draw_rect(Rect2(x-10*scale,y-31*scale,20*scale,20*scale), torso)
	draw_rect(Rect2(x-7*scale,y-44*scale,14*scale,12*scale), Color("#e5bd9b"))
	draw_rect(Rect2(x-9*scale,y-48*scale,18*scale,5*scale), Color("#181a25"))
	if is_player:
		draw_rect(Rect2(x-11,y-47,5,3), Color("#b84c52"))
		var sx := x + (12 if facing > 0 else -22)
		draw_rect(Rect2(sx,y-27,18,2), Color("#d8d6c7"))
	else:
		draw_rect(Rect2(x-9*scale,y-52*scale,18*scale,3), Color("#bd9b59"))

func _draw_enemy() -> void:
	_draw_actor(enemy_pos, false)
	if enemy_state == "telegraph":
		draw_rect(Rect2(enemy_pos.x-17,enemy_pos.y-61,34,3), Color("#e4b65d"))

func _draw_hud() -> void:
	draw_rect(Rect2(6,6,164,39), Color(0.03,0.04,0.06,0.88))
	draw_string(ThemeDB.fallback_font,Vector2(12,17),"AKANE Lv.%d" % level,HORIZONTAL_ALIGNMENT_LEFT,150,9,Color("#f0dfbd"))
	draw_rect(Rect2(12,23,108,6),Color("#513b40"))
	draw_rect(Rect2(12,23,108.0*float(hp)/float(max_hp),6),Color("#b84c52"))
	draw_string(ThemeDB.fallback_font,Vector2(12,40),"XP %d  Oro %d" % [xp,gold],HORIZONTAL_ALIGNMENT_LEFT,150,8,Color("#d7bc7d"))
	if enemy_alive:
		var label := "YOKAI" if enemy == "grunt" else ("YUREI" if enemy == "archer" else "GUARDIANA DEL SELLO")
		draw_string(ThemeDB.fallback_font,Vector2(250,17),label,HORIZONTAL_ALIGNMENT_CENTER,220,8,Color("#f0dfbd"))
		draw_rect(Rect2(260,23,150,6),Color("#513b40"))
		draw_rect(Rect2(260,23,150.0*float(enemy_hp)/float(enemy_max),6),Color("#a83f55"))
	draw_rect(Rect2(6,238,468,26),Color(0.03,0.04,0.06,0.86))
	draw_string(ThemeDB.fallback_font,Vector2(12,250),message,HORIZONTAL_ALIGNMENT_LEFT,450,8,Color("#f0dfbd"))
	draw_string(ThemeDB.fallback_font,Vector2(12,261),"A/D mover · W saltar · J/K atacar · L esquivar · I cubrir · E interactuar",HORIZONTAL_ALIGNMENT_LEFT,450,7,Color("#c8c0ae"))
	if dialogue != "":
		draw_rect(Rect2(12,151,456,50),Color(0.03,0.04,0.06,0.94))
		var dialogue_lines := dialogue.split("\n")
		for i in range(dialogue_lines.size()):
			draw_string(ThemeDB.fallback_font,Vector2(20,165 + i * 10),dialogue_lines[i],HORIZONTAL_ALIGNMENT_LEFT,440,8,Color("#f0dfbd"))

func _draw_controls() -> void:
	_button(Rect2(8,204,48,28),"◀")
	_button(Rect2(62,204,48,28),"▶")
	_button(Rect2(220,204,58,28),"SAL")
	_button(Rect2(286,204,48,28),"DEF")
	_button(Rect2(338,204,48,28),"DOD")
	_button(Rect2(390,204,40,28),"J")
	_button(Rect2(434,204,38,28),"K")
	_button(Rect2(438,170,34,26),"E")
	_button(Rect2(438,8,34,24),"II")

func _button(r: Rect2,label: String) -> void:
	draw_rect(r,Color(0.08,0.10,0.13,0.74))
	draw_rect(Rect2(r.position,Vector2(r.size.x,2)),Color("#a88b5a"))
	draw_string(ThemeDB.fallback_font,Vector2(r.position.x+2,r.position.y+17),label,HORIZONTAL_ALIGNMENT_CENTER,r.size.x-4,8,Color("#f2e5c8"))

func _draw_title() -> void:
	draw_rect(Rect2(0,0,W,H),Color(0.02,0.03,0.06,0.68))
	draw_string(ThemeDB.fallback_font,Vector2(44,76),"RONIN",HORIZONTAL_ALIGNMENT_LEFT,390,30,Color("#f1dfb4"))
	draw_string(ThemeDB.fallback_font,Vector2(46,99),"SHADOW DOJO",HORIZONTAL_ALIGNMENT_LEFT,390,16,Color("#c45b61"))
	draw_string(ThemeDB.fallback_font,Vector2(46,132),"Una espada. Dos mundos. Ningun camino sin precio.",HORIZONTAL_ALIGNMENT_LEFT,390,9,Color("#e1d4b8"))
	draw_rect(Rect2(72,164,156,34),Color("#6e353e"))
	draw_string(ThemeDB.fallback_font,Vector2(88,186),"ENTER: NUEVA PARTIDA",HORIZONTAL_ALIGNMENT_LEFT,132,8,Color("#fff0d1"))
	draw_rect(Rect2(252,164,156,34),Color("#405c56"))
	draw_string(ThemeDB.fallback_font,Vector2(269,186),"C: CONTINUAR",HORIZONTAL_ALIGNMENT_LEFT,132,8,Color("#fff0d1"))
	draw_string(ThemeDB.fallback_font,Vector2(12,258),"RONIN RPG · PROTOTIPO DE COMBATE",HORIZONTAL_ALIGNMENT_LEFT,456,7,Color("#b9b1a1"))

func _overlay(title: String,subtitle: String) -> void:
	draw_rect(Rect2(62,83,356,102),Color(0.02,0.03,0.05,0.94))
	draw_rect(Rect2(62,83,356,3),Color("#b28b59"))
	draw_string(ThemeDB.fallback_font,Vector2(82,122),title,HORIZONTAL_ALIGNMENT_CENTER,316,17,Color("#f0dfbd"))
	draw_string(ThemeDB.fallback_font,Vector2(82,151),subtitle,HORIZONTAL_ALIGNMENT_CENTER,316,9,Color("#d4bd8d"))
