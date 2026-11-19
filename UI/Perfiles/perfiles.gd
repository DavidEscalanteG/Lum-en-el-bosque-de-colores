@tool
extends Control
## La composición vive en libro.tscn, crear.tscn y fila_partida.tscn.
## En ejecución sólo se actualizan los datos y se instancian las filas guardadas.

@export_category("Vista en el editor")
@export_enum("Libro", "Crear", "Editar") var vista_editor: int = 0:
	set(valor):
		vista_editor = valor
		if Engine.is_editor_hint() and is_node_ready():
			_mostrar_vista_editor()

@export_category("Personajes")
@export var retratos: Dictionary[String, Texture2D] = {}
@export var cuerpos: Dictionary[String, Texture2D] = {}
@export var escena_fila: PackedScene

@onready var lienzo: Control = $Lienzo
@onready var libro: Control = $Lienzo/Libro
@onready var creacion: Control = $Lienzo/Crear
@onready var nombre_input: LineEdit = $Lienzo/Crear/NombreInput
@onready var vista_nombre: Label = $Lienzo/Crear/VistaNombre
@onready var vista_animal: TextureRect = $Lienzo/Crear/VistaAnimal
@onready var marca_animal: Control = $Lienzo/Crear/MarcaAnimal
@onready var borde_animal: Panel = $Lienzo/Crear/BordeAnimal
var pagina: Control
var mensaje: Label
var elegida := ""
var animal := "Lumi"
var editando := ""
var _ocupado := false
var _en_creacion := false
var _escala_anterior := Vector2i.ZERO
var _tamano_titulo: int
var _tamano_nombre: int
var _margen_seleccion: Vector2
var _extra_seleccion: Vector2
var _desfase_marca: Vector2


func _ready() -> void:
	if Engine.is_editor_hint():
		_mostrar_vista_editor()
		return
	_escala_anterior = get_window().content_scale_size
	get_window().content_scale_size = Vector2i.ZERO
	_tamano_titulo = libro.get_node("Titulo").get_theme_font_size("font_size")
	_tamano_nombre = vista_nombre.get_theme_font_size("font_size")
	var primero: Button = creacion.get_node("ElegirLumi")
	_margen_seleccion = borde_animal.position - primero.position
	_extra_seleccion = borde_animal.size - primero.size
	_desfase_marca = marca_animal.position - primero.position - Vector2(primero.size.x, 0)
	resized.connect(_ajustar)
	Partidas.guardado_fallido.connect(_error_guardado)
	_ajustar()
	mostrar_libro()


func _mostrar_vista_editor() -> void:
	libro.visible = vista_editor == 0
	creacion.visible = vista_editor != 0
	creacion.get_node("FondoTituloEdicion").visible = vista_editor == 2
	creacion.get_node("TituloEdicion").visible = vista_editor == 2
	var comenzar: Button = creacion.get_node("ComenzarAventura")
	comenzar.theme_type_variation = &"GuardarCambios" if vista_editor == 2 else &""
	comenzar.text = "Guardar cambios" if vista_editor == 2 else ""


func _ajustar() -> void:
	var tamano := lienzo.size
	var factor := minf(size.x / tamano.x, size.y / tamano.y)
	lienzo.scale = Vector2.ONE * factor
	lienzo.position = (size - tamano * factor) / 2.0


func _exit_tree() -> void:
	if not Engine.is_editor_hint():
		get_window().content_scale_size = _escala_anterior


func _cambiar_pagina(nueva: Control) -> void:
	libro.visible = nueva == libro
	creacion.visible = nueva == creacion
	pagina = nueva
	mensaje = pagina.get_node("Mensaje")
	mensaje.text = ""
	_ocupado = false


func mostrar_libro() -> void:
	_en_creacion = false
	_cambiar_pagina(libro)
	var partidas: Array[Dictionary] = Partidas.listar()
	var seleccion: Dictionary = {}
	for datos in partidas:
		if datos.id == elegida:
			seleccion = datos
	if seleccion.is_empty() and not partidas.is_empty():
		seleccion = partidas[0]
		elegida = seleccion.id
	var lista: ScrollContainer = libro.get_node("ListaPartidas")
	var filas: VBoxContainer = lista.get_node("Filas")
	for anterior in filas.get_children():
		filas.remove_child(anterior)
		anterior.queue_free()
	for datos in partidas:
		var fila := escena_fila.instantiate() as Button
		fila.name = "Partida_" + str(datos.id)
		fila.tooltip_text = datos.nombre
		var seleccionada: bool = datos.id == elegida
		fila.theme_type_variation = &"PartidaSeleccionada" if seleccionada else &""
		fila.get_node("Seleccion").visible = seleccionada
		fila.get_node("Recorte/Retrato").texture = retratos.get(datos.animal)
		var etiqueta: Label = fila.get_node("Nombre")
		etiqueta.text = datos.nombre
		if str(datos.nombre).length() > 10:
			etiqueta.add_theme_font_size_override("font_size", roundi(etiqueta.get_theme_font_size("font_size") * 0.68))
		fila.pressed.connect(_seleccionar_fila.bind(str(datos.id)))
		filas.add_child(fila)
	var vacio := seleccion.is_empty()
	libro.get_node("Bienvenida").visible = vacio
	libro.get_node("EditarPerfil").visible = not vacio
	libro.get_node("Continuar").disabled = vacio
	libro.get_node("Personaje").texture = cuerpos.get("Lumi" if vacio else str(seleccion.animal))
	var titular: Label = libro.get_node("Titulo")
	var titulo := "Tu próxima aventura" if vacio else "La aventura de " + str(seleccion.nombre)
	titular.text = titulo
	titular.tooltip_text = titulo
	titular.add_theme_font_size_override("font_size", _tamano_titulo if titulo.length() < 26 else roundi(_tamano_titulo * 0.72))
	libro.get_node("Capitulo").text = "Capítulo 1 de 5" if vacio else "Capítulo %d de 5" % int(seleccion.desbloqueado)
	if not vacio and seleccion.completados.size() == 5:
		libro.get_node("Capitulo").text = "¡Historia completada!"
	libro.get_node("UltimaVez").text = "Tu historia está por comenzar" if vacio else _ultima_vez(float(seleccion.get("ultima_vez", 0)))
	if vacio:
		libro.get_node("CrearNuevaPartida").grab_focus()


