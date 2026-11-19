class_name PreguntaLumi
extends Resource
## Cada pregunta y sus tres respuestas se editan desde nivel_5.tscn.

@export_multiline var texto: String = ""
@export var opciones: Array[String] = []
## Posición de la respuesta correcta en Opciones, antes de mezclar (1, 2 o 3).
@export_range(1, 3) var correcta: int = 1
