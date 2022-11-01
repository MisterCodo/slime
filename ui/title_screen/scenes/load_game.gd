extends Control


func _ready():
	var save_files = Global.list_save_files()
	var placeholder = $CenterContainer/VBoxContainer/VBoxContainer
	var button_pck = preload("res://ui/title_screen/game_overview_button.tscn")
	for save_file in save_files:
		var button = button_pck.instantiate()
		button.game_name = save_file.game_name
		button.datetime = save_file.save_datetime
		button.save_file = save_file.save_file
		placeholder.add_child(button)


func _on_back_pressed():
	get_tree().change_scene_to_file("res://ui/title_screen/title_screen.tscn")
