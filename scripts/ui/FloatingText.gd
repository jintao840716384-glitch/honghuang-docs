extends Label
class_name FloatingText

func setup(display_text: String, color: Color) -> void:
	text = display_text
	modulate = color
	add_theme_font_size_override("font_size", 22)
	add_theme_constant_override("outline_size", 3)
	add_theme_color_override("font_outline_color", Color(0.04, 0.04, 0.04, 0.95))
	call_deferred("_play")

func _play() -> void:
	position -= Vector2(size.x * 0.5, 0)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 42.0, 0.75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.finished.connect(queue_free)
