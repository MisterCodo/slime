extends Control


var paused: bool = false:
	get:
		return paused
	set(value):
		paused = value
		get_tree().paused = paused
		visible = paused
		if paused:
			$Center/Buttons/Resume.grab_focus()


func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		self.paused = !paused


func _on_resume_pressed():
	self.paused = false


func _on_save_pressed():
	Global.save_game()


func _on_quit_button_pressed():
	get_tree().quit()
