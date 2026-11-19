extends SceneTree

var partidas: Node
var global: Node
var fallos := 0
var comprobaciones := 0

func _initialize() -> void:
	call_deferred("_ejecutar")

func comprobar(condicion: bool, descripcion: String) -> void:
	comprobaciones += 1
	if not condicion:
		fallos += 1
		printerr("FALLO: " + descripcion)
	else:
		print("OK: " + descripcion)

func ir(ruta: String) -> Node:
	change_scene_to_file(ruta)
	await scene_changed
	await process_frame
	return current_scene

func _ejecutar() -> void:
	partidas = root.get_node("Partidas")
	global = root.get_node("Global")
	partidas.directorio = "res://.godot/pruebas-flujo/" + str(Time.get_ticks_usec())
	partidas.crear("Prueba de historia", "Mia")
	global.palabras_completadas = 9
	global.ronda = 9
	var juego := await ir("res://Scenes/juego_1.tscn")
	juego.completar_palabra()
	await scene_changed
	await process_frame
	comprobar(partidas.activa.desbloqueado == 2, "La décima palabra desbloquea el capítulo 2")
	current_scene._on_button_pressed()
	await scene_changed
	await process_frame
	comprobar(current_scene.scene_file_path == "res://Animacion/animacion_5.tscn", "Continúa la historia después del primer capítulo")
	global.reiniciar_capitulo(2)
	global.lista_silabas_seleccionada = true
	global.lista_actual_silabas = ["GO-MA", "CA-RRU-SEL"]
	global.palabras_completadas_silabas = 1
	global.palabras_usadas_silabas = ["GO-MA"]
	global.ronda = 1
	juego = await ir("res://Scenes/Nivel2.tscn")
	juego.pos = juego.silabas_objetivo.size() - 1
	juego.correcto()
	await scene_changed
	await process_frame
	comprobar(partidas.activa.desbloqueado == 3, "La última palabra de sílabas desbloquea el capítulo 3")
	current_scene._on_button_pressed()
	await scene_changed
	await process_frame
	comprobar(current_scene.scene_file_path == "res://Animacion/animacion_9.tscn", "Continúa la historia después de las sílabas")
	partidas.guardar_actividad(3, {"rondas": 15, "correctas": 10, "indice_imagen": 15})
	await ir("res://resultados_2.tscn")
	current_scene._on_boton_accion_pressed()
	await scene_changed
	await process_frame
	comprobar(current_scene.scene_file_path == "res://Animacion/animacion_14.tscn" and partidas.activa.desbloqueado == 4, "El resultado de memoria avanza al capítulo 4")
	global.reiniciar_capitulo(4)
	global.oraciones_completadas = 9
	global.lista_actual_oraciones = ["La casa es grande"]
	juego = await ir("res://nivel_4.tscn")
	juego.pos = juego.palabras_objetivo.size() - 1
	juego.correcto()
	await scene_changed
	await process_frame
	comprobar(current_scene.scene_file_path == "res://Animacion/animacion_21.tscn" and partidas.activa.desbloqueado == 5, "La décima oración abre el capítulo final")
	partidas.guardar_actividad(5, {"pregunta": 12, "correctas": 6})
	juego = await ir("res://nivel_5.tscn")
	juego.respuesta = juego.indice_correcta_actual
	juego.responder()
	juego._on_siguiente_pressed()
	await scene_changed
	await process_frame
	comprobar(current_scene.scene_file_path == "res://resultados.tscn" and current_scene.correctas == 7, "La última pregunta llega a resultados con la puntuación guardada")
	current_scene._on_boton_accion_pressed()
	await scene_changed
	await process_frame
	comprobar(current_scene.scene_file_path == "res://Animacion/animacion_24.tscn" and partidas.activa.completados.size() == 5, "Completar la historia conserva los cinco capítulos")
	# Repetir un capítulo terminado no debe borrar uno que quedó pendiente.
	partidas.activa.completados.erase(4)
	global.reiniciar_capitulo(4)
	global.oraciones_completadas = 3
	global.lista_actual_oraciones = ["La casa es grande"]
	partidas.guardar_actividad(4, {"oracion": "La casa es grande"})
	await ir("res://Scenes/mapa_de_niveles.tscn")
	partidas.abrir_capitulo(1)
	await scene_changed
	await process_frame
	await ir("res://Scenes/mapa_de_niveles.tscn")
	partidas.abrir_capitulo(4)
	await scene_changed
	await process_frame
	comprobar(current_scene.scene_file_path == "res://nivel_4.tscn" and global.oraciones_completadas == 3, "Volver a un capítulo anterior conserva la actividad pendiente de otro")
	# Comprobar todos los puntos de guardado de la narración y sus nodos.
	for ruta in partidas._escenas:
		if ruta.begins_with("res://Animacion/") and FileAccess.file_exists(ruta):
			await ir(ruta)
	print("RESULTADO FLUJO: %d comprobaciones, %d fallos" % [comprobaciones, fallos])
	partidas.activa = {}
	# Dejar que el hilo de audio libere los MP3 tras recorrer rápidamente las escenas.
	unload_current_scene()
	await process_frame
	await create_timer(0.25).timeout
	call_deferred("quit", 0 if fallos == 0 else 1)
