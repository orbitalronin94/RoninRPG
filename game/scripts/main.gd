extends Node2D
## Prototipo inicial: movimiento, diálogo con O-Ren y sistema de Honor.

const SPEED := 190.0
var player_position := Vector2(480, 280)
var honor := 50
var coins := 50
var lodging_obtained := false
var well_investigated := false
var dialogue_open := true
var dialogue_index := 0
var lines: Array[String] = [
	"O-Ren: ¿Cuarto? Sí, hay uno. Pago por adelantado. No fío a forasteros con espada.",
	"Kagetora: No tengo monedas. Tengo una espada.",
	"O-Ren: Una espada no llena el estómago. Hay un establo que necesita limpieza. Dos horas. Te doy el cuarto y una sopa."
]
var status := "Objetivo: consigue alojamiento en El Sauce Llorón."

func _process(delta: float) -> void:
	if not dialogue_open:
		player_position += Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * SPEED * delta
		player_position.x = clampf(player_position.x, 24.0, 936.0)
		player_position.y = clampf(player_position.y, 105.0, 430.0)
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if dialogue_open:
			dialogue_index += 1
			if dialogue_index >= lines.size():
				dialogue_open = false
				status = "Pulsa E cerca de O-Ren para ayudarla."
		queue_redraw()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		interact()

func interact() -> void:
	if dialogue_open:
		return
	if not lodging_obtained and player_position.distance_to(Vector2(480, 190)) < 140:
		lodging_obtained = true
		honor = clampi(honor + 5, 0, 100)
		status = "Alojamiento conseguido. Honor +5. Investiga el pozo azul."
	elif lodging_obtained and not well_investigated and player_position.distance_to(Vector2(810, 330)) < 85:
		well_investigated = true
		status = "El agua tiene un brillo extraño. Has encontrado indicios de mercurio."
	else:
		status = "Acércate a la posadera o al pozo y pulsa E."

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(960, 540)), Color("#263b32"))
	draw_rect(Rect2(0, 180, 960, 180), Color("#8c7958"))
	for x in range(0, 960, 48):
		draw_line(Vector2(x, 180), Vector2(x, 360), Color("#9b8968"), 1.0)
	for y in range(180, 360, 32):
		draw_line(Vector2(0, y), Vector2(960, y), Color("#9b8968"), 1.0)
	# Posada y tejado
	draw_rect(Rect2(385, 105, 190, 110), Color("#d1b58b"))
	draw_colored_polygon(PackedVector2Array([Vector2(365,112), Vector2(480,45), Vector2(595,112)]), Color("#633c32"))
	draw_rect(Rect2(452,153,56,62), Color("#49362d"))
	draw_string(ThemeDB.fallback_font, Vector2(400,98), "EL SAUCE LLORÓN", HORIZONTAL_ALIGNMENT_LEFT, 170, 13, Color("#f6e6c5"))
	# Pozo y sauce
	draw_circle(Vector2(810,330),37,Color("#b4a38a"))
	draw_circle(Vector2(810,330),24,Color("#3e7e89"))
	draw_rect(Rect2(155,95,18,120),Color("#514333"))
	draw_circle(Vector2(163,86),52,Color("#476c4d"))
	draw_circle(Vector2(126,105),30,Color("#476c4d"))
	draw_circle(Vector2(197,105),32,Color("#476c4d"))
	# O-Ren y Kagetora
	draw_circle(Vector2(480,190),12,Color("#c5a083"))
	draw_rect(Rect2(469,201,22,28),Color("#637c99"))
	draw_circle(player_position + Vector2(0,-10),9,Color("#e0b18f"))
	draw_rect(Rect2(player_position + Vector2(-8,0),Vector2(16,24)),Color("#354c70"))
	draw_line(player_position + Vector2(8,8),player_position + Vector2(21,0),Color("#d8d8d0"),3)
	# HUD y diálogo
	draw_rect(Rect2(14,12,350,72),Color(0.04,0.05,0.05,0.82))
	draw_string(ThemeDB.fallback_font,Vector2(28,35),"KAGETORA | HP 100 | KI 50",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("#f0e5ce"))
	draw_string(ThemeDB.fallback_font,Vector2(28,61),"HONOR %d/100 · MONEDAS %d" % [honor,coins],HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("#e4c77b"))
	draw_rect(Rect2(14,445,932,80),Color(0.04,0.05,0.05,0.9))
	draw_string(ThemeDB.fallback_font,Vector2(30,470),status,HORIZONTAL_ALIGNMENT_LEFT,895,17,Color("#f0e5ce"))
	draw_string(ThemeDB.fallback_font,Vector2(30,500),"WASD/Flechas: moverse · E: interactuar · Espacio/Enter: continuar",HORIZONTAL_ALIGNMENT_LEFT,895,14,Color("#b9c6bd"))
	if dialogue_open:
		draw_rect(Rect2(24,335,912,98),Color(0.06,0.07,0.08,0.96))
		draw_string(ThemeDB.fallback_font,Vector2(44,365),lines[clampi(dialogue_index,0,lines.size()-1)],HORIZONTAL_ALIGNMENT_LEFT,870,17,Color("#f0e5ce"))
		draw_string(ThemeDB.fallback_font,Vector2(44,405),"Espacio / Enter para continuar",HORIZONTAL_ALIGNMENT_LEFT,870,14,Color("#e4c77b"))
