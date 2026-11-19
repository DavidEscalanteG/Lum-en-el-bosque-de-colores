extends Node2D

func _ready() -> void:
	$AudioStreamPlayer2D.play()

func _on_créditos_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/creditos.tscn")
	$"Créditos/Click".play()
	
func _on_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/mapa_de_niveles.tscn")
	$Jugar/Click2.play()

func _on_instrucciones_pressed() -> void:
	$Instrucciones/Click3.play()
	get_tree().change_scene_to_file("res://Scenes/instrucciones.tscn")


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://ajustes.tscn")
