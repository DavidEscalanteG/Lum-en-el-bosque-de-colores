extends SceneTree
## Prueba visual aislada. Añadir -- --crear, --vacia o --interactivo.

func _initialize() -> void:
	call_deferred("_mostrar")

func _mostrar() -> void:
	var partidas := root.get_node("Partidas")
	var global := root.get_node("Global")
	partidas.directorio = "res://.godot/pruebas-visuales/" + str(Time.get_ticks_usec())
	var argumentos := OS.get_cmdline_user_args()
	var primera := ""
	var orden := 0
	if not "--vacia" in argumentos:
		for datos in [["Sofía", "Lumi", 3], ["Mateo", "Nico", 2], ["Valeria", "Tilo", 1]]:
			partidas.crear(datos[0], datos[1])
			partidas.activa.desbloqueado = datos[2]
			partidas.activa.ultima_vez = Time.get_unix_time_from_system() - (0 if orden == 0 else (86400 if orden == 1 else 259200))
			partidas.guardar(false)
			orden += 1
			if primera.is_empty():
				primera = partidas.activa.id
	partidas.activa = {}
	global.reiniciar_partida()
	change_scene_to_file("res://login.tscn")
	await scene_changed
	var perfiles := current_scene
	if not primera.is_empty():
		perfiles.elegida = primera
		perfiles.mostrar_libro()
	if "--crear" in argumentos:
		perfiles.mostrar_creacion()
		perfiles.nombre_input.text = "Sofía"
		perfiles._actualizar_nombre("Sofía")
	if "--editar" in argumentos:
		perfiles.mostrar_creacion(primera)
	if "--muchas" in argumentos:
		for i in range(8):
			partidas.crear("Aventura %d" % (i + 1), partidas.ANIMALES[i % 6])
		partidas.activa = {}
		perfiles.mostrar_libro()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var imagen := root.get_texture().get_image()
	var nombre := "crear" if "--crear" in argumentos else ("vacia" if "--vacia" in argumentos else ("editar" if "--editar" in argumentos else "libro"))
	var destino := "res://docs/propuestas-perfiles/validacion/" + nombre + ".png"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(destino.get_base_dir()))
	imagen.save_png(destino)
	print("CAPTURA=" + destino)
	if not "--interactivo" in argumentos:
		quit()
