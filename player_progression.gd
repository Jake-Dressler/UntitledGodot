# Create player_progression.gd and add it as an AutoLoad in Project Settings
extends Node

var currency = 0
var upgrades = {}
var run_stats = {
	"total_runs": 0,
	"best_score": 0,
	"total_currency_earned": 0
}

func _ready():
	load_data()

func add_currency(amount):
	currency += amount
	run_stats.total_currency_earned += amount
	save_data()

func get_upgrade_level(upgrade_id):
	return upgrades.get(upgrade_id, 0)

func upgrade(upgrade_id):
	if not upgrades.has(upgrade_id):
		upgrades[upgrade_id] = 0
	
	upgrades[upgrade_id] += 1
	save_data()

func complete_run(score):
	run_stats.total_runs += 1
	run_stats.best_score = max(run_stats.best_score, score)
	save_data()

func save_data():
	var save_file = FileAccess.open("user://player_progress.save", FileAccess.WRITE)
	var data = {
		"currency": currency,
		"upgrades": upgrades,
		"run_stats": run_stats
	}
	save_file.store_string(JSON.stringify(data))
	save_file.close()

func load_data():
	if FileAccess.file_exists("user://player_progress.save"):
		var save_file = FileAccess.open("user://player_progress.save", FileAccess.READ)
		var json_string = save_file.get_as_text()
		var data = JSON.parse_string(json_string)
		save_file.close()
		
		if data:
			currency = data.currency
			upgrades = data.upgrades
			run_stats = data.run_stats
