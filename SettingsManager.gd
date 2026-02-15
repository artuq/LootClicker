extends Node

# Globalny manager ustawień dla LootClicker

var master_volume: float = 1.0
var sfx_volume: float = 1.0

const SETTINGS_PATH = "user://settings.cfg"

func _ready():
	load_settings()
	apply_settings()

func apply_settings():
	# Konwersja 0.0 - 1.0 na Decybele
	var db = linear_to_db(master_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)
	
	# W przyszłości można dodać osobne szyny dla Music i SFX
	print("Applied Settings: Master Vol %.2f" % master_volume)

func save_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume)
	config.save(SETTINGS_PATH)

func load_settings():
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_PATH)
	if err == OK:
		master_volume = config.get_value("audio", "master_volume", 1.0)
