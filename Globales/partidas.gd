extends Node
## Un archivo por aventura; el nombre nunca se utiliza como identificador.

signal guardado_fallido(mensaje: String)
signal partidas_actualizadas

const VERSION := 1
const ANIMALES := ["Lumi", "Luna", "Mia", "Nico", "Tilo", "Bruno"]
const ENTRADAS := [
	"res://desbloqueado.tscn", "res://desbloquear_nivel_2.tscn",
	"res://desbloqueado_3.tscn", "res://desbloqueado_4.tscn", "res://desbloqueado_5.tscn"
]
const JUEGOS := [
	"res://Scenes/juego_1.tscn", "res://Scenes/Nivel2.tscn", "res://nivel_3.tscn",
	"res://nivel_4.tscn", "res://nivel_5.tscn"
]

var directorio := "user://partidas"
var activa: Dictionary = {}
var ultimo_error := ""
var modo_desarrollador := "--modo-desarrollador" in OS.get_cmdline_user_args()
var _escenas: Dictionary = {}
@onready var _volver: Button = $Interfaz/VolverAPerfiles
@onready var _aviso: Label = $Interfaz/AvisoGuardado


func _ready() -> void:
	_registrar_escenas()
	get_tree().scene_changed.connect(_al_cambiar_escena)
	guardado_fallido.connect(_mostrar_error)
	_volver.pressed.connect(volver_a_perfiles)


func _registrar_escenas() -> void:
	for i in range(5):
		_escenas[ENTRADAS[i]] = i + 1
		_escenas[JUEGOS[i]] = i + 1
	var grupos := [["", "_2", "_3", "_4"], ["_5", "_6", "_7", "_8"],
		["_9", "_10", "_11", "_12"], ["_14", "_15", "_16", "_17", "_18", "_19", "_20"],
		["_21", "_22", "_23", "_24"]]
	for i in range(grupos.size()):
		for sufijo in grupos[i]:
			_escenas["res://Animacion/animacion%s.tscn" % sufijo] = i + 1
	_escenas["res://Animacion/animacio_13.tscn"] = 3
	for i in range(5):
		var pergamino := "pegamino_3" if i == 2 else "pergamino_%d" % (i + 1)
		_escenas["res://Animacion/Animacion_expliacaciones/%s.tscn" % pergamino] = i + 1
		_escenas["res://Animacion/%s.tscn" % pergamino] = i + 1
	_escenas.merge({
		"res://Scenes/Felicidades.tscn": 1, "res://volver_a_jugar.tscn": 1,
		"res://felicidades_nivel_2.tscn": 2, "res://volverajugar_2.tscn": 2,
		"res://resultados_2.tscn": 3, "res://felicidades_4.tscn": 4,
		"res://volver_ajugar_3.tscn": 4, "res://resultados.tscn": 5,
		"res://celebracion.tscn": 5
	})


func _ruta(id: String) -> String:
	return directorio.path_join(id + ".json")


func _id_valido(id: String) -> bool:
	return id.length() == 32 and id.is_valid_hex_number(false)


func _validar(datos: Variant) -> bool:
	if not datos is Dictionary:
		return false
	if datos.get("version") != VERSION or not _id_valido(str(datos.get("id", ""))):
		return false
	if not datos.get("nombre") is String or not nombre_valido(datos.nombre):
		return false
	if not datos.get("animal") in ANIMALES:
		return false
	if not datos.get("desbloqueado") is float and not datos.get("desbloqueado") is int:
		return false
	if int(datos.desbloqueado) < 1 or int(datos.desbloqueado) > 5:
		return false
	if not datos.get("completados") is Array or not datos.get("estado") is Dictionary:
		return false
	if not datos.get("actividad") is Dictionary or not datos.get("checkpoint") is String:
		return false
	if not _escenas.has(datos.checkpoint) or not ResourceLoader.exists(datos.checkpoint):
		return false
	if not (datos.get("ultima_vez") is int or datos.get("ultima_vez") is float):
		return false
	if not (datos.get("capitulo") is int or datos.get("capitulo") is float):
		return false
	if int(datos.capitulo) != int(_escenas[datos.checkpoint]):
		return false
	if not datos.get("capitulos", {}) is Dictionary:
		return false
	for clave in datos.get("capitulos", {}):
		var progreso: Variant = datos.capitulos[clave]
		if not str(clave) in ["1", "2", "3", "4", "5"] or not progreso is Dictionary:
			return false
		if not progreso.get("checkpoint") is String or not _escenas.has(progreso.checkpoint):
			return false
		if not progreso.get("estado") is Dictionary or int(_escenas[progreso.checkpoint]) != int(clave):
			return false
	for clave in datos.actividad:
		if not str(clave) in ["1", "2", "3", "4", "5"] or not datos.actividad[clave] is Dictionary:
			return false
		var actividad: Dictionary = datos.actividad[clave]
		for campo in ["palabra", "oracion"]:
			if actividad.has(campo) and (not actividad[campo] is String or str(actividad[campo]).is_empty()):
				return false
		for campo in ["rondas", "correctas", "indice_imagen", "pregunta"]:
			if actividad.has(campo) and not (actividad[campo] is int or actividad[campo] is float):
				return false
	for numero in datos.completados:
		if not (numero is float or numero is int) or int(numero) < 1 or int(numero) > 5:
			return false
	return true


