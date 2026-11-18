extends CanvasLayer

# 1. Referencias a los nodos
@onready var boton_comenzar: Button = $Comenzar
@onready var boton_altavoz: Button = $Altavoz # Asegúrate de que el nodo se llame así
@onready var audio_cuento: AudioStreamPlayer2D = $Cuento
@onready var audio_fondo: AudioStreamPlayer = $Fondo

func _ready() -> void:
	# Configuración de audio fondo
	audio_fondo.volume_db = -20.0
	audio_fondo.play()
	
	# El botón comenzar aparece siempre desde el inicio
	boton_comenzar.visible = true
	
	# Conectar señales de los botones
	boton_altavoz.pressed.connect(_on_boton_altavoz_pressed)
	boton_comenzar.pressed.connect(_on_comenzar_pressed)

# --- LÓGICA DEL ALTAVOZ ---

func _on_boton_altavoz_pressed() -> void:
	# Si el audio ya está sonando, lo reinicia. Si no, lo reproduce.
	if audio_cuento.playing:
		audio_cuento.stop()
	
	audio_cuento.play()
	print("Reproduciendo audio del cuento desde el altavoz.")

# --- NAVEGACIÓN Y VENTANA ---

func _on_comenzar_pressed() -> void:
	# Detenemos los audios antes de cambiar de escena
	audio_cuento.stop()
	get_tree().change_scene_to_file("res://Scenes/Nivel2.tscn")

func _on_cerrar_pressed() -> void:
	get_tree().quit()

func _on_minimizar_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
