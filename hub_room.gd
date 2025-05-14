extends Node3D

@export var currency: int = 0
@export var current_upgrades = {}

func _ready():
	# Create room structure
	_setup_room()

	# Set up UI
	_setup_ui()

	# Place arcade machines
	place_arcade_machines()

	# Add upgrade station
	add_upgrade_station()

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
	
# Add this function in hub_room.gd to setup all required UI elements:
func _setup_ui():
	# Create a CanvasLayer for UI
	var canvas_layer = CanvasLayer.new()
	canvas_layer.name = "UI"
	add_child(canvas_layer)

	# Create a Control node for the HUD
	var hud = Control.new()
	hud.name = "HUD"
	hud.anchor_right = 1.0
	hud.anchor_bottom = 1.0
	canvas_layer.add_child(hud)

	# Create the currency label
	var currency_label = Label.new()
	currency_label.name = "CurrencyLabel"
	currency_label.text = "Currency: " + str(currency)
	# Position in top-right corner
	currency_label.anchor_left = 1.0
	currency_label.anchor_right = 1.0
	currency_label.offset_left = -200
	currency_label.offset_top = 20
	currency_label.offset_right = -20
	hud.add_child(currency_label)

	# Create notification label
	var notification = Label.new()
	notification.name = "NotificationLabel"
	notification.anchor_left = 0.5
	notification.anchor_right = 0.5
	notification.anchor_top = 0.1
	notification.anchor_bottom = 0.1
	notification.grow_horizontal = Control.GROW_DIRECTION_BOTH
	notification.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notification.visible = false
	canvas_layer.add_child(notification)

	# Create upgrade menu
	var upgrade_menu = Control.new()
	upgrade_menu.name = "UpgradeMenu"
	upgrade_menu.anchor_right = 1.0
	upgrade_menu.anchor_bottom = 1.0
	upgrade_menu.visible = false
	canvas_layer.add_child(upgrade_menu)

	# Add semi-transparent background
	var background = ColorRect.new()
	background.name = "Background"
	background.anchor_right = 1.0
	background.anchor_bottom = 1.0
	background.color = Color(0, 0, 0, 0.7)
	upgrade_menu.add_child(background)

	# Add title
	var title = Label.new()
	title.name = "Title"
	title.text = "UPGRADES"
	title.anchor_left = 0.5
	title.anchor_right = 0.5
	title.anchor_top = 0.1
	title.grow_horizontal = Control.GROW_DIRECTION_BOTH
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	upgrade_menu.add_child(title)

	# Add scroll container for upgrades
	var scroll = ScrollContainer.new()
	scroll.name = "ScrollContainer"
	scroll.anchor_left = 0.3
	scroll.anchor_right = 0.7
	scroll.anchor_top = 0.2
	scroll.anchor_bottom = 0.8
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	upgrade_menu.add_child(scroll)

	# Add container for upgrade items
	var container = VBoxContainer.new()
	container.name = "UpgradeContainer"
	container.size_flags_horizontal = Control.SIZE_FLAGS_EXPAND_FILL
	container.size_flags_vertical = Control.SIZE_FLAGS_EXPAND_FILL
	container.add_theme_constant_override("separation", 10)
	scroll.add_child(container)

	# Add close button
	var close_button = Button.new()
	close_button.name = "CloseButton"
	close_button.text = "Close"
	close_button.anchor_left = 0.5
	close_button.anchor_right = 0.5
	close_button.anchor_top = 0.9
	close_button.grow_horizontal = Control.GROW_DIRECTION_BOTH
	close_button.connect("pressed", func(): upgrade_menu.visible = false)
	upgrade_menu.add_child(close_button)

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
	
	# Create and setup the game level
	var game_scene = load("res://game_level.tscn").instantiate()
	game_scene.game_type = game_type
	game_scene.connect("run_ended", _on_run_ended)
	
	# Switch to the game scene
	get_tree().root.add_child(game_scene)
	get_tree().current_scene = game_scene
	queue_free()
	
func _on_run_ended(score, currency_earned):
	print("Run ended with score: " + str(score))
	print("Currency earned: " + str(currency_earned))

	# Add the earned currency
	add_currency(currency_earned)
	
func add_currency(amount):
	currency += amount
	update_currency_display()
	save_player_data()

func update_currency_display():
	$UI/HUD/CurrencyLabel.text = "Currency: " + str(currency)
	
# Add the purchase_upgrade function:
func purchase_upgrade(upgrade_id):
	var upgrade_system = get_node("/root/UpgradeSystem")
	var upgrade = upgrade_system.available_upgrades[upgrade_id]
	var current_level = current_upgrades.get(upgrade_id, 0)

	# Calculate cost based on current level
	var cost = upgrade.cost_per_level * (current_level + 1)

	# Check if player has enough currency
	if currency >= cost:
		# Deduct currency
		currency -= cost
		 
		# Increase upgrade level
		if not current_upgrades.has(upgrade_id):
			current_upgrades[upgrade_id] = 0
		current_upgrades[upgrade_id] += 1
		# Update UI
		update_currency_display()
		$UI/UpgradeMenu.visible = false
		show_upgrade_menu()  # Refresh the menu

		# Save progress
		save_player_data()
		
		# Show confirmation message
		var notification = $UI/NotificationLabel
		notification.text = "Purchased: " + upgrade.name + " (Level " + str(current_upgrades[upgrade_id]) + ")"
		notification.visible = true
		await get_tree().create_timer(2.0).timeout
		notification.visible = false
	else:
		# Show insufficient funds message
		var notification = $UI/NotificationLabel
		notification.text = "Not enough currency!"
		notification.visible = true
		await get_tree().create_timer(2.0).timeout
		notification.visible = false

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
