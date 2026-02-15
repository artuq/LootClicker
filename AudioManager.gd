extends Node

# Proceduralny Manager Dźwięku dla LootClicker (Poprawiona wersja 16-bit)

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

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
	stream.format = AudioStreamWAV.FORMAT_16_BITS # Zmiana na 16 bitów dla lepszej kompatybilności
	stream.mix_rate = 44100 # Standardowa jakość
	stream.stereo = false
	
	var duration = 0.1
	if type == "coin": duration = 0.2
	elif type == "error": duration = 0.2
	
	var num_samples = int(duration * stream.mix_rate)
	var data = PackedByteArray()
	# Każdy sampel 16-bit zajmuje 2 bajty
	data.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t = float(i) / stream.mix_rate
		var sample = 0.0
		
		match type:
			"hit":
				var is_crit = p_shift > 1.2
				var freq = 300.0 if not is_crit else 450.0
				var env = exp(-t * (40.0 if not is_crit else 25.0))
				# Normal: thud-like, Crit: snappy and metallic
				var osc = sin(t * freq * PI) * 0.4
				if is_crit:
					osc += sin(t * freq * 2.5 * PI) * 0.2 # Harmonics for crit
				sample = (osc + (randf() - 0.5) * 0.6) * env
			"coin":
				var freq = 1500.0 if t < 0.1 else 2000.0
				var env = exp(-(t if t < 0.1 else t-0.1) * 25.0)
				sample = sin(t * freq * PI) * env * 0.5
			"error":
				var env = exp(-t * 20.0)
				sample = (sin(t * 80.0 * PI) + sin(t * 120.0 * PI)) * env * 0.4
		
		# Konwersja float (-1.0 do 1.0) na Signed 16-bit Int (-32768 do 32767)
		var int_sample = int(clamp(sample, -1.0, 1.0) * 32767)
		
		# Zapisywanie 2 bajtów (Little Endian)
		data[i * 2] = int_sample & 0xFF
		data[i * 2 + 1] = (int_sample >> 8) & 0xFF
	
	stream.data = data
	player.stream = stream
	player.pitch_scale = p_shift
	player.bus = "Master" # Upewniamy się, że gra na głównym kanale
	player.play()
	
	player.finished.connect(func(): player.queue_free())
