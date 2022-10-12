extends Node


class SaveFileOverview:
	var game_name = ""
	var save_file = "user://save_2697073232.json"
	var save_datetime = Time.get_datetime_string_from_system(false, false)
	
	
	func save():
		var save_dict = {
			"game_name": game_name,
			"save_file": save_file,
			"save_datetime": save_datetime
		}
		return save_dict
	
	
	func stow(data):
		game_name = data["game_name"]
		save_file = data["save_file"]
		save_datetime = data["save_datetime"]


var save_file_overview = SaveFileOverview.new()


func save_game():
	var save_game_file = File.new()
	var err = save_game_file.open(save_file_overview.save_file, File.WRITE)
	if err != OK:
		push_error("Could not save to file %s. Error %d" % [save_file_overview.save_file, err])
		return false
	
	# Add game overview details
	var overview_data = save_file_overview.save()
	save_game_file.store_line(JSON.stringify(overview_data))
	
	# Add nodes details for all persistent objects
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
	# Generate new game if no save_file defined yet.
	if save_file_overview.save_file.is_empty():
		save_file_overview.game_name = "Alice" #TODO: assign proper value when a new game is created.
		var rand=RandomNumberGenerator.new()
		rand.randomize()
		while true:
			var game_id = randi()
			save_file_overview.save_file = "user://save_%d.json" % game_id
			if not save_file_exists(save_file_overview.save_file):
				break
			# TODO: maybe put a limit of tries here instead of infinite
		print(save_file_overview.save_file)
		return true
	
	# Load game data from disk and set game status.
	var game_overview = load_game_from_file(save_file_overview.save_file, false)
	if game_overview == null:
		return false
	
	save_file_overview = game_overview
	return true


func save_file_exists(filename):
	var save_game_file = File.new()
	return save_game_file.file_exists(filename)


func sort_save_files_descending(a, b):
	if Time.get_unix_time_from_datetime_string(a.save_datetime) > Time.get_unix_time_from_datetime_string(b.save_datetime):
		return true
	return false


func list_save_files():
	# Iterates through files and checks if it's a save file.
	var dir = Directory.new()
	var err = dir.open("user://")
	if err != OK:
		push_error("An error occurred when trying to access save files path. Error %d" % [err])
		return
	
	var regex = RegEx.new()
	regex.compile("^save_\\d+\\.json$")
	var save_files = []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			var regex_match = regex.search(file_name)
			if regex_match:
				print("Save file: " + file_name)
				var tmp = load_game_from_file("user://" + file_name, true)
				if tmp != null:
					save_files.append(tmp)
		file_name = dir.get_next()
	save_files.sort_custom(sort_save_files_descending)
	return save_files


func load_game_from_file(file_name, only_overview):
	# Verify save file actually exists on disk.
	if not save_file_exists(file_name):
		push_error("Error, save file not found")
		return null
	
	# Open save file.
	var save_game_file = File.new()
	var err = save_game_file.open(file_name, File.READ)
	if err != OK:
		push_error("Could not open save file %s. Error %d" % [file_name, err])
		return null
	
	# Load the overview details.
	var node_line = save_game_file.get_line()
	if node_line.is_empty():
		push_error("Empty save file %s" % [file_name])
		save_game_file.close()
		return null
	
	var game_overview = SaveFileOverview.new()
	game_overview.stow(JSON.parse_string(node_line))
	
	# If function call only asks for overview details then don't set the game status.
	if only_overview:
		save_game_file.close()
		return game_overview
	
	# Revert game state so we're not cloning objects during loading.
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		i.queue_free()
	
	# Process remaining lines to restore persistent objects.
	node_line = save_game_file.get_line()
	while not node_line.is_empty():
		# Get the saved dictionary from the next line in the save file.
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
	return game_overview
