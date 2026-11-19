@tool
extends CanvasLayer

## Sólo cambia la vista del editor; al jugar se mantiene la secuencia de memoria.
@export_enum("Memoria", "Pregunta", "Respuesta") var vista_editor: int = 0:
	set(valor):
		vista_editor = valor
		if Engine.is_editor_hint() and is_node_ready():
			_mostrar_vista_editor()

@onready var contenedor_memoria = $ContenedorMemoria
@onready var palabra_mostrar = $ContenedorMemoria/PalabraMostrar
@onready var imagen_mostrar = $ContenedorMemoria/ImagenMostrar
@onready var contenedor_pregunta = $ContenedorPregunta
@onready var pregunta_label = $ContenedorPregunta/PreguntaLabel
@onready var palabra_pregunta = $ContenedorPregunta/PalabraPregunta
@onready var hbox_botones = $HBoxContainer
@onready var boton_verdadero = $HBoxContainer/BotonVerdadero
@onready var boton_falso = $HBoxContainer/BotonFalso
@onready var boton_siguiente = $Siguiente
@onready var retro = $Retroalimentación
@onready var timer_memoria = $TimerMemoria
@onready var color_fondo = $ColorRect

@export var palabras: Array[String] = []

var indice_imagen = 0

@export var imagenes: Dictionary[String, Texture2D] = {}

var palabra_actual = ""
var pregunta_mostrada = ""
var es_verdadera = true

var rondas = 0
@export_range(1, 20) var max_rondas: int = 15

# >>> CONTADOR DE CORRECTAS <<<
var correctas = 0
var respuesta_registrada := false


func _ready():
	if Engine.is_editor_hint():
		_mostrar_vista_editor()
		return
	var guardado: Dictionary = Partidas.obtener_actividad(3)
	rondas = clampi(int(guardado.get("rondas", 0)), 0, max_rondas)
	correctas = clampi(int(guardado.get("correctas", 0)), 0, rondas)
	indice_imagen = clampi(int(guardado.get("indice_imagen", 0)), 0, palabras.size())
	$AudioStreamPlayer2D.play()


	contenedor_memoria.visible = true
	imagen_mostrar.visible = true
	contenedor_pregunta.visible = false
	hbox_botones.visible = false
	boton_siguiente.visible = false
	retro.visible = false

	color_fondo.visible = false
	color_fondo.color = Color(1, 1, 1, 0)


	iniciar_nueva_ronda()


func _mostrar_vista_editor() -> void:
	contenedor_memoria.visible = vista_editor == 0
	imagen_mostrar.visible = true
	contenedor_pregunta.visible = vista_editor == 1
	hbox_botones.visible = vista_editor == 1
	boton_siguiente.visible = vista_editor == 2
	retro.visible = vista_editor == 2
	color_fondo.visible = false


func iniciar_nueva_ronda():
	respuesta_registrada = false
	if indice_imagen >= palabras.size() or rondas >= max_rondas:
		cambiar_a_resultados()
		return

	pregunta_mostrada = ""
	retro.visible = false
	boton_siguiente.visible = false

	color_fondo.visible = false
	color_fondo.color = Color(1, 1, 1, 0)

	palabra_actual = palabras[indice_imagen]
	indice_imagen += 1

	imagen_mostrar.texture = imagenes[palabra_actual]
	imagen_mostrar.visible = true

	contenedor_memoria.visible = true
	contenedor_pregunta.visible = false
	hbox_botones.visible = false

	boton_verdadero.disabled = true
	boton_falso.disabled = true

	timer_memoria.start()


func _on_TimerMemoria_timeout():
	contenedor_memoria.visible = false
	generar_pregunta()

	contenedor_pregunta.visible = true
	hbox_botones.visible = true

	boton_verdadero.disabled = false
	boton_falso.disabled = false


func generar_pregunta():
	if pregunta_mostrada != "":
		return

	es_verdadera = randi_range(0, 1) == 0

	if es_verdadera:
		pregunta_mostrada = palabra_actual
	else:
		var otras = palabras.filter(func(p): return p != palabra_actual)
		pregunta_mostrada = otras.pick_random()

	if pregunta_mostrada == palabra_actual:
		es_verdadera = true

	pregunta_label.text = "¿Viste esto?"
	palabra_pregunta.text = pregunta_mostrada


func _on_respuesta(valor_usuario: bool):
	if respuesta_registrada:
		return
	respuesta_registrada = true
	boton_verdadero.disabled = true
	boton_falso.disabled = true

	hbox_botones.visible = false

	retro.visible = true
	boton_siguiente.visible = true

	color_fondo.visible = true
	color_fondo.color = Color(1, 1, 1, 0)

	var tween = get_tree().create_tween()

	if valor_usuario == es_verdadera:
		correctas += 1  # <<< CONTADOR DE CORRECTAS >>>
		retro.text = "¡Muy bien!"
		$correcct.play()
		tween.tween_property(color_fondo, "color", Color(0, 1, 0, 0.7), 0.1)
	else:
		retro.text = "Está bien, vamos a intentar otra."
		$recchazo.play()
		tween.tween_property(color_fondo, "color", Color(1, 0, 0, 0.7), 0.1)

	Partidas.guardar_actividad(3, {"rondas": rondas + 1, "correctas": correctas, "indice_imagen": indice_imagen})
	tween.tween_interval(0.5)
	tween.tween_property(color_fondo, "color", Color(1, 1, 1, 0), 0.1)


func _on_siguiente():
	if not respuesta_registrada:
		return
	rondas += 1

	if rondas >= max_rondas:
		cambiar_a_resultados()
	else:
		iniciar_nueva_ronda()


# >>> INSTANCIAR ESCENA DE RESULTADOS RECICLADA <<<
func cambiar_a_resultados():
	Partidas.guardar_actividad(3, {"rondas": rondas, "correctas": correctas, "indice_imagen": indice_imagen})
	Partidas.guardar_punto("res://resultados_2.tscn")
	get_tree().change_scene_to_file("res://resultados_2.tscn")


func _on_cerrar_pressed() -> void:
	get_tree().quit()


func _on_minimizar_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
