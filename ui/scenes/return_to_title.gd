extends Control


func _on_back_pressed():
	get_tree().change_scene_to_file("res://ui/title_screen.tscn")
