extends ColorRect


signal fade_finished


func fade():
	$AnimationPlayer.play("fade")


func _on_animation_player_animation_finished(_anim_name):
	emit_signal("fade_finished")
