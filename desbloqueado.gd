extends CanvasLayer

func _on_timer_timeout() -> void:
	$Barra.value +=10
	
	if $Barra.value >= $Barra.max_value:
		get_tree().change_scene_to_file("res://Animacion/animacion.tscn")
	
	
	
	
