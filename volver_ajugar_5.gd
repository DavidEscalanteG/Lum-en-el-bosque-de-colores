extends CanvasLayer

@onready var boton_reintentar = $reintentar

func _on_reintentar_pressed() -> void:
	
	get_tree().change_scene_to_file("res://Scenes/juego_1.tscn")
