extends CanvasLayer

func _ready() -> void:
	$sonido.play()
	$sonido2.play()

func _on_button_pressed() -> void:
	$burbuja.play()

	# Seguridad: si la lista de sílabas está vacía, recargarla
	if Global.lista_actual_silabas.is_empty():
		Global.lista_actual_silabas = Global.palabras_silabas.duplicate()

	# Avanzamos a la siguiente palabra
	Global.ronda = Global.palabras_completadas_silabas

	# -------------------------------
	# ✔ Si ya NO hay más palabras → Nivel 3
	# -------------------------------
	if Global.ronda >= Global.lista_actual_silabas.size():
		Partidas.completar_capitulo(2)
		Global.ronda = 0
		Global.palabras_completadas_silabas = 0
		Global.palabras_usadas_silabas.clear()

		# PASAR A NIVEL 3
		Global.nivel = 3
		get_tree().change_scene_to_file("res://Animacion/animacion_9.tscn")
		return

	# -------------------------------
	# ✔ Si aún quedan palabras → seguir en Nivel 2
	# -------------------------------
	get_tree().change_scene_to_file("res://Scenes/Nivel2.tscn")


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/mapa_de_niveles.tscn")
