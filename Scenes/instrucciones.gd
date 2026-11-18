extends Node2D


func _on_regresar_1_pressed() -> void:
	get_tree().change_scene_to_file("res://menu1.tscn")
	
	$Regresar1/Click.play()
