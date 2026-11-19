extends Node

const CAMPOS_NUMERICOS := ["ronda", "ronda1", "nivel", "palabras_completadas", "errores_actual", "palabras_completadas_silabas", "oraciones_completadas"]
const CAMPOS_LISTAS := ["lista_actual", "lista_actual_silabas", "palabras_usadas_silabas", "lista_actual_oraciones", "oraciones_usadas"]
const CAMPOS_TEXTO := ["ultima_palabra_fallida", "ultima_palabra_fallida_silabas", "ultima_oracion_fallida"]

func serializar_estado() -> Dictionary:
	var estado: Dictionary = {}
	for campo in CAMPOS_NUMERICOS + CAMPOS_TEXTO:
		estado[campo] = get(campo)
	for campo in CAMPOS_LISTAS:
		estado[campo] = get(campo).duplicate(true)
	estado["lista_silabas_seleccionada"] = lista_silabas_seleccionada
	return estado

func restaurar_estado(estado: Dictionary) -> void:
	for campo in CAMPOS_NUMERICOS:
		var valor: Variant = estado.get(campo, 1 if campo == "nivel" else 0)
		if valor is float or valor is int:
			set(campo, clampi(int(valor), 1, 5) if campo == "nivel" else maxi(0, int(valor)))
	for campo in CAMPOS_TEXTO:
		if estado.get(campo) is String:
			set(campo, estado[campo])
	for campo in CAMPOS_LISTAS:
		if estado.get(campo) is Array:
			var validas: Array = []
			for valor in estado[campo]:
				if valor is String:
					validas.append(valor)
			set(campo, validas)
	lista_silabas_seleccionada = bool(estado.get("lista_silabas_seleccionada", false))

func reiniciar_partida() -> void:
	for campo in CAMPOS_NUMERICOS:
		set(campo, 1 if campo == "nivel" else 0)
	for campo in CAMPOS_LISTAS:
		set(campo, [])
	for campo in CAMPOS_TEXTO:
		set(campo, "")
	lista_silabas_seleccionada = false

func reiniciar_capitulo(capitulo: int) -> void:
	nivel = capitulo
	ronda = 0
	errores_actual = 0
	match capitulo:
		1:
			palabras_completadas = 0
			lista_actual = []
			ultima_palabra_fallida = ""
		2:
			palabras_completadas_silabas = 0
			lista_actual_silabas = []
			palabras_usadas_silabas = []
			lista_silabas_seleccionada = false
			ultima_palabra_fallida_silabas = ""
		4:
			oraciones_completadas = 0
			lista_actual_oraciones = []
			oraciones_usadas = []
			ultima_oracion_fallida = ""

func nombre_archivo_sin_acentos(texto: String) -> String:
	var nombre := texto.strip_edges()
	var con_acentos := "áéíóúüñÁÉÍÓÚÜÑ"
	var sin_acentos := "aeiouunAEIOUUN"
	for indice in range(con_acentos.length()):
		nombre = nombre.replace(con_acentos[indice], sin_acentos[indice])
	return nombre

# --- Estado general ---
var ronda := 0
var ronda1 := 0
var nivel := 1

# --- Nivel 1 ---
var palabras_completadas := 0
var errores_actual = 0
@export var palabras: Array[String] = []
@export var palabras2: Array[String] = []
var ultima_palabra_fallida: String = ""
var lista_actual: Array = []

# --- Nivel 2 (sílabas) ---
var lista_silabas_seleccionada: bool = false

@export var palabras_silabas: Array[String] = []
@export var palabras_silabas2: Array[String] = []

var lista_actual_silabas: Array = []
var ultima_palabra_fallida_silabas: String = ""
var palabras_completadas_silabas := 0

# --- NUEVO: control de palabras usadas ---
var palabras_usadas_silabas: Array = []

# --- FUNCIONES GLOBALES ---

# Resetea todas las listas al iniciar un nuevo nivel
func reiniciar_listas():
	palabras_usadas_silabas.clear()
	palabras_completadas_silabas = 0
	ronda = 0
	lista_actual_silabas = []

# Elige aleatoriamente una palabra NO repetida
func obtener_palabra_sin_repetir() -> String:
	var disponibles = lista_actual_silabas.duplicate()
	for usada in palabras_usadas_silabas:
		disponibles.erase(usada)

	if disponibles.is_empty():
		return ""

	var index = randi() % disponibles.size()
	var palabra = disponibles[index]
	palabras_usadas_silabas.append(palabra)
	return palabra

#ORACIONES


# ---------------------------------------------------
# LISTAS DE ORACIONES
# ---------------------------------------------------

@export var oraciones: Array[String] = []

@export var oraciones2: Array[String] = []


# ---------------------------------------------------
# VARIABLES DE CONTROL
# ---------------------------------------------------

# Lista que usarás en cada nivel (puede contener oraciones u oraciones2)
var lista_actual_oraciones: Array = []

# Última oración fallada (por si quieres mostrar retroalimentación)
var ultima_oracion_fallida: String = ""

# Cuántas oraciones ha completado el jugador
var oraciones_completadas = 0

# Oraciones ya usadas, para evitar repeticiones
var oraciones_usadas: Array = []


# ---------------------------------------------------
# FUNCIONES
# ---------------------------------------------------

# Resetea todo al iniciar el nivel
func reiniciar_listas_oraciones():
	oraciones_usadas.clear()
	oraciones_completadas = 0
	ronda = 0
	lista_actual_oraciones.clear()


# Devuelve una oración que NO se haya repetido
func obtener_oracion_sin_repetir() -> String:
	# Si la lista actual está vacía, puedes cargar oraciones o oraciones2
	if lista_actual_oraciones.is_empty():
		lista_actual_oraciones = oraciones.duplicate()

	var disponibles = lista_actual_oraciones.duplicate()

	# Eliminar las ya usadas
	for usada in oraciones_usadas:
		disponibles.erase(usada)

	# Si ya no queda nada
	if disponibles.is_empty():
		return ""

	# Elegir una oración al azar
	var index = randi() % disponibles.size()
	var oracion = disponibles[index]

	# Guardarla como usada
	oraciones_usadas.append(oracion)

	return oracion


# Ejemplo útil: pedir la siguiente oración
func siguiente_oracion():
	var texto = obtener_oracion_sin_repetir()

	if texto == "":
		# Aquí decides qué hacer cuando se acabaron
		print("No quedan oraciones disponibles.")
		return

	print("Nueva oración:", texto)
	return texto
