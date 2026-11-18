extends CanvasLayer

# 1. Referencias exactas a tus nodos
@onready var lumi: AnimatedSprite2D = $Node2D/Lumi
@onready var luna: AnimatedSprite2D = $Node2D/Luna
@onready var boton_siguiente: Button = $Siguiente
@onready var boton_omitir: Button = $Omitir
@onready var boton_volver: Button = $Volver
@onready var audio_cuento: AudioStreamPlayer2D = $Cuento
@onready var audio_cuentoluna: AudioStreamPlayer2D = $CuentoLuna
@onready var audio_cuento2: AudioStreamPlayer2D = $Cuento2
@onready var audio_fondo: AudioStreamPlayer = $Fondo

func _ready() -> void:
	# Configuración de audio inicial
	audio_fondo.volume_db = -20.0
	audio_cuento.volume_db = 10.0
	audio_cuentoluna.volume_db = 10.0
	audio_cuento2.volume_db = 10.0
	audio_fondo.play()
	
	# Configuración inicial de botones
	boton_siguiente.visible = false 
	boton_volver.visible = false
	boton_omitir.visible = true
	
	# Conectar señales de botones
	boton_omitir.pressed.connect(_on_boton_omitir_pressed)
	boton_siguiente.pressed.connect(_on_boton_siguiente_pressed)
	boton_volver.pressed.connect(_on_volver_pressed)

	# Iniciar la secuencia narrativa
	reproducir_secuencia_completa()

# --- LÓGICA DE AUDIO Y ANIMACIÓN ---

func reproducir_secuencia_completa() -> void:
	# 1. Resetear botones y asegurar que ambos estén en Frame 0
	boton_volver.visible = false
	boton_siguiente.visible = false
	boton_omitir.visible = true
	
	lumi.stop()
	lumi.frame = 0
	luna.stop()
	luna.frame = 0
	
	# 2. PRIMERO: LUMI habla y se mueve
	if luna:
		luna.play("Luna")
	audio_cuento.play()
	
	# Esperar a que termine el audio de Lumi
	await audio_cuento.finished
	
	# Detener a Lumi en frame 0
	if luna:
		luna.stop()
		luna.frame = 1
	
	# 3. SEGUNDO: LUNA habla (Parte 1: CuentoLuna)
	if lumi:
		lumi.play("Lumi")
	audio_cuentoluna.play()
	
	# Esperar a que termine el primer audio de Luna
	await audio_cuentoluna.finished
	
	# 4. LUNA continúa moviéndose (Parte 2: Cuento2)
	# No ponemos "stop" para que la animación de Luna siga fluida entre audios
	audio_cuento2.play()
	
	# Esperar a que termine el audio final
	await audio_cuento2.finished
	
	# 5. ESTADO FINAL: Luna se detiene y aparecen los botones
	if lumi:
		lumi.stop()
		lumi.frame = 0
	
	# Ambos quedan en frame 0
	lumi.frame = 0
	luna.frame = 1
	
	boton_siguiente.visible = true
	boton_volver.visible = true
	boton_omitir.visible = false

# --- FUNCIONES DE NAVEGACIÓN ---

func _on_boton_omitir_pressed() -> void:
	_detener_todo()
	get_tree().change_scene_to_file("res://Animacion/Animacion_expliacaciones/pergamino_2.tscn")

func _on_boton_siguiente_pressed() -> void:
	_detener_todo()
	get_tree().change_scene_to_file("res://Animacion/Animacion_expliacaciones/pergamino_2.tscn")
	
func _on_volver_pressed() -> void:
	_detener_todo()
	# Reiniciar la lógica completa
	reproducir_secuencia_completa()

func _detener_todo() -> void:
	audio_cuento.stop()
	audio_cuentoluna.stop()
	audio_cuento2.stop()
func _on_cerrar_pressed() -> void:
	get_tree().quit()


func _on_minimizar_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
