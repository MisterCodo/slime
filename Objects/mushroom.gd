extends Node2D

var pickable = false

func _process(delta):
	if pickable and Input.is_action_just_pressed("action"):
		print("picked mushroom")
		queue_free()

func _on_action_box_area_entered(area):
	print("entered mushroom area")
	pickable = true

func _on_action_box_area_exited(area):
	print("exited mushroom area")
	pickable = false
