extends CanvasLayer
signal startGame

func showMessage(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func showGameOver():
	showMessage("Game Over")
	await $MessageTimer.timeout
	
	$Message.text = "Dodge The \nCreeps!"
	$Message.show()
	
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()

func updateScore(score):
	$ScoreLabel.text = str(score)



func _on_start_button_pressed():
	$StartButton.hide()
	startGame.emit()


func _on_message_timer_timeout():
	$Message.hide()
