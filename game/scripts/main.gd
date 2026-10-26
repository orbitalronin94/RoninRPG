extends Node2D
## Prototipo jugable: movimiento, diálogos contextuales y decisiones persistentes en memoria.
## Los sistemas narrativos se mantienen deterministas; no hay backend LLM conectado todavía.

const SPEED := 190.0
const OREN_POS := Vector2(480, 190)
const WELL_POS := Vector2(810, 330)
const YASUKE_POS := Vector2(700, 190)
const KIYOHIME_POS := Vector2(600, 300)

var player_position := Vector2(480, 280)
var hp := 100
var ki := 50
var honor := 50
var coins := 50
var lodging_obtained := false
var well_investigated := false
var story_node := 1
var choice_mode := false
var dialogue_open := true
var dialogue_index := 0
var lines: Array[String] = [
	"O-Ren: ¿Cuarto? Sí. Pago por adelantado. No fío a forasteros con espada.",
	"Kagetora: No tengo monedas. Tengo una espada.",
	"O-Ren: Una espada no llena el estómago. Limpia el establo y tendrás una sopa."
]
var status := "Objetivo: consigue alojamiento en El Sauce Llorón."
var faction_values := {
	"orden": 70,
	"riqueza": 50,
	"memoria": 30,
	"fe": 40,
	"artesania": 25,
	"carbon": 25,
	"pesca": 25
}
var decisions: Array[String] = []

func _ready() -> void:
	_load_progress()

func _process(delta: float) -> void:
	if not dialogue_open:
		player_position += Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * SPEED * delta
		player_position.x = clampf(player_position.x, 24.0, 936.0)
		player_position.y = clampf(player_position.y, 105.0, 430.0)
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	if choice_mode:
		if event.is_action("ui_accept") and dialogue_index < lines.size() - 1:
			dialogue_index += 1
		elif dialogue_index >= lines.size() - 1 and event.keycode == KEY_1:
			_resolve_choice(1)
		elif dialogue_index >= lines.size() - 1 and event.keycode == KEY_2:
			_resolve_choice(2)
		elif dialogue_index >= lines.size() - 1 and event.keycode == KEY_3:
			_resolve_choice(3)
		queue_redraw()
		return
	if event.is_action("ui_accept"):
		if dialogue_open:
			if dialogue_index < lines.size() - 1:
				dialogue_index += 1
			else:
				dialogue_open = false
				status = "Explora la aldea. Acércate a los personajes y pulsa E."
		queue_redraw()
	elif event.keycode == KEY_E:
		interact()

func _show_dialogue(new_lines: Array[String], choices := false) -> void:
	lines = new_lines
	dialogue_index = 0
	dialogue_open = true
	choice_mode = choices
	queue_redraw()

func _resolve_choice(choice: int) -> void:
	choice_mode = false
	dialogue_open = false
	if story_node == 2 and well_investigated:
		if choice == 1:
			_adjust_faction("orden", 10)
			_adjust_faction("memoria", -10)
			decisions.append("pozo:informar_clan")
			status = "Informaste al clan. Orden +10, Memoria -10."
		else:
			_adjust_faction("memoria", 10)
			_adjust_faction("orden", -10)
			decisions.append("pozo:informar_aldeanos")
			status = "Avisaste a los aldeanos. Memoria +10, Orden -10."
		story_node = 3
	elif story_node == 3:
		if choice == 1:
			_adjust_faction("fe", 5)
			_adjust_faction("riqueza", -5)
			decisions.append("carta:respetar_secreto")
			status = "No abriste la carta. Fe +5, Riqueza -5."
		else:
			_adjust_faction("riqueza", 5)
			_adjust_faction("fe", -5)
			decisions.append("carta:abrir")
			status = "Abriste la carta: Yasuke chantajea al clan. Riqueza +5, Fe -5."
		story_node = 4
	elif story_node >= 4:
		if choice == 1:
			_adjust_faction("fe", 5)
			decisions.append("kiyohime:preguntar_santuario")
			status = "Kiyohime habla de los sueños de un niño junto a un campo de arroz. Fe +5."
		else:
			decisions.append("kiyohime:guardar_silencio")
			status = "Kiyohime guarda silencio. Algunas verdades necesitan tiempo."
	_save_progress()
	queue_redraw()

