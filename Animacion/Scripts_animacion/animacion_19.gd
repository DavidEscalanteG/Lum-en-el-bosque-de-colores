extends CanvasLayer

@onready var audio_fondo: AudioStreamPlayer = $Fondo
@onready var boton_siguiente: Button = $Siguiente
@onready var boton_omitir: Button = $Omitir
# Agregamos los otros botones por si acaso
@onready var boton_cerrar: Button = $Cerrar
@onready var boton_minimizar: Button = $Minimizar

@onready var frames_luna = [
	$Node2D/Luna, $Node2D/Luna2, $Node2D/Luna3, $Node2D/Luna4, $Node2D/Luna5,
	$Node2D/Luna6, $Node2D/Luna7, $Node2D/Luna8, $Node2D/Luna9, $Node2D/Luna10
]

var indice_actual: int = 0
var tiempo_entre_frames: float = 0.12 
var tiempo_acumulado: float = 0.0

func _ready() -> void:
	audio_fondo.volume_db = 5
	
	if audio_fondo:
		audio_fondo.play()
	
	# 2. Visibilidad inicial de Luna
	for i in range(frames_luna.size()):
		if frames_luna[i]:
			frames_luna[i].visible = (i == 0)

	# 3. FORZAR CONEXIÓN DE BOTONES (Esto asegura que funcionen sí o sí)
	if not boton_omitir.pressed.is_connected(_on_boton_omitir_pressed):
		boton_omitir.pressed.connect(_on_boton_omitir_pressed)
	
	if not boton_siguiente.pressed.is_connected(_on_boton_siguiente_pressed):
		boton_siguiente.pressed.connect(_on_boton_siguiente_pressed)
		
	# Conectar cerrar y minimizar si existen los nodos
	if boton_cerrar and not boton_cerrar.pressed.is_connected(_on_cerrar_pressed):
		boton_cerrar.pressed.connect(_on_cerrar_pressed)
	
	if boton_minimizar and not boton_minimizar.pressed.is_connected(_on_minimizar_pressed):
		boton_minimizar.pressed.connect(_on_minimizar_pressed)

	# 4. Asegurar que los botones estén arriba de todo
	boton_siguiente.visible = true 
	boton_omitir.visible = true

func _process(delta: float) -> void:
	tiempo_acumulado += delta
	if tiempo_acumulado >= tiempo_entre_frames:
		tiempo_acumulado = 0.0
		_siguiente_frame_luna()

func _siguiente_frame_luna() -> void:
	if frames_luna[indice_actual]:
		frames_luna[indice_actual].visible = false
	indice_actual = (indice_actual + 1) % frames_luna.size()
	if frames_luna[indice_actual]:
		frames_luna[indice_actual].visible = true

# --- FUNCIONES DE LOS BOTONES ---

func _on_boton_omitir_pressed() -> void:
	# Agregamos un print para debuguear en la consola
	print("Botón Omitir presionado")
	get_tree().change_scene_to_file("res://Animacion/pergamino_4.tscn")

func _on_boton_siguiente_pressed() -> void:
	print("Botón Siguiente presionado")
	get_tree().change_scene_to_file("res://Animacion/animacion_20.tscn")

func _on_cerrar_pressed() -> void:
	get_tree().quit()

func _on_minimizar_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
