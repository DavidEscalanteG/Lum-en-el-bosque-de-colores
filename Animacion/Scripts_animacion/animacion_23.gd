extends CanvasLayer

# 1. Referencias exactas a tus nodos
@onready var lumi: AnimatedSprite2D = $Node2D/Luna
@onready var luna: AnimatedSprite2D = $Node2D/Lumi
@onready var boton_siguiente: Button = $Siguiente
@onready var boton_omitir: Button = $Omitir
@onready var boton_volver: Button = $Volver
@onready var audio_cuento: AudioStreamPlayer2D = $Cuento
@onready var audio_fondo: AudioStreamPlayer = $Fondo

# Variables para controlar los frames de Lumi al final
var alternar_lumi: bool = false
var tiempo_alternar: float = 0.5 # Velocidad del cambio (0.5 segundos)
var cronometro: float = 0.0

func _ready() -> void:
	audio_fondo.volume_db = 5
	audio_cuento.volume_db = 30
	$Fondo.play()
	
	# 2. Configuración inicial de los botones
	boton_siguiente.visible = false
	boton_volver.visible = false 
	boton_omitir.visible = true
	
	# Conexión de botones
	boton_omitir.pressed.connect(_on_boton_omitir_pressed)
	boton_siguiente.pressed.connect(_on_boton_siguiente_pressed)
	if not boton_volver.pressed.is_connected(_on_volver_pressed):
		boton_volver.pressed.connect(_on_volver_pressed)
	
	# 3. Iniciar animaciones iniciales
	if lumi:
		lumi.play("Luna")
	if luna:
		luna.play("Yo")
		
	# 4. Configurar el audio
	if audio_cuento:
		audio_cuento.finished.connect(_on_audio_finished)
		audio_cuento.play()

func _process(delta: float) -> void:
	# Si el audio terminó, hacemos que Lumi alterne solo entre frame 0 y 2
	if alternar_lumi and lumi:
		cronometro += delta
		if cronometro >= tiempo_alternar:
			cronometro = 0.0
			# Lógica de intercambio: si está en 0 pasa a 2, si no, vuelve a 0
			if lumi.frame == 0:
				lumi.frame = 3
			else:
				lumi.frame = 0

# --- FUNCIONES DE LÓGICA ---

func _on_audio_finished() -> void:
	# 1. Detenemos la animación automática de Lumi para controlarla por código
	if lumi:
		lumi.stop()
		alternar_lumi = true # Activamos el bucle en _process
	
	# 2. Configuración de interfaz
	boton_siguiente.visible = true
	boton_omitir.visible = false 
	boton_volver.visible = true
	print("Audio terminado. Lumi alternando frames 0 y 2.")

# --- FUNCIONES DE NAVEGACIÓN ---

func _on_boton_omitir_pressed() -> void:
	get_tree().change_scene_to_file("res://Animacion/pergamino_5.tscn")

func _on_boton_siguiente_pressed() -> void:
	get_tree().change_scene_to_file("res://Animacion/pergamino_5.tscn")

func _on_volver_pressed() -> void:
	# Resetear estado para que vuelva a hablar normalmente al repetir
	alternar_lumi = false
	if lumi:
		lumi.play("Luna")
	if audio_cuento:
		audio_cuento.play()
	boton_volver.visible = false
	boton_siguiente.visible = false
	boton_omitir.visible = true

func _on_cerrar_pressed() -> void:
	get_tree().quit()

func _on_minimizar_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
