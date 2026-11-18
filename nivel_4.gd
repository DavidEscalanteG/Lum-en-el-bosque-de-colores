extends CanvasLayer

@onready var barra: ProgressBar = $MarginContainer/Barra
@onready var items: ItemList = $ItemList
@onready var label: Label = $Label
@onready var color: ColorRect = $ColorRect
@onready var imagen_palabra: TextureRect = $ImagenOracion
@onready var advertencia: Label = $Advertencia

@export var oracion_objetivo := "EL PERRO CORRE"
var palabras_objetivo: Array = []
var pos = 0
var errores_actual = 0
var palabras_totales: Array = []

# --- ELEGIR ORACIÓN ALEATORIA ---
func elegir_oracion_aleatoria() -> String:
	var lista = Global.lista_actual_oraciones
	if lista.is_empty():
		return ""

	var disponibles = []
	for o in lista:
		if not o in Global.oraciones_usadas:
			disponibles.append(o)

	if disponibles.is_empty():
		return ""

	var index = randi() % disponibles.size()
	var elegida = disponibles[index]
	Global.oraciones_usadas.append(elegida)
	return elegida

# --- PREPARAR ORACIÓN ---
func preparar_oracion():
	pos = 0
	errores_actual = 0
	label.text = ""
	items.clear()

	palabras_objetivo = oracion_objetivo.split(" ")
	palabras_totales = palabras_objetivo.duplicate()
	palabras_totales.shuffle()

	barra.value = 0
	barra.max_value = palabras_objetivo.size()
	items.max_columns = palabras_totales.size()


	for palabra in palabras_totales:
		items.add_item(palabra)

	label.text = "_ ".repeat(palabras_objetivo.size())
	actualizar_imagen()

# --- READY ---
func _ready() -> void:
	randomize()

	if has_node("AudioStreamPlayer2D"):
		$AudioStreamPlayer2D.play()

	errores_actual = 0
	advertencia.visible = false

	# ⭐ CARGAR LISTAS Y SELECCIONAR ORACIÓN ⭐
	if Global.ultima_oracion_fallida != "":
		oracion_objetivo = Global.ultima_oracion_fallida
	else:	
		# Si las listas están vacías (primera vez en el nivel), las llenamos
		if Global.lista_actual_oraciones.is_empty():
			if randf() < 0.5:
				Global.lista_actual_oraciones = Global.oraciones.duplicate()
			else:
				Global.lista_actual_oraciones = Global.oraciones2.duplicate()
			
			# IMPORTANTE: Reiniciar contador si es la primera oración del nivel
			Global.oraciones_completadas = 0 
			Global.oraciones_usadas.clear()

		oracion_objetivo = elegir_oracion_aleatoria()

	if oracion_objetivo == "":
		get_tree().change_scene_to_file("res://Animacion/animacion_21.tscn")
		return

	preparar_oracion()

# --- CLICK EN PALABRA ---
func _on_item_list_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	var palabra = items.get_item_text(index)
	if palabra == palabras_objetivo[pos]:
		items.set_item_disabled(index, true)
		correcto()
	else:
		incorrecto()

# --- CORRECTO ---
func correcto() -> void:
	if has_node("correcct"): $correcct.play()

	if is_instance_valid(color):
		var tween = get_tree().create_tween()
		tween.tween_property(color, "color", Color(0, 1, 0, 0.7), 0.3)
		tween.tween_callback(reset_color)

	update_label()
	barra.value += 1

	if pos == palabras_objetivo.size() - 1:
		# ⭐ ORACIÓN COMPLETADA ⭐
		Global.oraciones_completadas += 1
		Global.ultima_oracion_fallida = ""
		errores_actual = 0

		await get_tree().create_timer(0.5).timeout
		
		# Decidir a qué escena ir
		if Global.oraciones_completadas >= 10:
			# Ya hizo las 10, vamos a la animación final del nivel
			Global.lista_actual_oraciones.clear() # Limpiamos para el próximo reinicio
			get_tree().change_scene_to_file("res://Animacion/animacion_21.tscn")
		else:
			# Ir a felicidades tras cada oración
			get_tree().change_scene_to_file("res://felicidades_4.tscn")
	else:
		pos += 1

# --- INCORRECTO ---
func incorrecto() -> void:
	errores_actual += 1
	if has_node("recchazo"): $recchazo.play()

	if is_instance_valid(color):
		var tween = get_tree().create_tween()
		tween.tween_property(color, "color", Color(1, 0, 0, 0.7), 0.5)
		tween.tween_callback(reset_color)

	if errores_actual == 2:
		mostrar_advertencia("Cuidado, te has equivocado 2 veces")
	elif errores_actual > 2:
		Global.ultima_oracion_fallida = oracion_objetivo
		get_tree().change_scene_to_file("res://volver_ajugar_3.tscn")

# --- ACTUALIZAR IMAGEN ---
func actualizar_imagen():
	var nombre_base = oracion_objetivo.strip_edges()
	var rutas = [
		"res://Img/" + nombre_base + ".png",
		"res://Img/" + nombre_base + ".jpg",
		"res://Img/" + nombre_base.to_lower() + ".png",
		"res://Img/" + nombre_base.to_lower() + ".jpg"
	]
	
	var tex = null
	for r in rutas:
		if ResourceLoader.exists(r):
			tex = load(r)
			break
	
	if tex:
		imagen_palabra.texture = tex

func update_label():
	var sub = ""
	for i in range(pos + 1):
		sub += palabras_objetivo[i] + " "
	label.text = sub + "_ ".repeat(palabras_objetivo.size() - pos - 1)

func mostrar_advertencia(texto: String):
	advertencia.text = texto
	advertencia.visible = true
	await get_tree().create_timer(2.0).timeout
	advertencia.visible = false

func reset_color():
	if is_instance_valid(color): color.color = Color(0, 0, 0, 0)

func _on_cerrar_pressed() -> void: get_tree().quit()
func _on_minimizar_pressed() -> void: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
