extends CanvasLayer

# Referencias a los personajes según tu árbol de nodos
@onready var luna: AnimatedSprite2D = $Node2D/Luna
@onready var lumi: AnimatedSprite2D = $Node2D/Lumi
@onready var bruno: AnimatedSprite2D = $Node2D/Bruno
@onready var tilo: AnimatedSprite2D = $Node2D/Tilo
@onready var nico: AnimatedSprite2D = $Node2D/Nico
@onready var mia: AnimatedSprite2D = $Node2D/Mia
func _ready() -> void:
	# Reproducir música de fondo
	$AudioStreamPlayer2D.play()
	
	# Iniciar animaciones de los personajes
	if luna:
		luna.play("Lumi") # Asegúrate que el nombre de la animación sea correcto
	if lumi:
		lumi.play("Luna")
	if bruno:
		bruno.play("Bruno")
	if tilo:
		tilo.play("Tilo")
	if nico:
		nico.play("Nico")

# --- BOTONES DEL MENÚ ---

# Botón Jugar (Siguiente)
func _on_siguiente_pressed() -> void:
	get_tree().change_scene_to_file("res://login.tscn")

# Botón Instrucciones (Siguiente2)
func _on_siguiente_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/instrucciones.tscn")
	
func _on_siguiente_3_pressed() -> void:
	get_tree().change_scene_to_file("res://creditos.tscn")

func _on_cerrar_pressed() -> void:
	get_tree().quit()


func _on_minimizar_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
