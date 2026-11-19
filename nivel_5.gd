extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var r1: Button = $"Respuesta 1"
@onready var r2: Button = $"Respuesta 2"
@onready var r3: Button = $"Respuesta 3"

var pregunta_numero = 0
var respuesta = 0
var correctas = 0
var total_preguntas = 13

var indice_correcta_actual = 0
var respuesta_registrada := false

func _ready():
	var guardado := Partidas.obtener_actividad(5)
	pregunta_numero = clampi(int(guardado.get("pregunta", 0)), 0, total_preguntas)
	correctas = clampi(int(guardado.get("correctas", 0)), 0, pregunta_numero)
	$AudioStreamPlayer2D.play()
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.modulate = Color(1,1,1,0)
	$Siguiente.visible = false

	# Texto siempre blanco
	r1.self_modulate = Color(1,1,1)
	r2.self_modulate = Color(1,1,1)
	r3.self_modulate = Color(1,1,1)

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

	var preguntas = [
		"¿Cómo se llamaba la llama que Lumi encontró al inicio de la historia?",
		"¿Qué tenía Luna en su cuello?",
		"¿Por qué Lumi ayudó a Luna?",
		"¿Quién ayudó a Lumi a cruzar el río?",
		"¿Cómo creó Lumi un puente sobre el río?",
		"¿Dónde encontró Lumi las bayas mágicas?",
		"¿Qué le enseñó Tilo la Tortuga a Lumi?",
		"¿Cómo se reveló la verdadera apariencia de Lumi?",
		"¿Qué personaje tenía alas brillantes?",
		"¿Qué celebraban los personajes en la Cascada Brillante?",
		"¿Qué hace especial a Lumi en la historia?",
		"¿Por qué es importante ser uno mismo?",
		"¿Qué mensaje nos deja la historia de Lumi?"
	]

	var opciones = [
		["Lila", "Luna", "Luma"],
		["Collar de estrellas", "Listón dorado", "Amuleto mágico"],
		["Porque quería encontrar su camino", "Porque se mezclaron las letras", "Porque Luna perdió su collar"],
		["Tilo la tortuga", "Mia la mariposa", "Bruno el búho"],
		["Construyendo un barco", "Formando palabras mágicas", "Saltando sobre las piedras"],
		["En el Bosque Brillante", "En la Cueva de Colores", "En la Pradera Mágica"],
		["A tener paciencia", "A correr rápido", "A encontrar más bayas"],
		["Con el reflejo del sol", "Con la lluvia", "Con un hechizo de Nico"],
		["Mia la mariposa", "Bruno el búho", "Nico el zorro"],
		["La llegada del invierno", "Que Lumi era especial tal como es", "La fiesta de Luna"],
		["Sus colores únicos", "Su velocidad", "Su fuerza"],
		["Porque cada persona es especial y única", "Para ser igual a los demás", "Porque es una regla del bosque"],
		["Que debemos aceptarnos y valorar lo que nos hace únicos", "Que siempre debemos cambiar para encajar", "Que ser diferentes nos hace menos importantes"]
	]

	var correctas_indices = [
		2, # Luna
		1, # Listón dorado
		2, # Luna perdió el collar
		3, # Bruno
		2, # Palabras mágicas
		2, # Cueva de colores
		1, # Paciencia
		2, # Reflejo del sol
		1, # Mia la mariposa
		2, # Lumi es especial tal como es
		1, # Sus colores únicos
		1, # Cada persona es única
		1  # Aceptarnos y valorarnos
	]

	$Pregunta.text = preguntas[pregunta_numero]

	var opciones_originales = opciones[pregunta_numero]
	var indice_correcta_original = correctas_indices[pregunta_numero] - 1
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