func _save_progress() -> void:
	var state := {
		"schema_version": 1,
		"current_node": "nodo_%d" % story_node,
		"honor": honor,
		"coins": coins,
		"faction_reputation": faction_values,
		"lodging_obtained": lodging_obtained,
		"well_investigated": well_investigated,
		"decisions": decisions
	}
	var file := FileAccess.open("user://decisions.json", FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(state, "\\t"))
		file.close()

func _load_progress() -> void:
	if not FileAccess.file_exists("user://decisions.json"):
		return
	var file := FileAccess.open("user://decisions.json", FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	honor = clampi(int(parsed.get("honor", honor)), 0, 100)
	coins = maxi(0, int(parsed.get("coins", coins)))
	story_node = clampi(int(str(parsed.get("current_node", "nodo_1")).trim_prefix("nodo_")), 1, 12)
	lodging_obtained = bool(parsed.get("lodging_obtained", false))
	well_investigated = bool(parsed.get("well_investigated", false))
	var saved_factions = parsed.get("faction_reputation", {})
	if saved_factions is Dictionary:
		for key in saved_factions:
			if faction_values.has(key):
				faction_values[key] = clampi(int(saved_factions[key]), 0, 100)
	var saved_decisions = parsed.get("decisions", [])
	if saved_decisions is Array:
		for item in saved_decisions:
			decisions.append(str(item))
	status = "Partida cargada. Nodo %d · Honor %d." % [story_node, honor]

func _adjust_faction(key: String, amount: int) -> void:
	faction_values[key] = clampi(int(faction_values.get(key, 0)) + amount, 0, 100)

func interact() -> void:
	if dialogue_open:
		return
	if not lodging_obtained and player_position.distance_to(OREN_POS) < 140:
		lodging_obtained = true
		honor = clampi(honor + 5, 0, 100)
		coins = maxi(0, coins - 10)
		story_node = 2
		decisions.append("oren:alojamiento_conseguido")
		status = "Alojamiento conseguido. Honor +5. Investiga el pozo azul."
		_show_dialogue([
			"O-Ren: La habitación es tuya por esta noche. No confundas necesidad con amistad.",
			"Kagetora: No suelo confundirlas.",
			"O-Ren: Entonces investiga el pozo. El agua sabe a metal y nadie escucha a los aldeanos."
		])
	elif lodging_obtained and not well_investigated and player_position.distance_to(WELL_POS) < 85:
		well_investigated = true
		story_node = 2
		status = "El agua tiene un brillo extraño. Decide a quién informar."
		_show_dialogue([
			"Kagetora: El agua brilla. No es barro. Huele a las minas.",
			"Aldeano: El clan desvió el río. Ahora el pozo nos devuelve veneno.",
			"¿A quién informar? 1: al clan (Orden+) · 2: a los aldeanos (Memoria+)"
		], true)
	elif story_node >= 3 and player_position.distance_to(YASUKE_POS) < 100:
		_show_dialogue([
			"Yasuke: Una carta sellada para Kiyohime. No la abras. En Kanegawa el silencio vale más que el arroz.",
			"Kagetora: ¿Y qué compras con tanto silencio?",
			"¿Qué haces? 1: respetar el secreto (Fe+) · 2: abrir la carta (Riqueza+)"
		], true)
	elif story_node >= 4 and player_position.distance_to(KIYOHIME_POS) < 100:
		var line := "Kiyohime: El agua no recuerda a quién ha limpiado. Solo fluye."
		if honor >= 60:
			line = "Kiyohime: Has venido con polvo en las sandalias y ceniza en el corazón. ¿Qué buscas?"
		elif honor < 30:
			line = "Kiyohime: No todos los caminos llevan a la purificación. Algunos solo enseñan el peso de los pasos."
		_show_dialogue([
			line,
			"Kagetora: ¿Has soñado con un niño junto al río?",
			"1: preguntar por el santuario (Fe+) · 2: no insistir"
		], true)
	elif lodging_obtained and not well_investigated:
		status = "Acércate al pozo azul y pulsa E."
	else:
		status = "Acércate a O-Ren, al pozo, a Yasuke o a Kiyohime y pulsa E."

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(960, 540)), Color("#263b32"))
	draw_rect(Rect2(0, 180, 960, 180), Color("#8c7958"))
	for x in range(0, 960, 48):
		draw_line(Vector2(x, 180), Vector2(x, 360), Color("#9b8968"), 1.0)
	for y in range(180, 360, 32):
		draw_line(Vector2(0, y), Vector2(960, y), Color("#9b8968"), 1.0)
	# Posada
	draw_rect(Rect2(385, 105, 190, 110), Color("#d1b58b"))
	draw_colored_polygon(PackedVector2Array([Vector2(365,112), Vector2(480,45), Vector2(595,112)]), Color("#633c32"))
	draw_rect(Rect2(452,153,56,62), Color("#49362d"))
	draw_string(ThemeDB.fallback_font, Vector2(400,98), "EL SAUCE LLORÓN", HORIZONTAL_ALIGNMENT_LEFT, 170, 13, Color("#f6e6c5"))
	# Sauce y pozo
	draw_rect(Rect2(155,95,18,120),Color("#514333"))
	draw_circle(Vector2(163,86),52,Color("#476c4d"))
	draw_circle(Vector2(126,105),30,Color("#476c4d"))
	draw_circle(Vector2(197,105),32,Color("#476c4d"))
	draw_circle(WELL_POS,37,Color("#b4a38a"))
	draw_circle(WELL_POS,24,Color("#3e7e89"))
	# NPCs: O-Ren, Yasuke y Kiyohime
	_draw_person(OREN_POS, Color("#637c50"))
	_draw_person(YASUKE_POS, Color("#887257"))
	_draw_person(KIYOHIME_POS, Color("#f0e9d8"), Color("#a93232"))
	# Kagetora
	draw_circle(player_position + Vector2(0,-10),9,Color("#e0b18f"))
	draw_rect(Rect2(player_position + Vector2(-8,0),Vector2(16,24)),Color("#354c70"))
	draw_line(player_position + Vector2(8,8),player_position + Vector2(21,0),Color("#d8d8d0"),3)
	# HUD
	draw_rect(Rect2(14,12,420,96),Color(0.04,0.05,0.05,0.86))
	draw_string(ThemeDB.fallback_font,Vector2(28,35),"KAGETORA | HP %d | KI %d | NODO %d" % [hp,ki,story_node],HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("#f0e5ce"))
	draw_string(ThemeDB.fallback_font,Vector2(28,61),"HONOR %d/100 · MONEDAS %d" % [honor,coins],HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("#e4c77b"))
	draw_string(ThemeDB.fallback_font,Vector2(28,87),"ORDEN %d · MEMORIA %d · FE %d" % [faction_values["orden"],faction_values["memoria"],faction_values["fe"]],HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("#b9c6bd"))
	draw_rect(Rect2(14,445,932,80),Color(0.04,0.05,0.05,0.9))
	draw_string(ThemeDB.fallback_font,Vector2(30,470),status,HORIZONTAL_ALIGNMENT_LEFT,895,16,Color("#f0e5ce"))
	draw_string(ThemeDB.fallback_font,Vector2(30,500),"WASD/Flechas: moverse · E: interactuar · Espacio/Enter: continuar",HORIZONTAL_ALIGNMENT_LEFT,895,14,Color("#b9c6bd"))
	if dialogue_open:
		draw_rect(Rect2(24,335,912,98),Color(0.06,0.07,0.08,0.97))
		draw_string(ThemeDB.fallback_font,Vector2(44,365),lines[clampi(dialogue_index,0,lines.size()-1)],HORIZONTAL_ALIGNMENT_LEFT,870,16,Color("#f0e5ce"))
		if choice_mode:
			draw_string(ThemeDB.fallback_font,Vector2(44,405),"Pulsa 1, 2 o 3 para elegir.",HORIZONTAL_ALIGNMENT_LEFT,870,14,Color("#e4c77b"))
		else:
			draw_string(ThemeDB.fallback_font,Vector2(44,405),"Espacio / Enter para continuar",HORIZONTAL_ALIGNMENT_LEFT,870,14,Color("#e4c77b"))

func _draw_person(pos: Vector2, robe: Color, accent: Color = Color(0.28, 0.22, 0.18)) -> void:
	draw_circle(pos, 10, Color("#c5a083"))
	draw_rect(Rect2(pos + Vector2(-11, 10), Vector2(22, 29)), robe)
	draw_rect(Rect2(pos + Vector2(-11, 29), Vector2(22, 5)), accent)
