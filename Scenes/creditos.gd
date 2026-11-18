extends Node2D

func _on_siguiente_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/sig_credit.tscn")
	$TextureRect/Siguiente/Clic.play()
