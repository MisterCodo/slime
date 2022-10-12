extends Button


var game_name: String = "":
	get:
		return game_name
	set(value):
		game_name = value
		$HBoxContainer/Name.text = game_name


var datetime: String = "":
	get:
		return datetime
	set(value):
		datetime = value
		$HBoxContainer/Datetime.text = datetime


var save_file: String = "":
	get:
		return save_file
	set(value):
		save_file = value


func _on_game_overview_pressed():
	print("loading save file: " + save_file)
	Global.save_file_overview.save_file = save_file
	get_tree().change_scene_to_file("res://levels/main.tscn")
