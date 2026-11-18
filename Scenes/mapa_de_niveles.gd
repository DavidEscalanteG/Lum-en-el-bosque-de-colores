extends Node2D

# 1. Referencia corregida según tu árbol de nodos
@onready var lumi: AnimatedSprite2D = $"Mapa de Niveles/Lumi"

func _ready() -> void:
	# Reproducir música de fondo
	$AudioStreamPlayer2D.play()
	
	# La lógica de Lumi DEBE ir aquí adentro
	if lumi:
		lumi.frame = 0
		lumi.play("Lumi")

# --- FUNCIONES DE LOS BOTONES ---

func _on_jugar_pressed() -> void:
	$Jugar/Clickr.play()
	get_tree().change_scene_to_file("res://desbloqueado.tscn")

func _on_regresar_pressed() -> void:
	$Regresar/Click.play()
	get_tree().change_scene_to_file("res://menu1.tscn")

func _on_jugar_2_pressed() -> void:
	$Jugar2/Clickr.play() # Corregido a Jugar2 según tu árbol
	get_tree().change_scene_to_file("res://desbloquear_nivel_2.tscn")

func _on_jugar_3_pressed() -> void:
	$Jugar3/Clickr.play() # Corregido a Jugar3
	get_tree().change_scene_to_file("res://desbloqueado_3.tscn")

func _on_jugar_4_pressed() -> void:
	$Jugar4/Clickr.play() # Corregido a Jugar4
	get_tree().change_scene_to_file("res://desbloqueado_4.tscn")

func _on_jugar_5_pressed() -> void:
	$Jugar5/Clickr.play() # Corregido a Jugar5
	get_tree().change_scene_to_file("res://desbloqueado_5.tscn")
