extends Node3D

signal run_started(game_type)

@export var game_type: String = "default_game"
@export var game_title: String = "Arcade Game"
@export var machine_color: Color = Color(0.8, 0.2, 0.2)

func _ready():
	var material = StandardMaterial3D.new()
	material.albedo_color = machine_color
	$ArcadeCabinet.material_override = material
	
	$GameTitle.text = game_title

func interact():
	print("Starting game: " + game_type)
	emit_signal("run_started", game_type)
	# Will later transition to the actual game
