extends CanvasLayer

func _ready() -> void:
	if has_node("sonido"): $sonido.play()
	if has_node("sonido2"): $sonido2.play()

# Botón “Siguiente” después de Felicidades
func _on_button_pressed() -> void:
	if has_node("burbuja"): $burbuja.play()

	# 1. Verificamos si ya completamos las 10 oraciones en el Global
	if Global.oraciones_completadas >= 10:
		# Si ya terminó el objetivo, vamos a la animación final del juego
		get_tree().change_scene_to_file("res://Animacion/animacion_21.tscn")
	else:
		# 2. Si faltan oraciones, REGRESAMOS al nivel 4 para la siguiente
		# Asegúrate de que el nombre del archivo sea exacto
		get_tree().change_scene_to_file("res://nivel_4.tscn")

# Botón “Mapa de niveles”
func _on_button_2_pressed() -> void:
	# Al salir al mapa, es buena idea resetear contadores si quieres que empiece de 0 luego
	Global.oraciones_completadas = 0
	get_tree().change_scene_to_file("res://Scenes/mapa_de_niveles.tscn")
