extends Node3D

@export var currency: int = 0
@export var current_upgrades = {}

func _ready():
	# Create room structure
	_setup_room()
	
	# Place arcade machines
	place_arcade_machines()
	
	# Spawn player
	var player_scene = preload("res://player.tscn")
	var player = player_scene.instantiate()
	player.position = Vector3(0, 1, 0)
	add_child(player)
	
	# Load saved player data
	load_player_data()
	
	# Update UI with current currency
	update_currency_display()

func _setup_room():
	# Create walls
	create_wall(self, "WallNorth", Vector3(20, 4, 0.5), Vector3(0, 2, -10))
	create_wall(self, "WallSouth", Vector3(20, 4, 0.5), Vector3(0, 2, 10))
	create_wall(self, "WallEast", Vector3(0.5, 4, 20), Vector3(10, 2, 0))
	create_wall(self, "WallWest", Vector3(0.5, 4, 20), Vector3(-10, 2, 0))
	
	# Add lighting
	var main_light = DirectionalLight3D.new()
	main_light.name = "MainLight"
	main_light.rotation_degrees = Vector3(-45, -45, 0)
	main_light.light_energy = 1.5
	add_child(main_light)
	
	# Add point lights
	add_point_light(self, Vector3(5, 3, 5), Color(1, 0.9, 0.8), 1.2)
	add_point_light(self, Vector3(-5, 3, -5), Color(0.8, 0.9, 1), 1.2)

func create_wall(parent_node, name, size, position):
	var wall = MeshInstance3D.new()
	wall.name = name
	wall.mesh = BoxMesh.new()
	wall.mesh.size = size
	wall.position = position
	parent_node.add_child(wall)
	
	# Add collision
	var static_body = StaticBody3D.new()
	wall.add_child(static_body)
	
	var collision_shape = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.extents = Vector3(size.x/2, size.y/2, size.z/2)
	collision_shape.shape = shape
	static_body.add_child(collision_shape)
	
	return wall

func add_point_light(parent_node, position, color, energy=1.0):
	var light = OmniLight3D.new()
	light.position = position
	light.light_color = color
	light.light_energy = energy
	light.omni_range = 8
	parent_node.add_child(light)
	return light

func place_arcade_machines():
	var arcade_scene = preload("res://arcade_machine.tscn")
	
	# Game 1
	var arcade1 = arcade_scene.instantiate()
	arcade1.position = Vector3(-5, 0, -8)
	arcade1.rotation_degrees.y = 180
	arcade1.game_type = "dungeon_crawler"
	arcade1.game_title = "Dungeon Delver"
	arcade1.machine_color = Color(0.8, 0.2, 0.2)
	arcade1.connect("run_started", _on_run_started)
	add_child(arcade1)
	
	# Game 2
	var arcade2 = arcade_scene.instantiate()
	arcade2.position = Vector3(0, 0, -8)
	arcade2.rotation_degrees.y = 180
	arcade2.game_type = "space_shooter"
	arcade2.game_title = "Cosmic Blaster"
	arcade2.machine_color = Color(0.2, 0.2, 0.8)
	arcade2.connect("run_started", _on_run_started)
	add_child(arcade2)
	
	# Game 3
	var arcade3 = arcade_scene.instantiate()
	arcade3.position = Vector3(5, 0, -8)
	arcade3.rotation_degrees.y = 180
	arcade3.game_type = "zombie_survival"
	arcade3.game_title = "Undead Rush"
	arcade3.machine_color = Color(0.2, 0.8, 0.2)
	arcade3.connect("run_started", _on_run_started)
	add_child(arcade3)

# Handle starting a run
func _on_run_started(game_type):
	print("Starting a run: " + game_type)
	# Later you'll transition to the actual game scene
	# get_tree().change_scene_to_file("res://" + game_type + "_game.tscn")

func add_currency(amount):
	currency += amount
	update_currency_display()
	save_player_data()

func update_currency_display():
	var placeholder = 0
	# Will update the UI with current currency
	# $CurrencyLabel.text = "Currency: " + str(currency)

func save_player_data():
	var save_data = {
		"currency": currency,
		"upgrades": current_upgrades
	}
	
	var save_file = FileAccess.open("user://player_data.save", FileAccess.WRITE)
	save_file.store_string(JSON.stringify(save_data))
	save_file.close()

func load_player_data():
	if FileAccess.file_exists("user://player_data.save"):
		var save_file = FileAccess.open("user://player_data.save", FileAccess.READ)
		var data = JSON.parse_string(save_file.get_as_text())
		save_file.close()
		
		if data:
			currency = data.currency
			current_upgrades = data.upgrades
