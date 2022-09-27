extends Control

func _on_new_game_pressed():
	get_tree().change_scene_to_file("res://UI/Scenes/new_game.tscn")

func _on_continue_pressed():
	$Fade.fade()

func _on_options_pressed():
	get_tree().change_scene_to_file("res://UI/Scenes/options.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _on_fade_fade_finished():
	get_tree().change_scene_to_file("res://Levels/main.tscn")