func _seleccionar_fila(id: String) -> void:
	var lista: ScrollContainer = libro.get_node("ListaPartidas")
	var desplazamiento := lista.scroll_vertical
	elegida = id
	mostrar_libro()
	lista.set_deferred("scroll_vertical", desplazamiento)


func _ultima_vez(tiempo: float) -> String:
	var hoy := Time.get_date_string_from_system()
	var fecha := Time.get_date_string_from_unix_time(int(tiempo + Time.get_time_zone_from_system().bias * 60))
	if fecha == hoy:
		return "Última vez: hoy"
	if Time.get_unix_time_from_system() - tiempo < 172800:
		return "Última vez: ayer"
	return "Última vez: " + fecha


func mostrar_creacion(id: String = "") -> void:
	_en_creacion = true
	editando = id
	animal = "Lumi"
	var nombre := ""
	for datos in Partidas.listar():
		if datos.id == id:
			nombre = datos.nombre
			animal = datos.animal
	_cambiar_pagina(creacion)
	nombre_input.text = nombre
	var edicion := not editando.is_empty()
	creacion.get_node("FondoTituloEdicion").visible = edicion
	creacion.get_node("TituloEdicion").visible = edicion
	var comenzar: Button = creacion.get_node("ComenzarAventura")
	comenzar.theme_type_variation = &"GuardarCambios" if edicion else &""
	comenzar.text = "Guardar cambios" if edicion else ""
	_elegir_animal(animal)
	nombre_input.grab_focus()
	_actualizar_nombre(nombre)


func _editar_perfil() -> void:
	mostrar_creacion(elegida)


func _nombre_enviado(_valor: String) -> void:
	_crear_partida()


func _elegir_animal(eleccion: String) -> void:
	animal = eleccion
	var boton: Button = creacion.get_node("Elegir" + eleccion)
	borde_animal.position = boton.position + _margen_seleccion
	borde_animal.size = boton.size + _extra_seleccion
	marca_animal.position = boton.position + Vector2(boton.size.x, 0) + _desfase_marca
	vista_animal.texture = retratos.get(animal)


func _actualizar_nombre(valor: String) -> void:
	vista_nombre.text = valor.strip_edges()
	vista_nombre.add_theme_font_size_override("font_size", _tamano_nombre if valor.length() < 9 else roundi(_tamano_nombre * 0.71))
	if is_instance_valid(mensaje):
		mensaje.text = ""


func _crear_partida() -> void:
	if _ocupado:
		return
	if not Partidas.nombre_valido(nombre_input.text):
		mensaje.text = "Escribe tu nombre para comenzar (máximo 24 caracteres)."
		nombre_input.grab_focus()
		return
	_ocupado = true
	if not editando.is_empty():
		if Partidas.editar(editando, nombre_input.text, animal):
			elegida = editando
			Partidas.activa = {}
			Global.reiniciar_partida()
			mostrar_libro()
		else:
			_ocupado = false
		return
	var error: String = Partidas.crear(nombre_input.text, animal)
	if not error.is_empty():
		mensaje.text = error
		_ocupado = false
		return
	Partidas.continuar()


func _continuar() -> void:
	if _ocupado or elegida.is_empty():
		return
	_ocupado = true
	if Partidas.seleccionar(elegida):
		Partidas.continuar()
	else:
		_ocupado = false


func _error_guardado(texto: String) -> void:
	if is_instance_valid(mensaje):
		mensaje.text = texto


func _volver_al_menu() -> void:
	get_tree().change_scene_to_file("res://menu1.tscn")


func _salir() -> void:
	$ConfirmarSalida.popup_centered()


func _confirmar_salida() -> void:
	get_tree().quit()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _en_creacion:
			mostrar_libro()
		else:
			_salir()
		get_viewport().set_input_as_handled()
