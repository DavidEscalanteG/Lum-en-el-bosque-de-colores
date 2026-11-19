extends Control
## Arte de la propuesta aprobada y controles reales, con escala uniforme.

const TAMANO := Vector2(1672, 941)
const LIBRO := preload("res://UI/Perfiles/arte/libro.png")
const CREAR := preload("res://UI/Perfiles/arte/crear.png")
const RETRATOS_ATLAS := preload("res://UI/Perfiles/arte/retratos.png")
const FUENTE := preload("res://UI/Perfiles/fuentes/LilitaOne-Regular.ttf")
const MARCA := preload("res://UI/Perfiles/marca_seleccion.gd")
const TINTA := Color("49230f")
const SPRITES := ["res://Animacion/Lumi_estatico.png", "res://Animacion/Luna_hablando.png",
	"res://Animacion/Mia_hablando.png", "res://Animacion/Nico_hablando.png",
	"res://Animacion/Tilo_hablando.png", "res://Animacion/Bruno_hablando.png"]

var lienzo: Control
var fondo: TextureRect
var pagina: Control
var elegida := ""
var animal := "Lumi"
var editando := ""
var nombre_input: LineEdit
var mensaje: Label
var vista_nombre: Label
var vista_animal: TextureRect
var marca_animal: Control
var borde_animal: Panel
var _ocupado := false
var _en_creacion := false
var _escala_anterior := Vector2i.ZERO


func _ready() -> void:
	_escala_anterior = get_window().content_scale_size
	# Las escenas antiguas estiran 1152x648; el libro conserva sus proporciones.
	get_window().content_scale_size = Vector2i.ZERO
	var cielo := ColorRect.new()
	cielo.color = Color("82d8ed")
	cielo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(cielo)
	lienzo = Control.new()
	lienzo.size = TAMANO
	add_child(lienzo)
	fondo = TextureRect.new()
	fondo.size = TAMANO
	fondo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lienzo.add_child(fondo)
	resized.connect(_ajustar)
	Partidas.guardado_fallido.connect(_error_guardado)
	_ajustar()
	mostrar_libro()


func _ajustar() -> void:
	if not is_instance_valid(lienzo):
		return
	var factor := minf(size.x / TAMANO.x, size.y / TAMANO.y)
	lienzo.scale = Vector2.ONE * factor
	lienzo.position = (size - TAMANO * factor) / 2.0


func _exit_tree() -> void:
	get_window().content_scale_size = _escala_anterior


func _nueva_pagina(textura: Texture2D) -> void:
	if is_instance_valid(pagina):
		lienzo.remove_child(pagina)
		pagina.queue_free()
	pagina = Control.new()
	pagina.size = TAMANO
	lienzo.add_child(pagina)
	fondo.texture = textura
	_ocupado = false


func _poner(control: Control, rect: Rect2, padre: Node = null) -> void:
	control.position = rect.position
	control.size = rect.size
	(pagina if padre == null else padre).add_child(control)


func _texto(valor: String, rect: Rect2, tamano: int, padre: Node = null) -> Label:
	var etiqueta := Label.new()
	etiqueta.text = valor
	etiqueta.add_theme_font_override("font", FUENTE)
	etiqueta.add_theme_font_size_override("font_size", tamano)
	etiqueta.add_theme_color_override("font_color", TINTA)
	etiqueta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	etiqueta.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_poner(etiqueta, rect, padre)
	return etiqueta


func _estilo(color: Color, borde: Color, ancho: int = 2, radio: int = 36) -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = color
	estilo.border_color = borde
	estilo.set_border_width_all(ancho)
	estilo.set_corner_radius_all(radio)
	return estilo


func _boton(rect: Rect2, titulo: String, accion: Callable) -> Button:
	var boton := Button.new()
	boton.name = titulo.to_pascal_case().validate_node_name()
	boton.tooltip_text = titulo
	boton.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	boton.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	boton.add_theme_stylebox_override("hover", _estilo(Color(1, 1, 1, 0.12), Color(1, 1, 1, 0.7), 3))
	boton.add_theme_stylebox_override("pressed", _estilo(Color(0, 0.7, 0.7, 0.13), Color("08bbc5"), 4))
	boton.add_theme_stylebox_override("focus", _estilo(Color.TRANSPARENT, Color("08bbc5"), 5))
	boton.add_theme_stylebox_override("disabled", _estilo(Color(0.98, 0.93, 0.79, 0.68), Color.TRANSPARENT, 0))
	boton.pressed.connect(accion)
	_poner(boton, rect)
	return boton


func _retrato(eleccion: String) -> AtlasTexture:
	var textura := AtlasTexture.new()
	textura.atlas = RETRATOS_ATLAS
	var indice := maxi(0, Partidas.ANIMALES.find(eleccion))
	textura.region = Rect2((indice % 3) * 512, floori(indice / 3.0) * 512, 512, 480)
	return textura


func _imagen(textura: Texture2D, rect: Rect2, padre: Node = null) -> TextureRect:
	var imagen := TextureRect.new()
	imagen.texture = textura
	imagen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	imagen.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	imagen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_poner(imagen, rect, padre)
	return imagen


