extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var r1: Button = $"Respuesta 1"
@onready var r2: Button = $"Respuesta 2"
@onready var r3: Button = $"Respuesta 3"

var pregunta_numero = 0
var respuesta = 0
var correctas = 0
@export var preguntas: Array[PreguntaLumi] = []
var total_preguntas: int:
	get:
		return preguntas.size()

var indice_correcta_actual = 0
var respuesta_registrada := false

func _ready():
	var guardado := Partidas.obtener_actividad(5)
	pregunta_numero = clampi(int(guardado.get("pregunta", 0)), 0, total_preguntas)
	correctas = clampi(int(guardado.get("correctas", 0)), 0, pregunta_numero)
	$AudioStreamPlayer2D.play()
	color_rect.modulate = Color(1,1,1,0)
	$Siguiente.visible = false

	preguntar()


func preguntar():
	respuesta_registrada = false
	for boton in [r1, r2, r3]:
		boton.disabled = false
	$Siguiente.visible = false
	color_rect.modulate = Color(1,1,1,0)

	# Restaurar botones
	r1.visible = true
	r2.visible = true
	r3.visible = true

	r1.modulate = Color(1,1,1,1)
	r2.modulate = Color(1,1,1,1)
	r3.modulate = Color(1,1,1,1)

	if pregunta_numero >= total_preguntas:
		Partidas.guardar_actividad(5, {"pregunta": pregunta_numero, "correctas": correctas})
		Partidas.guardar_punto("res://resultados.tscn")
		get_tree().change_scene_to_file("res://resultados.tscn")
		return

	$Pregunta.text = preguntas[pregunta_numero].texto

	var opciones_originales = preguntas[pregunta_numero].opciones
	var indice_correcta_original = preguntas[pregunta_numero].correcta - 1
	var correcta_texto = opciones_originales[indice_correcta_original]

	var opciones_mezcladas = opciones_originales.duplicate()
	opciones_mezcladas.shuffle()

	r1.text = opciones_mezcladas[0]
	r2.text = opciones_mezcladas[1]
	r3.text = opciones_mezcladas[2]

	indice_correcta_actual = opciones_mezcladas.find(correcta_texto) + 1


func responder():
	if respuesta_registrada:
		return
	respuesta_registrada = true
	for boton in [r1, r2, r3]:
		boton.disabled = true
	var correcta = (respuesta == indice_correcta_actual)

	var boton_presionado = null
	if respuesta == 1: boton_presionado = r1
	if respuesta == 2: boton_presionado = r2
	if respuesta == 3: boton_presionado = r3

	# Ocultar los otros dos botones
	var otros = []
	if boton_presionado == r1:
		otros = [r2, r3]
	elif boton_presionado == r2:
		otros = [r1, r3]
	else:
		otros = [r1, r2]

	for b in otros:
		var tw = get_tree().create_tween()
		tw.tween_property(b, "modulate:a", 0.0, 0.25)
		tw.tween_property(b, "visible", false, 0.0)

	# Tween del botón elegido
	var t = get_tree().create_tween()

	if correcta:
		correctas += 1
		t.tween_property(boton_presionado, "modulate", Color(0,1,0), 0.3)
		$correcct.play()
	else:
		t.tween_property(boton_presionado, "modulate", Color(1,0,0), 0.3)
		$recchazo.play()

	Partidas.guardar_actividad(5, {"pregunta": pregunta_numero + 1, "correctas": correctas})
	flash(Color(0,1,0) if correcta else Color(1,0,0))

	$Siguiente.visible = true


func flash(c: Color):
	color_rect.modulate = Color(c.r, c.g, c.b, 0)

	var t = get_tree().create_tween()
	t.tween_property(color_rect, "modulate:a", 0.6, 0.5).set_trans(Tween.TRANS_SINE)
	t.tween_property(color_rect, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE)


func _on_respuesta_1_pressed():
	respuesta = 1
	responder()

func _on_respuesta_2_pressed():
	respuesta = 2
	responder()

func _on_respuesta_3_pressed():
	respuesta = 3
	responder()

func _on_siguiente_pressed():
	if not respuesta_registrada:
		return
	pregunta_numero += 1
	preguntar()



func _on_cerrar_pressed() -> void:
	get_tree().quit()


func _on_minimizar_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
