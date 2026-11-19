extends Control

func _draw() -> void:
	var centro := size / 2.0
	draw_circle(centro, size.x / 2.0, Color.WHITE)
	draw_circle(centro, size.x / 2.0 - 4.0, Color("08bbc5"))
	draw_polyline(PackedVector2Array([centro + Vector2(-13, 0), centro + Vector2(-3, 10), centro + Vector2(16, -12)]), Color.WHITE, 7.0, true)