func _leer(ruta: String) -> Dictionary:
	if not FileAccess.file_exists(ruta):
		return {}
	var archivo := FileAccess.open(ruta, FileAccess.READ)
	if archivo == null:
		return {}
	var lector := JSON.new()
	if lector.parse(archivo.get_as_text()) != OK:
		return {}
	var datos: Variant = lector.data
	return datos if _validar(datos) else {}


func listar() -> Array[Dictionary]:
	var partidas: Array[Dictionary] = []
	var carpeta := DirAccess.open(directorio)
	if carpeta == null:
		return partidas
	var ids: Dictionary = {}
	for archivo in carpeta.get_files():
		var id := archivo.trim_suffix(".bak").trim_suffix(".json")
		if (archivo.ends_with(".json") or archivo.ends_with(".json.bak")) and _id_valido(id):
			ids[id] = true
	for id in ids:
		var datos := _leer(_ruta(id))
		if datos.is_empty() or datos.get("id") != id:
			datos = _leer(_ruta(id) + ".bak")
		if not datos.is_empty() and datos.id == id:
			partidas.append(datos)
	partidas.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("ultima_vez", 0)) > float(b.get("ultima_vez", 0)))
	return partidas


func nombre_valido(nombre: String) -> bool:
	var limpio := nombre.strip_edges()
	if limpio.is_empty() or limpio.length() > 24:
		return false
	for letra in limpio:
		if letra.unicode_at(0) < 32:
			return false
	return true


func crear(nombre: String, animal: String) -> String:
	if not nombre_valido(nombre) or not animal in ANIMALES:
		return "Escribe un nombre de 1 a 24 caracteres y elige un animal."
	var anterior := activa.duplicate(true)
	var estado_anterior := Global.serializar_estado()
	Global.reiniciar_partida()
	activa = {
		"version": VERSION, "id": Crypto.new().generate_random_bytes(16).hex_encode(),
		"nombre": nombre.strip_edges(), "animal": animal,
		"creada": Time.get_unix_time_from_system(), "ultima_vez": Time.get_unix_time_from_system(),
		"desbloqueado": 1, "completados": [], "capitulo": 1,
		"checkpoint": ENTRADAS[0], "estado": Global.serializar_estado(), "actividad": {}, "capitulos": {}
	}
	if not guardar():
		activa = anterior
		Global.restaurar_estado(estado_anterior)
		return ultimo_error
	return ""


func seleccionar(id: String) -> bool:
	if not _id_valido(id):
		return false
	var datos := _leer(_ruta(id))
	if datos.is_empty() or datos.get("id") != id:
		datos = _leer(_ruta(id) + ".bak")
	if datos.is_empty() or datos.id != id:
		_error("No pudimos abrir esta partida. Tu archivo se ha conservado.")
		return false
	Global.reiniciar_partida()
	activa = datos
	# JSON representa los números como float; las claves de capítulos siempre son enteras.
	activa.capitulo = int(activa.capitulo)
	activa.desbloqueado = int(activa.desbloqueado)
	Global.restaurar_estado(activa.estado)
	return true


func editar(id: String, nombre: String, animal: String) -> bool:
	if not nombre_valido(nombre) or not animal in ANIMALES:
		return false
	var anterior := activa.duplicate(true)
	var estado_anterior := Global.serializar_estado()
	if not seleccionar(id):
		return false
	activa.nombre = nombre.strip_edges()
	activa.animal = animal
	if guardar(false):
		return true
	activa = anterior
	Global.reiniciar_partida()
	Global.restaurar_estado(estado_anterior)
	return false


