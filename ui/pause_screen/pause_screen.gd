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
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue
		
		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")

		# Store the save dictionary as a new line in the save file.
		save_game.store_line(JSON.stringify(node_data))
	save_game.close()


func _on_quit_button_pressed():
	get_tree().quit()
