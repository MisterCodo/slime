extends Control


func _on_new_game_pressed():
#	get_tree().change_scene_to_file("res://ui/title_screen/scenes/new_game.tscn")
	$Fade.fade()
	# fade emits a signal when done, see _on_fade_fade_finished() func below


func _on_load_pressed():
	get_tree().change_scene_to_file("res://ui/title_screen/scenes/load_game.tscn")


func _on_options_pressed():
	get_tree().change_scene_to_file("res://ui/title_screen/scenes/options.tscn")


func _on_quit_pressed():
	get_tree().quit()


func _on_fade_fade_finished():
	get_tree().change_scene_to_file("res://levels/main.tscn")
