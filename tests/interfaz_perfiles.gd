extends SceneTree

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

func _ejecutar() -> void:
	var partidas := root.get_node("Partidas")
	partidas.directorio = "res://.godot/pruebas-interfaz/" + str(Time.get_ticks_usec())
	change_scene_to_file("res://login.tscn")
	await scene_changed
	await process_frame
	var perfiles := current_scene
	comprobar(perfiles.pagina.get_node("Continuar").disabled, "Sin partidas, Continuar está desactivado")
	perfiles.pagina.get_node("CrearNuevaPartida").pressed.emit()
	await process_frame
	comprobar(perfiles.nombre_input.has_focus(), "Crear partida enfoca el campo del nombre")
	perfiles.pagina.get_node("ComenzarAventura").pressed.emit()
	comprobar(partidas.listar().is_empty() and not perfiles.mensaje.text.is_empty(), "Un nombre vacío muestra ayuda sin crear un archivo")
	for animal in partidas.ANIMALES:
		perfiles.pagina.get_node("Elegir" + animal).pressed.emit()
		comprobar(perfiles.animal == animal, "El botón del animal selecciona " + animal)
	perfiles.nombre_input.text = "Sofía"
	perfiles.nombre_input.text_changed.emit("Sofía")
	comprobar(perfiles.vista_nombre.text == "Sofía", "El nombre con acento aparece en la vista previa")
	perfiles.pagina.get_node("ComenzarAventura").pressed.emit()
	await scene_changed
	await process_frame
	comprobar(partidas.activa.nombre == "Sofía" and partidas.activa.animal == "Bruno", "Comenzar crea el perfil con los valores elegidos")
	var id: String = partidas.activa.id
	partidas.volver_a_perfiles()
	await scene_changed
	await process_frame
	perfiles = current_scene
	comprobar(not perfiles.pagina.get_node("Continuar").disabled, "La partida recién creada aparece al regresar")
	perfiles.pagina.get_node("EditarPerfil").pressed.emit()
	await process_frame
	perfiles.nombre_input.text = "Valeria"
	perfiles.nombre_input.text_changed.emit("Valeria")
	perfiles.pagina.get_node("ElegirMia").pressed.emit()
	perfiles.pagina.get_node("ComenzarAventura").pressed.emit()
	await process_frame
	var datos: Dictionary = partidas.listar()[0]
	comprobar(datos.id == id and datos.nombre == "Valeria" and datos.animal == "Mia", "Editar conserva la misma partida y actualiza nombre y animal")
	comprobar(datos.desbloqueado == 1, "Editar conserva el avance")
	for i in range(9):
		partidas.crear("Aventura %d" % i, partidas.ANIMALES[i % 6])
	partidas.activa = {}
	perfiles.mostrar_libro()
	await process_frame
	await process_frame
	var lista := perfiles.pagina.get_node("ListaPartidas") as ScrollContainer
	comprobar(lista.get_v_scroll_bar().max_value > lista.get_v_scroll_bar().page, "Muchas partidas habilitan desplazamiento vertical")
	var ultima_fila := lista.get_child(0).get_child(9) as Button
	var ultimo_id := ultima_fila.name.trim_prefix("Partida_")
	ultima_fila.pressed.emit()
	await process_frame
	comprobar(perfiles.elegida == ultimo_id, "Cada fila selecciona su propia partida")
	print("RESULTADO INTERFAZ: %d comprobaciones, %d fallos" % [comprobaciones, fallos])
	partidas.activa = {}
	call_deferred("quit", 0 if fallos == 0 else 1)
