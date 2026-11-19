extends CanvasLayer

var correctas = 0
var incorrectas = 0
var total = 0

func _ready() -> void:
	set_resultado(int(Partidas.obtener_actividad(5).get("correctas", 0)))

func set_resultado(c):
	$sonido2.play()
	$sonido.play()
	correctas = c
	incorrectas = 13 - c
	if correctas >= 7:
		Partidas.completar_capitulo(5)
		Partidas.guardar_punto("res://resultados.tscn")
	_mostrar_resultado()

func _mostrar_resultado():
	if !$Titulo or !$Resumen or !$BotonAccion:
		push_error("Faltan nodos en Resultados.tscn")
		return

	
	$Resumen.text = " Correctas: " + str(correctas) + "/13"
	
	if correctas >= 7:
		$BotonAccion.text = "Continuar"
	else:
		$BotonAccion.text = "Volver a intentar"

func _on_boton_accion_pressed() -> void:
	if correctas >= 7:
		get_tree().change_scene_to_file("res://Animacion/animacion_24.tscn")
	else:
		Partidas.limpiar_actividad(5)
		get_tree().change_scene_to_file("res://nivel_5.tscn")
