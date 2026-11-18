extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AudioStreamPlayer2D.volume_db = -20.0
	$AudioStreamPlayer2D.play()
	$Cuento.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_3_pressed() -> void:
		get_tree().change_scene_to_file("res://menu1.tscn")
