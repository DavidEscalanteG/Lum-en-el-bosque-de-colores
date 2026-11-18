extends Node2D

func _on_timer_timeout() -> void:
	$Barra.value +=10
	
	if $Barra.value >= $Barra.max_value:
		Global.ronda = 0
		Global.palabras.shuffle()
		get_tree().change_scene_to_file("res://Scenes/juego_1.tscn")
	
	
	
	
	
	
	
	
