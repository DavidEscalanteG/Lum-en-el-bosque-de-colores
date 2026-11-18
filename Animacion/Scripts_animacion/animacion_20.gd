extends CanvasLayer

# 1. Referencias exactas a tus nodos
@onready var lumi: AnimatedSprite2D = $Node2D/Lumi
@onready var luna: AnimatedSprite2D = $Node2D/Luna
@onready var boton_siguiente: Button = $Siguiente
@onready var boton_omitir: Button = $Omitir
@onready var boton_volver: Button = $Volver
@onready var audio_cuento: AudioStreamPlayer2D = $Cuento
@onready var audio_fondo: AudioStreamPlayer = $Fondo

# Variables para el control de frames de Luna
var solo_frames_especificos: bool = false
var tiempo_alternar: float = 0.5 # Velocidad del parpadeo/movimiento entre 0 y 2
var cronometro: float = 0.0

func _ready() -> void:
	audio_fondo.volume_db = 5
	audio_cuento.volume_db = 30
	
	audio_fondo.play()
	
	# 2. Configuración inicial de los botones
	boton_siguiente.visible = false 
	boton_volver.visible = false 
	boton_omitir.visible = true    
	
	# 3. Iniciar animaciones normales
	if lumi:
		lumi.play("Lumi")
	if luna:
		luna.play("Luna")
	
	# 4. Configurar el audio y señales
	if audio_cuento:
		audio_cuento.finished.connect(_on_audio_finished)
		audio_cuento.play()
	
	# Conectar botones
	boton_omitir.pressed.connect(_on_boton_omitir_pressed)
	boton_siguiente.pressed.connect(_on_boton_siguiente_pressed)
	boton_volver.pressed.connect(_on_volver_pressed)

func _process(delta: float) -> void:
	# Si el audio ya terminó, forzamos a Luna a alternar solo entre frame 0 y 2
	if solo_frames_especificos and luna:
		cronometro += delta
		if cronometro >= tiempo_alternar:
			cronometro = 0.0
			# Alternar: si es 0 pasa a 2, si es cualquier otro pasa a 0
			if luna.frame == 0:
				luna.frame = 2
			else:
				luna.frame = 0

# --- FUNCIONES DE LÓGICA ---

func _on_audio_finished() -> void:
	# 1. Detener la animación normal de Luna para tomar control manual
	if luna:
		luna.stop() 
		solo_frames_especificos = true # Activamos el bucle del _process
	
	# 2. Mostrar/Ocultar botones
	boton_siguiente.visible = true
	boton_omitir.visible = false 
	boton_volver.visible = true
	print("Audio terminado. Luna ahora solo alterna frames 0 y 2.")

# --- FUNCIONES DE NAVEGACIÓN ---

func _on_boton_omitir_pressed() -> void:
	get_tree().change_scene_to_file("res://Animacion/pergamino_4.tscn")

func _on_boton_siguiente_pressed() -> void:
	get_tree().change_scene_to_file("res://Animacion/pergamino_4.tscn")

func _on_volver_pressed() -> void:
	# Al volver a jugar, reseteamos el estado
	solo_frames_especificos = false
	if luna:
		luna.play("Luna")
	if audio_cuento:
		audio_cuento.play()
	boton_volver.visible = false
	boton_siguiente.visible = false
	boton_omitir.visible = true

func _on_cerrar_pressed() -> void:
	get_tree().quit()

func _on_minimizar_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
