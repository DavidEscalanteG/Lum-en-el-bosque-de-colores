extends Node2D


func _on_regresar_1_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
	$TextureRect/Regresar1/Click3.play()
