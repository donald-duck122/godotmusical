extends CanvasLayer
signal startArena1

func _on_start_button_pressed():
	startArena1.emit()
	hide()

func _on_message_timer_timeout():
	$Message.hide()
