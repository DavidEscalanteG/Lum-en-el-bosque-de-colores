extends CanvasLayer

@onready var barra: ProgressBar = $MarginContainer/Barra
@onready var items: ItemList = $ItemList
@onready var label: Label = $Label
@onready var color: ColorRect = $ColorRect
@onready var imagen_palabra: TextureRect = $ImagenPalabra
@onready var advertencia: Label = $Advertencia

@export var palabra_objetivo := "PA-LA-BRA"
var silabas_objetivo: Array = []
var pos = 0
var errores_actual = 0
var silabas_totales: Array = []
var actividad_terminada := false

# --- Preparar palabra ---
func preparar_palabra():
	pos = 0
	errores_actual = 0
	label.text = ""
	items.clear()

	# Separamos la palabra por guiones para la lógica de juego
	silabas_objetivo = palabra_objetivo.split("-")

	# Sílabas distractoras para rellenar la ItemList
	var silabas_distractoras = ["PA", "ME", "LU", "CA", "SO", "TI", "RE", "LO"]
	var distractoras_elegidas: Array = []
	for i in range(2):
		distractoras_elegidas.append(silabas_distractoras[randi() % silabas_distractoras.size()])

	silabas_totales = silabas_objetivo + distractoras_elegidas
	silabas_totales.shuffle()

	barra.value = 0
	barra.max_value = silabas_objetivo.size()

	items.max_columns = silabas_totales.size()
	
	# Estilo visual tipo burbuja para las sílabas
	var estilo_burbuja = StyleBoxFlat.new()
	estilo_burbuja.bg_color = Color(0.3, 0.5, 1.0, 0.9)
	estilo_burbuja.corner_radius_top_left = 12
	estilo_burbuja.corner_radius_top_right = 12
	estilo_burbuja.corner_radius_bottom_left = 12
	estilo_burbuja.corner_radius_bottom_right = 12
	items.add_theme_stylebox_override("normal", estilo_burbuja)

	for silaba in silabas_totales:
		items.add_item(silaba)

	label.text = "_ ".repeat(silabas_objetivo.size())
	actualizar_imagen()

# --- Ready ---
func _ready() -> void:
	randomize()
	if has_node("AudioStreamPlayer2D"):
		$AudioStreamPlayer2D.play()

	errores_actual = 0
	advertencia.visible = false

	# Selección de lista global
	if not Global.lista_silabas_seleccionada:
		if randf() < 0.5:
			Global.lista_actual_silabas = Global.palabras_silabas.duplicate()
		else:
			Global.lista_actual_silabas = Global.palabras_silabas2.duplicate()
		Global.lista_silabas_seleccionada = true

	# Control de palabras fallidas o nuevas
	var pendiente := Partidas.obtener_actividad(2)
	if pendiente.has("palabra"):
		palabra_objetivo = pendiente.palabra
	elif Global.ultima_palabra_fallida_silabas != "":
		palabra_objetivo = Global.ultima_palabra_fallida_silabas
		Global.ultima_palabra_fallida_silabas = ""
	else:
		palabra_objetivo = Global.obtener_palabra_sin_repetir()

	if palabra_objetivo == "":
		get_tree().change_scene_to_file("res://felicidades_nivel_2.tscn")
		return

	Partidas.guardar_actividad(2, {"palabra": palabra_objetivo})
	preparar_palabra()

# --- Clic en sílaba ---
func _on_item_list_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	if actividad_terminada or items.is_item_disabled(index):
		return
	var silaba = items.get_item_text(index)
	if silaba == silabas_objetivo[pos]:
		items.set_item_disabled(index, true)
		correcto()
	else:
		incorrecto()

# --- Correcto ---
func correcto() -> void:
	if has_node("correcct"): $correcct.play()

	if is_instance_valid(color):
		var tween = get_tree().create_tween()
		tween.tween_property(color, "color", Color(0, 1, 0, 0.7), 0.3)
		tween.tween_callback(reset_color)

	update_label()
	barra.value += 1

	if pos == silabas_objetivo.size() - 1:
		actividad_terminada = true
		Global.palabras_completadas_silabas += 1
		Global.ultima_palabra_fallida_silabas = ""
		Partidas.limpiar_actividad(2)
		if Global.palabras_completadas_silabas >= Global.lista_actual_silabas.size():
			Partidas.completar_capitulo(2)
		Partidas.guardar_punto("res://felicidades_nivel_2.tscn")
		errores_actual = 0
		await get_tree().create_timer(0.5).timeout
		if has_node("Felicidasde"): $Felicidasde.play()
		
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://felicidades_nivel_2.tscn")
	else:
		pos += 1

# --- Incorrecto ---
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
		Global.ultima_palabra_fallida_silabas = palabra_objetivo
		errores_actual = 0
		get_tree().change_scene_to_file("res://volverajugar_2.tscn")

func mostrar_advertencia(texto: String):
	advertencia.text = texto
	advertencia.visible = true
	await get_tree().create_timer(2.0).timeout
	advertencia.visible = false

func reset_color():
	if is_instance_valid(color):
		color.color = Color(0, 0, 0, 0)

func update_label():
	var sub = ""
	for i in range(pos + 1):
		sub += silabas_objetivo[i] + " "
	label.text = sub + "_ ".repeat(silabas_objetivo.size() - pos - 1)

# --- ACTUALIZACIÓN MAESTRA DE CARGA DE IMÁGENES ---
func actualizar_imagen():
	# Eliminamos guiones para el nombre del archivo: "LU-MI" -> "LUMI"
	var nombre_base = Global.nombre_archivo_sin_acentos(palabra_objetivo.replace("-", ""))
	
	# Lista de posibles combinaciones (Mayúsculas/Minúsculas + PNG/JPG)
	var rutas_a_intentar = [
		"res://Img/" + nombre_base + ".png",
		"res://Img/" + nombre_base + ".jpg",
		"res://Img/" + nombre_base.to_lower() + ".png",
		"res://Img/" + nombre_base.to_lower() + ".jpg",
		"res://Img/" + nombre_base.to_upper() + ".png",
		"res://Img/" + nombre_base.to_upper() + ".jpg"
	]
	
	var textura_encontrada = null
	
	for ruta in rutas_a_intentar:
		if ResourceLoader.exists(ruta):
			textura_encontrada = load(ruta)
			if textura_encontrada:
				print("Log: Cargada imagen desde " + ruta)
				break 

	if textura_encontrada:
		imagen_palabra.texture = textura_encontrada
	else:
		push_error("Error: No se encontró imagen para " + nombre_base + " en res://Img/")
		imagen_palabra.texture = null

func _on_cerrar_pressed() -> void:
	get_tree().quit()

func _on_minimizar_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