func mostrar_libro() -> void:
	_en_creacion = false
	_nueva_pagina(LIBRO)
	var partidas := Partidas.listar()
	var seleccion: Dictionary = {}
	for datos in partidas:
		if datos.id == elegida:
			seleccion = datos
	if seleccion.is_empty() and not partidas.is_empty():
		seleccion = partidas[0]
		elegida = seleccion.id
	var lista := ScrollContainer.new()
	lista.name = "ListaPartidas"
	lista.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_poner(lista, Rect2(208, 318, 585, 407))
	var filas := VBoxContainer.new()
	filas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	filas.add_theme_constant_override("separation", 12)
	lista.add_child(filas)
	for datos in partidas:
		var fila := Button.new()
		fila.name = "Partida_" + str(datos.id)
		fila.custom_minimum_size = Vector2(560, 122)
		fila.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		fila.tooltip_text = datos.nombre
		var seleccionada: bool = datos.id == elegida
		fila.add_theme_stylebox_override("normal", _estilo(Color("d0f5e9") if seleccionada else Color(1, 0.97, 0.88, 0.7), Color("0bbfc9") if seleccionada else Color("d5ae72"), 6 if seleccionada else 2))
		fila.add_theme_stylebox_override("hover", _estilo(Color("e0f9ed"), Color("0bbfc9"), 4))
		fila.add_theme_stylebox_override("pressed", _estilo(Color("c3f0e6"), Color("0bbfc9"), 6))
		fila.add_theme_stylebox_override("focus", _estilo(Color.TRANSPARENT, Color("0bbfc9"), 5))
		fila.pressed.connect(func() -> void:
			var desplazamiento := lista.scroll_vertical
			elegida = datos.id
			mostrar_libro()
			var nueva_lista := pagina.get_node("ListaPartidas") as ScrollContainer
			nueva_lista.set_deferred("scroll_vertical", desplazamiento)
		)
		filas.add_child(fila)
		var clip := Control.new()
		clip.clip_contents = true
		clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_poner(clip, Rect2(12, 7, 188, 108), fila)
		_imagen(_retrato(datos.animal), Rect2(0, 0, 188, 145), clip)
		var etiqueta := _texto(datos.nombre, Rect2(214, 8, 278, 104), 50 if str(datos.nombre).length() <= 10 else 34, fila)
		etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		if seleccionada:
			var marca := Control.new()
			marca.set_script(MARCA)
			marca.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_poner(marca, Rect2(494, 34, 55, 55), fila)
	if partidas.is_empty():
		var bienvenida := _texto("¡Tu historia comienza aquí!\n\nCrea tu primera partida y elige\nun amigo del bosque.", Rect2(225, 365, 535, 260), 34)
		bienvenida.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_boton(Rect2(230, 735, 525, 80), "Crear nueva partida", mostrar_creacion).grab_focus()
	else:
		_boton(Rect2(230, 735, 525, 80), "Crear nueva partida", mostrar_creacion)
	var animal_vista := "Lumi" if seleccion.is_empty() else str(seleccion.animal)
	var indice := maxi(0, Partidas.ANIMALES.find(animal_vista))
	var hoja := load(SPRITES[indice]) as Texture2D
	var cuerpo := AtlasTexture.new()
	cuerpo.atlas = hoja
	var lado: float = hoja.get_width() / (3.0 if indice in [0, 1, 4, 5] else 2.0)
	cuerpo.region = Rect2(lado * (2 if indice == 0 else (1 if indice == 5 else 0)), 0, lado, lado)
	_imagen(cuerpo, Rect2(1008, 296, 338, 285))
	var titulo := "Tu próxima aventura" if seleccion.is_empty() else "La aventura de " + str(seleccion.nombre)
	var titular := _texto(titulo, Rect2(940, 180, 476, 72), 43 if titulo.length() < 26 else 31)
	titular.tooltip_text = titulo
	var nivel := "Capítulo 1 de 5" if seleccion.is_empty() else "Capítulo %d de 5" % int(seleccion.desbloqueado)
	if not seleccion.is_empty() and seleccion.completados.size() == 5:
		nivel = "¡Historia completada!"
	_texto(nivel, Rect2(1006, 601, 330, 58), 35)
	var ultima := "Tu historia está por comenzar" if seleccion.is_empty() else _ultima_vez(float(seleccion.get("ultima_vez", 0)))
	_texto(ultima, Rect2(943, 661, 376, 35), 25)
	var continuar := _boton(Rect2(925, 706, 508, 110), "Continuar", _continuar)
	continuar.disabled = seleccion.is_empty()
	if not seleccion.is_empty():
		var editar := _boton(Rect2(1318, 663, 103, 34), "Editar perfil", func() -> void: mostrar_creacion(elegida))
		editar.text = "Editar"
		editar.add_theme_font_override("font", FUENTE)
		editar.add_theme_font_size_override("font_size", 23)
		editar.add_theme_color_override("font_color", TINTA)
	_boton(Rect2(29, 856, 205, 67), "Volver", _volver_al_menu)
	mensaje = _texto("", Rect2(310, 817, 1050, 32), 23)
	mensaje.add_theme_color_override("font_color", Color("9c3027"))


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
	_nueva_pagina(CREAR)
	nombre_input = LineEdit.new()
	nombre_input.name = "NombreInput"
	nombre_input.max_length = 24
	nombre_input.placeholder_text = "Tu nombre"
	nombre_input.text = nombre
	nombre_input.add_theme_font_override("font", FUENTE)
	nombre_input.add_theme_font_size_override("font_size", 48)
	nombre_input.add_theme_color_override("font_color", TINTA)
	nombre_input.add_theme_color_override("caret_color", Color("08bbc5"))
	nombre_input.add_theme_color_override("font_placeholder_color", Color("aa927d"))
	nombre_input.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	nombre_input.add_theme_stylebox_override("focus", _estilo(Color.TRANSPARENT, Color("08bbc5"), 3, 12))
	_poner(nombre_input, Rect2(741, 276, 560, 58))
	nombre_input.text_changed.connect(_actualizar_nombre)
	nombre_input.text_submitted.connect(func(_valor: String) -> void: _crear_partida())
	var posiciones := [Rect2(159, 451, 229, 232), Rect2(399, 451, 208, 232),
		Rect2(618, 451, 210, 232), Rect2(839, 451, 208, 232),
		Rect2(1058, 451, 208, 232), Rect2(1278, 451, 213, 232)]
	for i in range(6):
		_boton(posiciones[i], "Elegir " + str(Partidas.ANIMALES[i]), _elegir_animal.bind(Partidas.ANIMALES[i], posiciones[i]))
	borde_animal = Panel.new()
	borde_animal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	borde_animal.add_theme_stylebox_override("panel", _estilo(Color.TRANSPARENT, Color("08c7cf"), 7, 40))
	pagina.add_child(borde_animal)
	marca_animal = Control.new()
	marca_animal.set_script(MARCA)
	marca_animal.size = Vector2(66, 66)
	marca_animal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pagina.add_child(marca_animal)
	vista_animal = _imagen(_retrato(animal), Rect2(574, 729, 92, 71))
	vista_nombre = _texto(nombre, Rect2(676, 730, 156, 70), 35)
	_elegir_animal(animal, posiciones[Partidas.ANIMALES.find(animal)])
	_boton(Rect2(155, 735, 258, 80), "Volver", mostrar_libro)
	var comenzar := _boton(Rect2(970, 724, 542, 94), "Comenzar aventura", _crear_partida)
	if not editando.is_empty():
		var titulo := Panel.new()
		titulo.add_theme_stylebox_override("panel", _estilo(Color("fff2d3"), Color.TRANSPARENT, 0))
		_poner(titulo, Rect2(450, 167, 800, 90))
		_texto("Editar mi aventura", Rect2(455, 173, 790, 72), 65)
		comenzar.add_theme_stylebox_override("normal", _estilo(Color("8bd500"), Color("46790d"), 3, 42))
		comenzar.add_theme_stylebox_override("hover", _estilo(Color("9bdf12"), Color("46790d"), 3, 42))
		comenzar.add_theme_stylebox_override("pressed", _estilo(Color("79bc00"), Color("46790d"), 3, 42))
		comenzar.text = "Guardar cambios"
		comenzar.add_theme_font_override("font", FUENTE)
		comenzar.add_theme_font_size_override("font_size", 42)
		comenzar.add_theme_color_override("font_color", TINTA)
		comenzar.add_theme_color_override("font_hover_color", TINTA)
		comenzar.add_theme_color_override("font_pressed_color", TINTA)
	mensaje = _texto("", Rect2(440, 689, 980, 33), 23)
	mensaje.add_theme_color_override("font_color", Color("9c3027"))
	nombre_input.grab_focus()
	_actualizar_nombre(nombre)


func _elegir_animal(eleccion: String, rect: Rect2) -> void:
	animal = eleccion
	borde_animal.position = rect.position - Vector2(3, 3)
	borde_animal.size = rect.size + Vector2(6, 6)
	marca_animal.position = rect.position + Vector2(rect.size.x - 64, -26)
	vista_animal.texture = _retrato(animal)


func _actualizar_nombre(valor: String) -> void:
	vista_nombre.text = valor.strip_edges()
	vista_nombre.add_theme_font_size_override("font_size", 35 if valor.length() < 9 else 25)
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
	var error := Partidas.crear(nombre_input.text, animal)
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
	var confirmar := ConfirmationDialog.new()
	confirmar.title = "Hasta pronto"
	confirmar.dialog_text = "¿Quieres salir del juego?"
	confirmar.ok_button_text = "Salir"
	confirmar.cancel_button_text = "Seguir aquí"
	confirmar.confirmed.connect(func() -> void: get_tree().quit())
	confirmar.canceled.connect(confirmar.queue_free)
	add_child(confirmar)
	confirmar.popup_centered()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _en_creacion:
			mostrar_libro()
		else:
			_salir()
		get_viewport().set_input_as_handled()
