extends CanvasLayer

var correctas = 0
var incorrectas = 0
var total = 0

func _ready() -> void:
	set_resultado(int(Partidas.obtener_actividad(3).get("correctas", 0)))

func set_resultado(c):
	$sonido2.play()
	$sonido.play()
	correctas = c
	incorrectas = 15 - c
	if correctas >= 10:
		Partidas.completar_capitulo(3)
		Partidas.guardar_punto("res://resultados_2.tscn")
	_mostrar_resultado()

func _mostrar_resultado():
	if !$Titulo or !$Resumen or !$BotonAccion:
		push_error("Faltan nodos en Resultados.tscn")
		return

	
	$Resumen.text = " Correctas: " + str(correctas) + "/15"
	
	if correctas >= 10:
		$BotonAccion.text = "Desbloquear nivel"
	else:
		$BotonAccion.text = "Volver a intentar"

func _on_boton_accion_pressed() -> void:
	if correctas >= 10:
		get_tree().change_scene_to_file("res://Animacion/animacion_14.tscn")
	else:
		Partidas.limpiar_actividad(3)
		get_tree().change_scene_to_file("res://nivel_3.tscn")
