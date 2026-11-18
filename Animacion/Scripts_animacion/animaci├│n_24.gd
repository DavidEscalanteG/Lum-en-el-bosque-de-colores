extends CanvasLayer

# 1. Referencias exactas a tus nodos
@onready var lumi: AnimatedSprite2D = $Node2D/Lumi
@onready var boton_siguiente: Button = $Siguiente
@onready var boton_omitir: Button = $Omitir
@onready var boton_volver: Button = $Volver
@onready var audio_cuento: AudioStreamPlayer2D = $Cuento
@onready var audio_cuento2: AudioStreamPlayer2D = $Cuento2
@onready var audio_fondo: AudioStreamPlayer = $Fondo

func _ready() -> void:
	# Ajustes de volumen
	audio_fondo.volume_db = 5
	audio_cuento.volume_db = 30
	audio_cuento2.volume_db = 30
	
	audio_fondo.play()
	
	# Configuración inicial de botones
	boton_siguiente.visible = false 
	boton_volver.visible = false 
	boton_omitir.visible = true 
	
	# Conectar señales de botones
	boton_omitir.pressed.connect(_on_boton_omitir_pressed)
	boton_siguiente.pressed.connect(_on_boton_siguiente_pressed)
	boton_volver.pressed.connect(_on_volver_pressed)

	# Iniciar la secuencia por primera vez
	reproducir_secuencia_cuento()

# --- LÓGICA DE AUDIO Y ANIMACIÓN ---

func reproducir_secuencia_cuento() -> void:
	# Ocultamos botones y REINICIAMOS animación
	boton_volver.visible = false
	boton_siguiente.visible = false
	boton_omitir.visible = true
	
	if lumi:
		lumi.frame = 0    # Empezar desde el inicio
		lumi.play("Lumi") # Activar movimiento
	
	# 1. Reproducir primer audio
	audio_cuento.play()
	
	# 2. Esperar el tiempo definido (5 segundos)
	await get_tree().create_timer(10.0).timeout
	
	# 3. Reproducir segundo audio
	audio_cuento2.play()
	
	# 4. Esperar a que el segundo audio termine
	await audio_cuento2.finished
	
	# 5. DETENER ANIMACIÓN EN FRAME 0
	if lumi:
		lumi.stop()
		lumi.frame = 0
	
	# 6. Mostrar botones de navegación
	boton_volver.visible = true
	boton_siguiente.visible = true
	boton_omitir.visible = false

# --- FUNCIONES DE BOTONES ---

func _on_volver_pressed() -> void:
	# Detenemos audios por si aún están sonando y reiniciamos
	audio_cuento.stop()
	audio_cuento2.stop()
	reproducir_secuencia_cuento()

func _on_boton_omitir_pressed() -> void:
	get_tree().change_scene_to_file("res://celebracion.tscn")

func _on_boton_siguiente_pressed() -> void:
	get_tree().change_scene_to_file("res://celebracion.tscn")

func _on_cerrar_pressed() -> void:
	get_tree().quit()


func _on_minimizar_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)


func _on_omitir_pressed() -> void:
	pass # Replace with function body.


func _on_siguiente_pressed() -> void:
	pass # Replace with function body.
