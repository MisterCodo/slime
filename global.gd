extends Node


var save_file = ""


func save_game():
	var save_game_file = File.new()
	var err = save_game_file.open(save_file, File.WRITE)
	if err != OK:
		push_error("Could not save to file %s. Error %d" % [save_file, err])
		return false
	
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
		save_game_file.store_line(JSON.stringify(node_data))
	save_game_file.close()
	return true


func load_game():
	if save_file.is_empty():
		# New game
		var rand=RandomNumberGenerator.new()
		rand.randomize()
		while true:
			var game_id = randi()
			save_file = "user://save_%d.json" % game_id
			if not save_file_exists(save_file):
				break
			# TODO: maybe put a limit of tries here instead of infinite
		print(save_file)
		return
	
	# Load data from disk
	if not save_file_exists(save_file):
		print("Error, save file not found")
		return # Error! We don't have a save to load.
	
	# We need to revert the game state so we're not cloning objects
	# during loading. We will accomplish this by deleting saveable objects.
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		i.queue_free()
	
	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_game_file = File.new()
	save_game_file.open(save_file, File.READ)
	var node_line = save_game_file.get_line()
	while not node_line.is_empty():
		# Get the saved dictionary from the next line in the save file
		var node_data = JSON.parse_string(node_line)
		node_line = save_game_file.get_line()
		
		# Firstly, we need to create the object and add it to the tree and set its position.
		var new_object = load(node_data["scene_file_path"]).instantiate()
		new_object.add_to_group("Persist")
		get_node(node_data["parent"]).add_child(new_object)
		new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])
		
		# Now we set the remaining variables.
		for i in node_data.keys():
			if i == "scene_file_path" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			new_object.set(i, node_data[i])
		
	save_game_file.close()


func save_file_exists(filename):
	var save_game_file = File.new()
	return save_game_file.file_exists(filename)


func list_save_files():
	# Iterates through files and checks if it's a save file
	var regex = RegEx.new()
	regex.compile("^save_\\d+\\.json$")
	var dir = Directory.new()
	if dir.open("user://") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				var regex_match = regex.search(file_name)
				if regex_match:
					print("Save file: " + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access save files path.")
