extends Node

# Globalny manager ustawień dla LootClicker

var master_volume: float = 1.0
var sfx_volume: float = 1.0
var music_volume: float = 1.0
var ui_volume: float = 1.0

const SETTINGS_PATH = "user://settings.cfg"

const MASTER_BUS := "Master"
const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"
const UI_BUS := "UI"

func _ready():
	load_settings()
	apply_settings()

func apply_settings():
	# Konwersja 0.0 - 1.0 na Decybele
	_set_bus_volume_if_exists(MASTER_BUS, master_volume)
	_set_bus_volume_if_exists(SFX_BUS, sfx_volume)
	_set_bus_volume_if_exists(MUSIC_BUS, music_volume)
	_set_bus_volume_if_exists(UI_BUS, ui_volume)
	print("Applied Settings: Master %.2f | SFX %.2f | Music %.2f | UI %.2f" % [master_volume, sfx_volume, music_volume, ui_volume])

func save_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "ui_volume", ui_volume)
	config.save(SETTINGS_PATH)

func load_settings():
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_PATH)
	if err == OK:
		master_volume = config.get_value("audio", "master_volume", 1.0)
		sfx_volume = config.get_value("audio", "sfx_volume", 1.0)
		music_volume = config.get_value("audio", "music_volume", 1.0)
		ui_volume = config.get_value("audio", "ui_volume", 1.0)

func _set_bus_volume_if_exists(bus_name: String, linear_value: float):
	var idx := AudioServer.get_bus_index(bus_name)
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, linear_to_db(clamp(linear_value, 0.0001, 1.0)))
