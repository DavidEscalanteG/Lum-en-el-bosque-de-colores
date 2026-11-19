extends SceneTree
## Ejecutar con --headless --editor --path . --script res://tests/editor_previa.gd
## Prueba los scripts @tool en contexto real de editor, sin cargar partidas.

var fallos := 0

func _initialize() -> void:
	call_deferred("_ejecutar")

func comprobar(valor: bool, descripcion: String) -> void:
	if not valor:
		fallos += 1
		printerr("FALLO: " + descripcion)

func _ejecutar() -> void:
	comprobar(Engine.is_editor_hint(), "Se ejecuta en contexto de editor")
	if not Engine.is_editor_hint():
		quit(1)
		return
	var perfiles: Node = load("res://login.tscn").instantiate()
	root.add_child(perfiles)
	comprobar(perfiles.get_node("Lienzo/Libro").visible, "Vista del libro")
	perfiles.set("vista_editor", 1)
	comprobar(perfiles.get_node("Lienzo/Crear").visible and not perfiles.get_node("Lienzo/Libro").visible, "Vista de creación")
	perfiles.set("vista_editor", 2)
	comprobar(perfiles.get_node("Lienzo/Crear/TituloEdicion").visible, "Título de edición")
	comprobar(perfiles.get_node("Lienzo/Crear/ComenzarAventura").text == "Guardar cambios", "Botón de edición")
	perfiles.free()
	var memoria: Node = load("res://nivel_3.tscn").instantiate()
	root.add_child(memoria)
	comprobar(memoria.get_node("ContenedorMemoria").visible and not memoria.get_node("ContenedorPregunta").visible, "Vista de memoria")
	memoria.set("vista_editor", 1)
	comprobar(memoria.get_node("ContenedorPregunta").visible and memoria.get_node("HBoxContainer").visible and not memoria.get_node("ContenedorMemoria").visible, "Vista de pregunta")
	memoria.set("vista_editor", 2)
	comprobar(memoria.get_node("Retroalimentación").visible and memoria.get_node("Siguiente").visible and not memoria.get_node("HBoxContainer").visible, "Vista de respuesta")
	memoria.free()
	print("RESULTADO PREVIA: 8 comprobaciones, %d fallos" % fallos)
	quit(0 if fallos == 0 else 1)
