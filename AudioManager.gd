extends Node

# Procedural Sound Manager for LootClicker (16-bit version)

var music_player: AudioStreamPlayer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	
	var music_stream = load("res://assets/audio/bg_music.mp3")
	if music_stream:
		music_player.stream = music_stream
		music_player.volume_db = -10 # Slightly quieter background
		music_player.bus = "Master"
		music_player.finished.connect(func(): music_player.play())

func play_music():
	if music_player and not music_player.playing:
		music_player.play()

func stop_music():
	if music_player:
		music_player.stop()

func play_hit_sound(pitch_shift: float = 1.0):
	_play_generated_sound("hit", pitch_shift)

func play_coin_sound():
	_play_generated_sound("coin")

func play_error_sound():
	_play_generated_sound("error")

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
		
		# Convert float (-1.0 to 1.0) to Signed 16-bit Int (-32768 to 32767)
		var int_sample = int(clamp(sample, -1.0, 1.0) * 32767)
		
		# Store 2 bytes (Little Endian)
		data[i * 2] = int_sample & 0xFF
		data[i * 2 + 1] = (int_sample >> 8) & 0xFF
	
	stream.data = data
	player.stream = stream
	player.pitch_scale = p_shift
	player.bus = "Master" # Ensure it plays on Master bus
	player.play()
	
	player.finished.connect(func(): player.queue_free())
