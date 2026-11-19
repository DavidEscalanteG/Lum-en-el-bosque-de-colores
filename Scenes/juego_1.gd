extends CanvasLayer

@onready var barra: ProgressBar = $MarginContainer/Barra
@onready var items: ItemList = $ItemList
@onready var label: Label = $Label
@onready var color: ColorRect = $ColorRect
@onready var imagen_palabra: TextureRect = $ImagenPalabra
@onready var advertencia: Label = $Advertencia

@export var palabra_objetivo := "PALABRA"

## Texturas asignadas desde el Inspector; claves sin acentos ni guiones.
@export var imagenes: Dictionary[String, Texture2D] = {}

var pos = 0
var errores_actual = 0
var actividad_terminada := false

func _ready() -> void:
	randomize()
	errores_actual = 0
	advertencia.visible = false
	
	if has_node("AudioStreamPlayer2D"):
		$AudioStreamPlayer2D.play()
	
	# Determinar la palabra objetivo
	if Global.ultima_palabra_fallida != "":
		palabra_objetivo = Global.ultima_palabra_fallida
	else:
		if Global.lista_actual == null or Global.lista_actual.is_empty():
			Global.lista_actual = Global.palabras.duplicate() if randf() < 0.5 else Global.palabras2.duplicate()
		
		# Asegurar que la ronda no se pase del tamaño de la lista
		if Global.ronda >= Global.lista_actual.size():
			Global.ronda = 0
			
		palabra_objetivo = Global.lista_actual[Global.ronda]
	
	var pendiente := Partidas.obtener_actividad(1)
	if pendiente.has("palabra"):
		palabra_objetivo = pendiente.palabra
	Partidas.guardar_actividad(1, {"palabra": palabra_objetivo})
	label.set_text("")
	items.max_columns = palabra_objetivo.length()
	barra.max_value = palabra_objetivo.length()
	barra.value = 0
	
	actualizar_imagen()
	preparar_letras()

func preparar_letras() -> void:
	items.clear()
	var chars = Array(palabra_objetivo.split(""))
	chars.shuffle()
	
	label.text = "_ ".repeat(palabra_objetivo.length())
		
	for char in chars:
		items.add_item(char)

func _on_item_list_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	if actividad_terminada or items.is_item_disabled(index):
		return
	var letra_seleccionada = items.get_item_text(index)
	
	if letra_seleccionada == palabra_objetivo[pos]:
		items.set_item_disabled(index, true)
		correcto()
	else:
		incorrecto()

func correcto() -> void:
	if has_node("correcct"): $correcct.play()
	
	if is_instance_valid(color):
		var tween = get_tree().create_tween()
		tween.tween_property(color, "color", Color(0, 1, 0, 0.7), 0.3)
		tween.tween_callback(reset_color)
	
	update_label()
	barra.value += 1
	
	if pos == palabra_objetivo.length() - 1:
		completar_palabra()
	else:
		pos += 1

func completar_palabra() -> void:
	actividad_terminada = true
	Global.palabras_completadas += 1
	Global.ultima_palabra_fallida = ""
	errores_actual = 0
	
	# Siempre avanzamos la ronda y vamos a felicidades
	Global.ronda += 1
	Partidas.limpiar_actividad(1)
	if Global.palabras_completadas >= 10:
		Partidas.completar_capitulo(1)
	Partidas.guardar_punto("res://Scenes/Felicidades.tscn")
	get_tree().change_scene_to_file("res://Scenes/Felicidades.tscn")

func incorrecto() -> void:
	if has_node("recchazo"): $recchazo.play()
	errores_actual += 1
	
	if is_instance_valid(color):
		var tween = get_tree().create_tween()
		tween.tween_property(color, "color", Color(1, 0, 0, 0.7), 0.3)
		tween.tween_callback(reset_color)
	
	if errores_actual == 2:
		mostrar_advertencia("Cuidado, te has equivocado 2 veces")
	elif errores_actual > 2:
		Global.ultima_palabra_fallida = palabra_objetivo
		get_tree().change_scene_to_file("res://volver_a_jugar.tscn")

# --- SISTEMA DE CARGA ROBUSTO ---
func actualizar_imagen() -> void:
	var clave := Global.nombre_archivo_sin_acentos(palabra_objetivo.replace("-", "")).to_upper()
	imagen_palabra.texture = imagenes.get(clave)
	if imagen_palabra.texture == null:
		push_warning("Asigna una imagen para %s en el Inspector del nivel." % clave)

func update_label():
	var completado = palabra_objetivo.left(pos + 1)
	var restante = "_ ".repeat(palabra_objetivo.length() - (pos + 1))
	label.text = completado + " " + restante

func mostrar_advertencia(texto: String):
	advertencia.text = texto
	advertencia.visible = true
	await get_tree().create_timer(2.0).timeout
	advertencia.visible = false

func reset_color():
	if is_instance_valid(color):
		color.color = Color(0, 0, 0, 0)

func _on_cerrar_pressed() -> void:
	get_tree().quit()

func _on_minimizar_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
