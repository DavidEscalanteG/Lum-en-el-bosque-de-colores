extends CanvasLayer

# 1. Referencias exactas a tus nodos
@onready var lumi: AnimatedSprite2D = $Node2D/Lumi
@onready var luna: AnimatedSprite2D = $Node2D/Luna
@onready var boton_siguiente: Button = $Siguiente
@onready var boton_omitir: Button = $Omitir
@onready var boton_volver: Button = $Volver
@onready var audio_cuento: AudioStreamPlayer2D = $Cuento
@onready var audio_fondo: AudioStreamPlayer = $Fondo

func _ready() -> void:
	audio_fondo.volume_db = 5
	audio_cuento.volume_db = 30 
	$Fondo.play()
	
	# 2. Configuración inicial de los botones
	boton_siguiente.visible = false # Empieza oculto
	boton_omitir.visible = true    # Siempre visible al inicio
	boton_volver.visible =false
	boton_omitir.pressed.connect(_on_boton_omitir_pressed)
	# 3. Iniciar la animación del elefante
	if lumi:
		lumi.play("Lumi")
		if luna:
			luna.play("Luna")
		
	# 4. Configurar el audio
	if audio_cuento:
		# Conectamos la señal para que el botón Siguiente aparezca al terminar
		audio_cuento.finished.connect(_on_audio_finished)
		audio_cuento.play()
	
	# 5. Conectar clics de los botones por código
	
	boton_siguiente.pressed.connect(_on_boton_siguiente_pressed)

# --- FUNCIONES DE NAVEGACIÓN ---

func _on_audio_finished() -> void:
	# Se activa automáticamente cuando el audio termina de sonar
	boton_siguiente.visible = true
	boton_omitir.visible = false # Opcional: ocultamos omitir porque ya terminó
	boton_volver.visible = true
	print("Audio terminado. Aparece botón Siguiente.")

func _on_boton_omitir_pressed() -> void:
	# El botón OMITIR lleva directamente al JUEGO
	print("Omitiendo introducción... Cargando juego_1.tscn")
	get_tree().change_scene_to_file("res://desbloqueado_4.tscn")

func _on_boton_siguiente_pressed() -> void:
	# El botón SIGUIENTE lleva a la ANIMACIÓN 2
	print("Avanzando a animacion_2.tscn")
	get_tree().change_scene_to_file("res://Animacion/animacion_15.tscn")
	
func _on_volver_pressed() -> void:
	if audio_cuento:
		audio_cuento.play()
	boton_volver.visible = false

func _on_cerrar_pressed() -> void:
	get_tree().quit()


func _on_minimizar_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
