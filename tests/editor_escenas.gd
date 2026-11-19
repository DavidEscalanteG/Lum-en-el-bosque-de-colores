extends SceneTree
## Verifica las escenas SIN ejecutar _ready: deben contener su interfaz y recursos.

var fallos := 0
var comprobaciones := 0
var escenas := 0

func _initialize() -> void:
	call_deferred("_ejecutar")

func comprobar(valor: bool, descripcion: String) -> void:
	comprobaciones += 1
	if not valor:
		fallos += 1
		printerr("FALLO: " + descripcion)

func revisar_carpeta(ruta: String) -> void:
	for archivo in DirAccess.get_files_at(ruta):
		if not archivo.ends_with(".tscn"):
			continue
		var recurso := load(ruta.path_join(archivo)) as PackedScene
		comprobar(recurso != null and recurso.can_instantiate(), "Se carga " + archivo)
		if recurso == null or not recurso.can_instantiate():
			continue
		var nodo := recurso.instantiate()
		comprobar(nodo != null, "Se instancia " + archivo)
		nodo.free()
		escenas += 1
	for carpeta in DirAccess.get_directories_at(ruta):
		if not carpeta.begins_with(".") and carpeta != "docs":
			revisar_carpeta(ruta.path_join(carpeta))

func _ejecutar() -> void:
	revisar_carpeta("res://")
	var perfiles: Node = load("res://login.tscn").instantiate()
	for ruta in ["Lienzo/Libro/Fondo", "Lienzo/Libro/ListaPartidas/Filas/EjemploPartida/Nombre", "Lienzo/Libro/Continuar", "Lienzo/Crear/NombreInput", "Lienzo/Crear/MarcaAnimal", "ConfirmarSalida"]:
		comprobar(perfiles.has_node(ruta), "Existe en el editor: " + ruta)
	comprobar(perfiles.get("retratos").size() == 6 and perfiles.get("cuerpos").size() == 6, "Los seis personajes ya tienen recursos")
	comprobar(perfiles.get_node("Lienzo/Crear/ElegirBruno").is_connected("pressed", Callable(perfiles, "_elegir_animal")), "Las señales de los controles quedan guardadas")
	perfiles.free()
	var global := root.get_node("Global")
	for datos in [
		["res://Scenes/juego_1.tscn", "ImagenPalabra", global.palabras + global.palabras2],
		["res://Scenes/Nivel2.tscn", "ImagenPalabra", global.palabras_silabas + global.palabras_silabas2],
		["res://nivel_3.tscn", "ContenedorMemoria/ImagenMostrar", []],
		["res://Scenes/menu.tscn", "ContenedorMemoria/ImagenMostrar", []],
		["res://nivel_4.tscn", "ImagenOracion", global.oraciones + global.oraciones2]
	]:
		var nivel: Node = load(datos[0]).instantiate()
		comprobar(nivel.get_node(datos[1]).texture != null, "La imagen se ve sin ejecutar: " + datos[0])
		if nivel.has_node("ItemList"):
			var opciones: ItemList = nivel.get_node("ItemList")
			comprobar(opciones.item_count > 0 and not opciones.get_item_text(0).is_empty(), "Las opciones también se ven sin ejecutar: " + datos[0])
		var palabras: Array = datos[2] if not datos[2].is_empty() else nivel.get("palabras")
		for palabra in palabras:
			var clave: String = palabra if nivel.has_node("ContenedorMemoria") else global.nombre_archivo_sin_acentos(palabra.replace("-", "")).to_upper()
			comprobar(nivel.get("imagenes").get(clave) is Texture2D, "Imagen configurada: " + palabra)
		nivel.free()
	var final: Node = load("res://nivel_5.tscn").instantiate()
	comprobar(final.get("preguntas").size() == 13, "Se conservan las trece preguntas")
	for pregunta in final.get("preguntas"):
		comprobar(not pregunta.texto.is_empty() and pregunta.opciones.size() == 3 and pregunta.correcta >= 1 and pregunta.correcta <= 3, "Pregunta completa en el Inspector")
	comprobar(not final.get_node("Pregunta").text.is_empty(), "El cuestionario tiene una vista previa")
	final.free()
	print("RESULTADO EDITOR: %d escenas, %d comprobaciones, %d fallos" % [escenas, comprobaciones, fallos])
	quit(0 if fallos == 0 else 1)