func guardar(actualizar_fecha: bool = true) -> bool:
	if activa.is_empty():
		return true
	activa.estado = Global.serializar_estado()
	if not activa.has("capitulos"):
		activa.capitulos = {}
	activa.capitulos[str(int(activa.capitulo))] = {"checkpoint": activa.checkpoint, "estado": activa.estado.duplicate(true)}
	if actualizar_fecha:
		activa.ultima_vez = Time.get_unix_time_from_system()
	var carpeta := ProjectSettings.globalize_path(directorio)
	if DirAccess.make_dir_recursive_absolute(carpeta) != OK:
		return _error("No se pudo crear la carpeta de partidas.")
	var ruta := ProjectSettings.globalize_path(_ruta(activa.id))
	var temporal := ruta + ".tmp"
	var archivo := FileAccess.open(temporal, FileAccess.WRITE)
	if archivo == null:
		return _error("No se pudo guardar tu aventura. Revisa el espacio disponible.")
	archivo.store_string(JSON.stringify(activa, "\t"))
	archivo.flush()
	var resultado := archivo.get_error()
	archivo.close()
	if resultado != OK:
		return _error("No se pudo terminar el guardado. Conservamos la copia anterior.")
	# Nunca sustituir una copia sana por un archivo dañado.
	if not _leer(ruta).is_empty():
		if DirAccess.copy_absolute(ruta, ruta + ".bak") != OK:
			return _error("No se pudo respaldar tu partida. Conservamos el archivo anterior.")
	if DirAccess.rename_absolute(temporal, ruta) != OK:
		return _error("No se pudo actualizar tu partida. Conservamos la copia anterior.")
	ultimo_error = ""
	partidas_actualizadas.emit()
	return true


func _error(mensaje: String) -> bool:
	ultimo_error = mensaje
	guardado_fallido.emit(mensaje)
	return false


func guardar_punto(ruta: String) -> bool:
	if activa.is_empty():
		return true
	if not _escenas.has(ruta):
		return false
	activa.checkpoint = ruta
	activa.capitulo = _escenas[ruta]
	return guardar()


func guardar_actividad(capitulo: int, datos: Dictionary) -> void:
	if activa.is_empty():
		return
	activa.actividad[str(capitulo)] = datos.duplicate(true)
	guardar_punto(JUEGOS[capitulo - 1])


func obtener_actividad(capitulo: int) -> Dictionary:
	if activa.is_empty():
		return {}
	return activa.actividad.get(str(capitulo), {}).duplicate(true)


func limpiar_actividad(capitulo: int) -> void:
	if not activa.is_empty():
		activa.actividad.erase(str(capitulo))


func completar_capitulo(capitulo: int) -> void:
	if activa.is_empty():
		return
	if not capitulo in activa.completados:
		activa.completados.append(capitulo)
	activa.desbloqueado = maxi(int(activa.desbloqueado), mini(5, capitulo + 1))
	guardar()


func puede_jugar(capitulo: int) -> bool:
	if modo_desarrollador or (activa.is_empty() and OS.has_feature("editor")):
		return true
	return not activa.is_empty() and capitulo >= 1 and capitulo <= int(activa.desbloqueado)


func abrir_capitulo(capitulo: int) -> void:
	if not puede_jugar(capitulo):
		return
	if not activa.is_empty():
		if not guardar(false):
			return
		var progreso: Dictionary = activa.get("capitulos", {}).get(str(capitulo), {})
		if not progreso.is_empty() and not capitulo in activa.completados:
			Global.reiniciar_partida()
			Global.restaurar_estado(progreso.estado)
			guardar_punto(progreso.checkpoint)
			get_tree().change_scene_to_file(progreso.checkpoint)
			return
	Global.reiniciar_capitulo(capitulo)
	limpiar_actividad(capitulo)
	guardar_punto(ENTRADAS[capitulo - 1])
	get_tree().change_scene_to_file(ENTRADAS[capitulo - 1])


func continuar() -> void:
	if not activa.is_empty():
		# Una historia terminada vuelve al mapa para elegir qué capítulo repetir.
		if activa.completados.size() == 5:
			get_tree().change_scene_to_file("res://Scenes/mapa_de_niveles.tscn")
		else:
			get_tree().change_scene_to_file(activa.checkpoint)


func volver_a_perfiles() -> void:
	if not guardar():
		return
	activa = {}
	Global.reiniciar_partida()
	get_tree().change_scene_to_file("res://login.tscn")


func _al_cambiar_escena() -> void:
	var escena := get_tree().current_scene
	if escena == null:
		return
	var ruta := escena.scene_file_path
	_volver.visible = not activa.is_empty() and ruta != "res://login.tscn" and ruta != "res://Scenes/inicio.tscn"
	if not activa.is_empty():
		_volver.text = "Mis aventuras · " + str(activa.nombre)
	if _escenas.has(ruta):
		Global.nivel = int(_escenas[ruta])
		guardar_punto(ruta)


func _mostrar_error(mensaje: String) -> void:
	if is_instance_valid(_aviso):
		_aviso.text = mensaje


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_CLOSE_REQUEST:
		guardar(false)


func _exit_tree() -> void:
	guardar(false)
