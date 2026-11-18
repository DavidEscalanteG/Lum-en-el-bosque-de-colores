extends CanvasLayer






func _on_button_pressed() -> void:
	if Global.ronda != Global.palabras.size():
		get_tree().change_scene_to_file("res://Scenes/juego_1.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/menú.tscn")
