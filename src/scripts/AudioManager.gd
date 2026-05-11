extends Node

# Procedural Sound Manager for LootClicker

var music_player: AudioStreamPlayer
var low_pass_filter: AudioEffectLowPassFilter
var low_pass_enabled: bool = false
var heartbeat_player: AudioStreamPlayer
var heartbeat_playing: bool = false

const MASTER_BUS := "Master"
const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"
const UI_BUS := "UI"

const MUSIC_VOLUME_DB := -10.0
const CROSSFADE_DURATION := 0.6

var _tracks: Dictionary = {}
var _current_track: String = ""
var _crossfade_tween: Tween = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	music_player = AudioStreamPlayer.new()
	music_player.volume_db = MUSIC_VOLUME_DB
	music_player.bus = _pick_bus([MUSIC_BUS, MASTER_BUS])
	add_child(music_player)

	var track_files := {
		"jungle":  "res://assets/audio/jungle_theme.mp3",
		"temple":  "res://assets/audio/temple_theme.mp3",
		"boss":    "res://assets/audio/boss_theme.mp3",
		"title":   "res://assets/audio/title_theme.mp3",
		"victory": "res://assets/audio/victory_jingle.mp3",
	}
	for key in track_files:
		var stream = load(track_files[key])
		if stream:
			_tracks[key] = stream
		else:
			print("AudioManager: missing track — ", track_files[key])

func play_track(track_name: String):
	if track_name == _current_track and music_player.playing:
		return
	if not _tracks.has(track_name):
		print("AudioManager: unknown track — ", track_name)
		return
	_current_track = track_name
	_crossfade_to(_tracks[track_name], track_name != "victory")

func play_victory_jingle(return_track: String):
	if not _tracks.has("victory"):
		return
	_current_track = "victory"
	_crossfade_to(_tracks["victory"], false)
	music_player.finished.connect(func():
		play_track(return_track)
	, CONNECT_ONE_SHOT)

func _crossfade_to(stream: AudioStream, loop: bool):
	if _crossfade_tween:
		_crossfade_tween.kill()
	if music_player.playing:
		_crossfade_tween = create_tween()
		_crossfade_tween.tween_property(music_player, "volume_db", -80.0, CROSSFADE_DURATION)
		_crossfade_tween.tween_callback(func():
			_start_stream(stream, loop)
		)
	else:
		_start_stream(stream, loop)

func _start_stream(stream: AudioStream, loop: bool):
	music_player.stream = stream
	music_player.volume_db = -80.0
	music_player.play()
	if _crossfade_tween:
		_crossfade_tween.kill()
	_crossfade_tween = create_tween()
	_crossfade_tween.tween_property(music_player, "volume_db", MUSIC_VOLUME_DB, CROSSFADE_DURATION)
	if loop:
		if not music_player.finished.is_connected(_on_loop):
			music_player.finished.connect(_on_loop)
	else:
		if music_player.finished.is_connected(_on_loop):
			music_player.finished.disconnect(_on_loop)

func _on_loop():
	music_player.play()

func play_music():
	if music_player and not music_player.playing:
		music_player.play()

func stop_music():
	if music_player:
		music_player.stop()
	_current_track = ""

# === Near Death Audio Effects ===
func set_near_death_audio(enabled: bool):
	if enabled == low_pass_enabled:
		return
	low_pass_enabled = enabled
	
	var bus_idx = AudioServer.get_bus_index("Master")
	if bus_idx < 0:
		return
	
	if enabled:
		# Add low-pass filter to Master bus
		if not low_pass_filter:
			low_pass_filter = AudioEffectLowPassFilter.new()
		low_pass_filter.cutoff_hz = 20500.0
		AudioServer.add_bus_effect(bus_idx, low_pass_filter)
		# Tween cutoff down to muffled
		var tween = create_tween()
		tween.tween_method(_set_lowpass_cutoff, 20500.0, 800.0, 0.6).set_trans(Tween.TRANS_SINE)
		# Start heartbeat
		_start_heartbeat()
	else:
		# Tween cutoff back up then remove
		var tween = create_tween()
		tween.tween_method(_set_lowpass_cutoff, 800.0, 20500.0, 0.4).set_trans(Tween.TRANS_SINE)
		tween.tween_callback(_remove_lowpass_effect)
		# Stop heartbeat
		_stop_heartbeat()

func _set_lowpass_cutoff(value: float):
	if low_pass_filter:
		low_pass_filter.cutoff_hz = value

func _remove_lowpass_effect():
	var bus_idx = AudioServer.get_bus_index("Master")
	if bus_idx < 0:
		return
	for i in range(AudioServer.get_bus_effect_count(bus_idx) - 1, -1, -1):
		if AudioServer.get_bus_effect(bus_idx, i) == low_pass_filter:
			AudioServer.remove_bus_effect(bus_idx, i)
			break

func _start_heartbeat():
	if heartbeat_playing:
		return
	heartbeat_playing = true
	if not heartbeat_player:
		heartbeat_player = AudioStreamPlayer.new()
		add_child(heartbeat_player)
	_play_heartbeat_loop()

