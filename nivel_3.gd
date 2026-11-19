extends CanvasLayer

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

var palabras = [
	"NIDO", "TAPA", "BOTE", "SILLA", "ABANICO", 
	"TELEVISION", "CHOCOLATE", "FERROCARRIL", "JIRAFA", "BICICLETA",
	"NIÑO", "LAPIZ", "TIJERA", "BOTA", "RUEDA", 
	"AUTO", "FOCO", "TELEFONO", "TAZA", "LIBRO"
]

var indice_imagen = 0

var imagenes = {
	"NIDO": preload("res://Img/NIDO.png"),
	"TAPA": preload("res://Img/TAPA.png"),
	"BOTE": preload("res://Img/BOTE.png"),
	"SILLA": preload("res://Img/SILLA.png"),
	"ABANICO": preload("res://Img/ABANICO.png"),
	"TELEVISION": preload("res://Img/TELEVISION.png"),
	"CHOCOLATE": preload("res://Img/CHOCOLATE.png"),
	"FERROCARRIL": preload("res://Img/FERROCARRIL.png"),
	"JIRAFA": preload("res://Img/JIRAFA.png"),
	"BICICLETA": preload("res://Img/BICICLETA.png"),
	"NIÑO": preload("res://Img/NINO.png"),
	"LAPIZ": preload("res://Img/LAPIZ.png"),
	"TIJERA": preload("res://Img/TIJERA.png"),
	"BOTA": preload("res://Img/BOTA.png"),
	"RUEDA": preload("res://Img/RUEDA.png"),
	"AUTO": preload("res://Img/AUTO.png"),
	"FOCO": preload("res://Img/FOCO.png"),
	"TELEFONO": preload("res://Img/TELEFONO.png"),
	"TAZA": preload("res://Img/TAZA.png"),
	"LIBRO": preload("res://Img/LIBRO.png")
}

var palabra_actual = ""
var pregunta_mostrada = ""
var es_verdadera = true

var rondas = 0
var max_rondas = 15

# >>> CONTADOR DE CORRECTAS <<<
var correctas = 0


func _ready():
	$AudioStreamPlayer2D.play()

	timer_memoria.timeout.connect(_on_TimerMemoria_timeout)

	contenedor_memoria.visible = true
	imagen_mostrar.visible = true
	contenedor_pregunta.visible = false
	hbox_botones.visible = false
	boton_siguiente.visible = false
	retro.visible = false

	color_fondo.visible = false
	color_fondo.color = Color(1, 1, 1, 0)

	boton_verdadero.pressed.connect(_on_respuesta.bind(true))
	boton_falso.pressed.connect(_on_respuesta.bind(false))
	boton_siguiente.pressed.connect(_on_siguiente)

	iniciar_nueva_ronda()


func iniciar_nueva_ronda():
	if indice_imagen >= palabras.size():
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

	timer_memoria.start(5.0)


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

	tween.tween_interval(0.5)
	tween.tween_property(color_fondo, "color", Color(1, 1, 1, 0), 0.1)


func _on_siguiente():
	rondas += 1

	if rondas >= max_rondas:
		cambiar_a_resultados()
	else:
		iniciar_nueva_ronda()


# >>> INSTANCIAR ESCENA DE RESULTADOS RECICLADA <<<
func cambiar_a_resultados():
	# Instancia resultados
	var escena_resultados = preload("res://resultados_2.tscn").instantiate()
	get_tree().root.add_child(escena_resultados)

	# Elimina la escena de juego
	queue_free()

	# Pasa resultados
	if escena_resultados.has_method("set_resultado"):
		escena_resultados.set_resultado(correctas)


func _on_cerrar_pressed() -> void:
	get_tree().quit()


func _on_minimizar_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
