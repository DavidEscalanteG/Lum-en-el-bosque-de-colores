extends CanvasLayer
func _ready() -> void:
	$sonido.play()
	$sonido2.play()

# Botón “Siguiente” después de Felicidades
func _on_button_pressed() -> void:
	$burbuja.play()
	
	# Si completaste 10 palabras y estás en nivel 1 → pasar al nivel 2
	if Global.palabras_completadas >= 10 and Global.nivel == 1:
		Global.nivel = 2
		Global.ronda = 0
		Global.palabras_completadas = 0
		Global.lista_actual = Global.palabras2
		get_tree().change_scene_to_file("res://Animacion/animacion_5.tscn")
	else:
		# Para cualquier otra palabra → volver al juego
		get_tree().change_scene_to_file("res://Scenes/juego_1.tscn")


# Botón “Mapa de niveles” o similar
func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/mapa_de_niveles.tscn")
