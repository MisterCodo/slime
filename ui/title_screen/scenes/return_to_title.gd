extends Control


func _ready():
	$CenterContainer/VBoxContainer/Back.grab_focus()


func _on_back_pressed():
	get_tree().change_scene_to_file("res://ui/title_screen/title_screen.tscn")
