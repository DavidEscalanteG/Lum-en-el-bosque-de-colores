extends Node2D

# 1. Referencia corregida según tu árbol de nodos
@onready var lumi: AnimatedSprite2D = $Lumi

func _ready() -> void:
	for i in range(5):
		var boton := get_node("Jugar" + ("" if i == 0 else str(i + 1))) as Button
		boton.disabled = not Partidas.puede_jugar(i + 1)
		boton.text = "Capítulo %d" % (i + 1) if not boton.disabled else "Completa el capítulo anterior"
		boton.tooltip_text = "Continuar o volver a jugar este capítulo" if not boton.disabled else "Este capítulo todavía no está disponible"
	# Reproducir música de fondo
	$AudioStreamPlayer2D.play()
	
	# La lógica de Lumi DEBE ir aquí adentro
	if lumi:
		lumi.frame = 0
		lumi.play("Lumi")

# --- FUNCIONES DE LOS BOTONES ---

func _on_jugar_pressed() -> void:
	$Jugar/Clickr.play()
	Partidas.abrir_capitulo(1)

func _on_regresar_pressed() -> void:
	$Regresar/Click.play()
	get_tree().change_scene_to_file("res://menu1.tscn")

func _on_jugar_2_pressed() -> void:
	$Jugar2/Clickr.play() # Corregido a Jugar2 según tu árbol
	Partidas.abrir_capitulo(2)

func _on_jugar_3_pressed() -> void:
	$Jugar3/Clickr.play() # Corregido a Jugar3
	Partidas.abrir_capitulo(3)

func _on_jugar_4_pressed() -> void:
	$Jugar4/Clickr.play() # Corregido a Jugar4
	Partidas.abrir_capitulo(4)

func _on_jugar_5_pressed() -> void:
	$Jugar5/Clickr.play() # Corregido a Jugar5
	Partidas.abrir_capitulo(5)
