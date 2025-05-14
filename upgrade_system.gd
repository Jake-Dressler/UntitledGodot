# Create a new script called upgrade_system.gd
extends Node

# Available upgrades
var available_upgrades = {
	"health_boost": {
		"name": "Health Boost",
		"description": "Increases maximum health by 25%",
		"levels": 3,
		"cost_per_level": 100,
		"effect_per_level": 0.25
	},
	"damage_boost": {
		"name": "Damage Boost",
		"description": "Increases damage dealt by 20%",
		"levels": 5,
		"cost_per_level": 150,
		"effect_per_level": 0.2
	},
	"speed_boost": {
		"name": "Speed Boost",
		"description": "Increases movement speed by 15%",
		"levels": 3,
		"cost_per_level": 120,
		"effect_per_level": 0.15
	}
}

func get_upgrade_effect(upgrade_id, level):
	if upgrade_id in available_upgrades:
		var upgrade = available_upgrades[upgrade_id]
		return upgrade.effect_per_level * level
	return 0.0
