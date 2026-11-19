extends SceneTree
## Ejecutar con --headless --path . --script res://tests/pruebas_partidas.gd
## Todos los archivos de prueba quedan dentro de .godot; nunca usa partidas reales.

var partidas: Node
var global: Node
var comprobaciones := 0
var fallos := 0
var carpeta := "res://.godot/pruebas-partidas/" + str(Time.get_ticks_usec())
var recargar := false


func _initialize() -> void:
	for argumento in OS.get_cmdline_user_args():
		if argumento.begins_with("--directorio="):
			carpeta = argumento.trim_prefix("--directorio=")
		if argumento == "--recargar":
			recargar = true
	call_deferred("_ejecutar")


func comprobar(valor: bool, descripcion: String) -> void:
	comprobaciones += 1
	if not valor:
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
	partidas.directorio = carpeta
	if recargar:
		var datos: Array = partidas.listar()
		comprobar(datos.size() == 2, "Los perfiles sobreviven a un proceso nuevo")
		for datos_perfil in datos:
			if datos_perfil.nombre == "Sofía":
				comprobar(partidas.seleccionar(datos_perfil.id), "Se restaura la aventura desde disco")
				comprobar(global.palabras_completadas == 6, "Se restaura el avance guardado")
				comprobar(partidas.activa.desbloqueado == 5, "Se restauran los capítulos disponibles")
		_finalizar()
		return
	comprobar(partidas.crear("   ", "Lumi") != "", "Rechaza nombres vacíos")
	comprobar(partidas.crear("Luz", "Otro") != "", "Rechaza animales desconocidos")
	comprobar(partidas.crear("Sofía", "Lumi") == "", "Crea una partida sin contraseña")
	var primera: String = partidas.activa.id
	comprobar(partidas.puede_jugar(1) and not partidas.puede_jugar(2), "Solo el primer capítulo está disponible al comenzar")
	global.palabras_completadas = 4
	global.ronda = 4
	global.lista_actual = ["ARBOL", "COLORES", "GIRASOL", "PINCEL", "SOL"]
	partidas.guardar_actividad(1, {"palabra": "SOL"})
	comprobar(partidas.crear("Sofía", "Nico") == "", "Admite nombres repetidos")
	var segunda: String = partidas.activa.id
	comprobar(primera != segunda and partidas.listar().size() == 2, "Los nombres repetidos no sobrescriben partidas")
	comprobar(global.palabras_completadas == 0 and global.lista_actual.is_empty(), "Un perfil nuevo no hereda el estado del anterior")
	comprobar(partidas.editar(segunda, "Mateo", "Bruno"), "Permite cambiar nombre e ícono")
	comprobar(partidas.seleccionar(segunda) and partidas.activa.animal == "Bruno", "La edición se puede cargar desde el archivo principal")
	comprobar(partidas.editar(segunda, "Mateo", "Tilo"), "Permite editar un perfil previamente cargado")
	comprobar(partidas.seleccionar(segunda) and partidas.activa.animal == "Tilo", "Editar después de cargar conserva claves de capítulo válidas")
	comprobar(partidas.listar().size() == 2, "Los perfiles editados siguen apareciendo en el libro")
	comprobar(partidas.seleccionar(primera), "Carga la primera partida")
	comprobar(global.palabras_completadas == 4 and global.ronda == 4, "Mantiene contadores separados")
	var juego := await ir("res://Scenes/juego_1.tscn")
	comprobar(juego.palabra_objetivo == "SOL", "Retoma la palabra pendiente al abrir la actividad")
	juego.completar_palabra()
	await scene_changed
	await process_frame
	comprobar(global.palabras_completadas == 5, "Guarda una palabra completada")
	comprobar(partidas.activa.checkpoint == "res://Scenes/Felicidades.tscn", "Guarda la pantalla de continuación")
	partidas.completar_capitulo(1)
	comprobar(partidas.puede_jugar(2) and not partidas.puede_jugar(3), "Completar un capítulo desbloquea el siguiente")
	global.reiniciar_capitulo(2)
	global.lista_silabas_seleccionada = true
	global.lista_actual_silabas = ["GO-MA", "CA-RRU-SEL"]
	global.palabras_usadas_silabas = ["GO-MA"]
	global.palabras_completadas_silabas = 0
	partidas.guardar_actividad(2, {"palabra": "GO-MA"})
	juego = await ir("res://Scenes/Nivel2.tscn")
	comprobar(juego.palabra_objetivo == "GO-MA", "Reanudar sílabas no salta la palabra ya seleccionada")
	partidas.completar_capitulo(2)
	partidas.guardar_actividad(3, {"rondas": 5, "correctas": 4, "indice_imagen": 5})
	juego = await ir("res://nivel_3.tscn")
	comprobar(juego.rondas == 5 and juego.correctas == 4 and juego.indice_imagen == 6, "Restaura rondas y puntuación de memoria")
	juego._on_respuesta(juego.es_verdadera)
	var conteo: int = juego.correctas
	juego._on_respuesta(juego.es_verdadera)
	comprobar(juego.correctas == conteo, "Una respuesta no se cuenta dos veces")
	comprobar(partidas.obtener_actividad(3).rondas == 6, "Guarda la respuesta antes de pulsar Siguiente")
	partidas.guardar_actividad(3, {"rondas": 15, "correctas": 10, "indice_imagen": 15})
	var resultado := await ir("res://resultados_2.tscn")
	comprobar(resultado.correctas == 10 and partidas.puede_jugar(4), "Los resultados de memoria desbloquean el cuarto capítulo")
	comprobar(partidas.obtener_actividad(3).correctas == 10, "Los resultados siguen disponibles al reabrir")
	global.reiniciar_capitulo(4)
	global.lista_actual_oraciones = ["La casa es grande", "El perro corre rápido"]
	global.oraciones_usadas = ["La casa es grande"]
	global.oraciones_completadas = 3
	partidas.guardar_actividad(4, {"oracion": "La casa es grande"})
	juego = await ir("res://nivel_4.tscn")
	comprobar(juego.oracion_objetivo == "La casa es grande" and global.oraciones_completadas == 3, "Restaura la oración sin repetir ni borrar avances")
	partidas.completar_capitulo(4)
	partidas.guardar_actividad(5, {"pregunta": 4, "correctas": 3})
	juego = await ir("res://nivel_5.tscn")
	comprobar(juego.pregunta_numero == 4 and juego.correctas == 3, "Restaura el cuestionario final")
	juego.respuesta = juego.indice_correcta_actual
	juego.responder()
	juego.responder()
	comprobar(juego.correctas == 4 and partidas.obtener_actividad(5).pregunta == 5, "Guarda una sola vez la respuesta del cuestionario")
	partidas.guardar_actividad(5, {"pregunta": 13, "correctas": 7})
	resultado = await ir("res://resultados.tscn")
	comprobar(resultado.correctas == 7 and 5 in partidas.activa.completados, "Guarda la historia completada")
	var mapa := await ir("res://Scenes/mapa_de_niveles.tscn")
	comprobar(not mapa.get_node("Jugar5").disabled, "El mapa refleja los capítulos desbloqueados")
	partidas.seleccionar(segunda)
	mapa = await ir("res://Scenes/mapa_de_niveles.tscn")
	comprobar(mapa.get_node("Jugar2").disabled and mapa.get_node("Jugar5").disabled, "El bloqueo del mapa pertenece a cada perfil")
	partidas.seleccionar(primera)
	global.palabras_completadas = 6
	partidas.guardar()
	partidas.guardar()
	var ruta: String = ProjectSettings.globalize_path(carpeta.path_join(primera + ".json"))
	var corrupto := FileAccess.open(ruta, FileAccess.WRITE)
	corrupto.store_string("{archivo interrumpido")
	corrupto.close()
	comprobar(partidas.seleccionar(primera) and global.palabras_completadas == 6, "Recupera la copia de respaldo si el archivo principal está dañado")
	comprobar(partidas.guardar(), "Puede guardar de nuevo después de recuperar el respaldo")
	var carpeta_anterior: String = partidas.directorio
	partidas.directorio = ruta.path_join("imposible")
	comprobar(not partidas.guardar(), "Informa un error de escritura sin fingir que guardó")
	partidas.directorio = carpeta_anterior
	comprobar(partidas.seleccionar(primera) and global.palabras_completadas == 6, "El error de escritura conserva el guardado anterior")
	print("DIRECTORIO_PRUEBA=" + carpeta)
	_finalizar()


func _finalizar() -> void:
	partidas.activa = {}
	print("RESULTADO: %d comprobaciones, %d fallos" % [comprobaciones, fallos])
	call_deferred("quit", 0 if fallos == 0 else 1)
