extends CanvasLayer


func _on_confirm_button_pressed() -> void:
	Events.confirm.emit()