func _stop_heartbeat():
	heartbeat_playing = false
	if heartbeat_player:
		heartbeat_player.stop()

func _play_heartbeat_loop():
	if not heartbeat_playing:
		return
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 44100
	stream.stereo = false
	
	# Double-beat heartbeat: "lub-dub" pattern ~0.6s total
	var duration = 0.6
	var num_samples = int(duration * stream.mix_rate)
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t = float(i) / stream.mix_rate
		var sample = 0.0
		
		# First beat ("lub") at t=0
		var env1 = exp(-t * 25.0) * 0.6
		sample += sin(t * 60.0 * PI) * env1
		
		# Second beat ("dub") at t=0.15
		var t2 = t - 0.15
		if t2 > 0:
			var env2 = exp(-t2 * 30.0) * 0.4
			sample += sin(t2 * 50.0 * PI) * env2
		
		var int_sample = int(clamp(sample, -1.0, 1.0) * 32767)
		data[i * 2] = int_sample & 0xFF
		data[i * 2 + 1] = (int_sample >> 8) & 0xFF
	
	stream.data = data
	heartbeat_player.stream = stream
	heartbeat_player.volume_db = -6
	heartbeat_player.bus = _pick_bus([SFX_BUS, MASTER_BUS])
	heartbeat_player.play()
	# Loop after pause (heartbeat rhythm ~0.9s cycle)
	heartbeat_player.finished.connect(func():
		if heartbeat_playing:
			await get_tree().create_timer(0.3).timeout
			_play_heartbeat_loop()
	, CONNECT_ONE_SHOT)

func play_hit_sound(pitch_shift: float = 1.0):
	_play_generated_sound("hit", pitch_shift)

func play_coin_sound():
	_play_generated_sound("coin")

func play_error_sound():
	_play_generated_sound("error")

func play_ui_click_sound():
	_play_generated_sound("ui_click")

func play_ui_hover_sound():
	_play_generated_sound("ui_hover")

func _play_generated_sound(type: String, p_shift: float = 1.0):
	var player = AudioStreamPlayer.new()
	add_child(player)
	
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS # 16-bit for better compatibility
	stream.mix_rate = 44100 # Standard quality
	stream.stereo = false
	
	var duration = 0.1
	if type == "coin": duration = 0.2
	elif type == "error": duration = 0.2
	
	var num_samples = int(duration * stream.mix_rate)
	var data = PackedByteArray()
	# Each 16-bit sample takes 2 bytes
	data.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t = float(i) / stream.mix_rate
		var sample = 0.0
		
		match type:
			"hit":
				var is_crit = p_shift > 1.2
				var freq = randf_range(200.0, 350.0) if not is_crit else randf_range(400.0, 600.0)
				var env = exp(-t * (50.0 if not is_crit else 30.0))
				
				# Base impact wave
				var osc = sin(t * freq * PI) * 0.5
				
				# Add "crunch" using noise and high-pass frequency
				var noise = (randf() - 0.5) * 0.8 * env
				
				# Pitch slide for "punchy" feel
				var pitch_slide = exp(-t * 15.0)
				osc = sin(t * freq * (1.0 + pitch_slide) * PI) * 0.4
				
				if is_crit:
					osc += sin(t * freq * 2.0 * PI) * 0.2 # Extra harmonics for crit
					osc += (randf() - 0.5) * 0.4 * env # Extra grit
				
				sample = (osc + noise) * env
			"coin":
				var freq = 1500.0 if t < 0.1 else 2000.0
				var env = exp(-(t if t < 0.1 else t-0.1) * 25.0)
				sample = sin(t * freq * PI) * env * 0.5
			"error":
				var env = exp(-t * 20.0)
				sample = (sin(t * 80.0 * PI) + sin(t * 120.0 * PI)) * env * 0.4
			"ui_click":
				var env = exp(-t * 60.0)
				sample = (randf() - 0.5) * 0.2 * env + sin(t * 1000.0 * PI) * env * 0.3
			"ui_hover":
				var env = exp(-t * 40.0)
				sample = sin(t * 1500.0 * PI) * env * 0.1
		
		# Convert float (-1.0 to 1.0) to Signed 16-bit Int (-32768 to 32767)
		var int_sample = int(clamp(sample, -1.0, 1.0) * 32767)
		
		# Store 2 bytes (Little Endian)
		data[i * 2] = int_sample & 0xFF
		data[i * 2 + 1] = (int_sample >> 8) & 0xFF
	
	stream.data = data
	player.stream = stream
	player.pitch_scale = p_shift
	var target_bus := _pick_sound_bus(type)
	player.bus = target_bus
	player.play()
	
	player.finished.connect(func(): player.queue_free())

func _pick_sound_bus(sound_type: String) -> String:
	if sound_type == "ui_click" or sound_type == "ui_hover":
		return _pick_bus([UI_BUS, SFX_BUS, MASTER_BUS])
	return _pick_bus([SFX_BUS, MASTER_BUS])

func _pick_bus(candidates: Array[String]) -> String:
	for bus_name in candidates:
		if AudioServer.get_bus_index(bus_name) >= 0:
			return bus_name
	return MASTER_BUS
