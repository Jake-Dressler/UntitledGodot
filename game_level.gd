# Create a new script called game_level.gd
extends Node3D

signal run_ended(score, currency_earned)

var game_type = "default_game"
var score = 0
var player_alive = true
var difficulty_multiplier = 1.0

func _ready():
	# Set up the basic level based on game_type
	setup_level()
	
	# Start the game
	start_game()

func setup_level():
	# Different setup based on game type
	match game_type:
		"dungeon_crawler":
			difficulty_multiplier = 1.0
			# Set up dungeon environment
		"space_shooter":
			difficulty_multiplier = 1.2
			# Set up space environment  
		"zombie_survival":
			difficulty_multiplier = 1.5
			# Set up zombie environment

# In game_level.gd:
func calculate_difficulty():
	var player_power = 1.0
	var player_progression = get_node("/root/PlayerProgression")

	# Calculate player power based on upgrades
	var health_level = player_progression.get_upgrade_level("health_boost")
	var damage_level = player_progression.get_upgrade_level("damage_boost")
	var speed_level = player_progression.get_upgrade_level("speed_boost")

	player_power += health_level * 0.15
	player_power += damage_level * 0.2
	player_power += speed_level * 0.1

	# Scale difficulty based on player power
	difficulty_multiplier = 1.0 + (player_power * 0.1)

	# Apply upgrades to player
	var player = $Player
	player.max_health *= (1 + health_level * 0.25)
	player.damage_multiplier = 1 + damage_level * 0.2
	player.speed_multiplier = 1 + speed_level * 0.15
	
func start_game():
	# Start the game logic
	# For testing, we'll just add a timer that ends the run after 30 seconds
	var timer = Timer.new()
	timer.wait_time = 30.0
	timer.one_shot = true
	timer.connect("timeout", end_run)
	add_child(timer)
	timer.start()

func add_score(points):
	score += points
	$UI/HUD/ScoreLabel.text = "Score: " + str(score)

func end_run():
	player_alive = false
	
	# Calculate currency earned based on score and difficulty
	var currency_earned = int(score * 0.1 * difficulty_multiplier)
	
	# Show results screen
	show_results(currency_earned)
	
	# Emit signal to let hub know about the results
	await get_tree().create_timer(3.0).timeout
	emit_signal("run_ended", score, currency_earned)
	
	# Return to hub
	get_tree().change_scene_to_file("res://hub_room.tscn")

func show_results(currency_earned):
	# Create or show the results UI
	var results_screen = $UI/ResultsScreen
	results_screen.visible = true
	results_screen.get_node("ScoreValue").text = str(score)
	results_screen.get_node("CurrencyValue").text = str(currency_earned)
