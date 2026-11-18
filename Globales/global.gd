extends Node

# --- Estado general ---
var ronda := 0
var ronda1 := 0
var nivel := 1

# --- Nivel 1 ---
var palabras_completadas := 0
var errores_actual = 0
var palabras = ["ARBOL", "COLORES", "GIRASOL", "PINCEL", "PATO", "GATO", "AZUL", "AMARILLO", "MANZANA", "MANO"]
var palabras2 = ["MESA", "CASA", "LUNA", "PERRO", "FLOR", "CIELO", "NUBE", "RIO", "FUEGO", "SOL"]
var ultima_palabra_fallida: String = ""
var lista_actual: Array = []

# --- Nivel 2 (sílabas) ---
var lista_silabas_seleccionada: bool = false

var palabras_silabas = [
	"GO-MA", "PA-YA-SO", "CA-RRU-SEL", "SOM-BRI-LLA",
	"MU-SI-CO", "MO-NI-TO", "MA-LE-TA", "MU-ÑE-CO",
	"CE-PI-LLO", "PO-LI-CIA", "GUI-TA-RRA", "LAM-PA-RA", "GA-LLE-TA"
]
var palabras_silabas2 = [
	"CA-RA-COL", "SI-RE-NA", "CU-CHA-RA", "MO-CHI-LA", "TO-MA-TE",
	"CO-RA-ZÓN", "PLA-YE-RA", "BU-RRI-TO", "SOM-BRE-RO", "CU-BE-TA",
	"PAN-TA-LÓN", "BO-TO-NES"
]

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

var oraciones = [
	"El niño come una manzana",
	"La mamá lee un libro",
	"El perro corre rápido",
	"La casa es grande",
	"El gato duerme en la cama",
	"La mesa tiene flores",
	"El payaso ríe mucho",
	"La niña salta la cuerda",
	"El auto va muy rápido",
	"La señora cocina sopa"
]

var oraciones2 = [
	"El caballo corre en el campo",
	"La tortuga camina lento",
	"El pájaro vuela alto",
	"La luna brilla en la noche",
	"El niño juega con la pelota",
	"La maestra escribe en el pizarrón",
	"El sol calienta el día",
	"El niño arma un rompecabezas",
	"La niña dibuja una flor",
	"El perro juega con la pelota"
]


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
