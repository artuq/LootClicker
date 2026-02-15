extends Node

# Proceduralny Manager Dźwięku dla LootClicker
# Generuje dźwięki bez użycia zewnętrznych plików (0 bajtów rozmiaru)

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
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 22050
	
	var duration = 0.1
	if type == "coin": duration = 0.2
	elif type == "error": duration = 0.15
	
	var num_samples = int(duration * stream.mix_rate)
	var data = PackedByteArray()
	data.resize(num_samples)
	
	for i in range(num_samples):
		var t = float(i) / stream.mix_rate
		var val = 0
		
		match type:
			"hit":
				# Krótki impuls szumu + sinusoida opadająca
				var env = exp(-t * 30.0)
				val = int((sin(t * 400.0 * PI) * 0.5 + (randf() - 0.5) * 0.5) * env * 127 + 128)
			"coin":
				# Dwa tony (bebeep)
				var freq = 1200.0 if t < 0.1 else 2400.0
				var env = exp(-(t if t < 0.1 else t-0.1) * 20.0)
				val = int(sin(t * freq * PI) * env * 127 + 128)
			"error":
				# Niski, nieprzyjemny dźwięk
				var env = exp(-t * 15.0)
				val = int(sin(t * 100.0 * PI) * env * 127 + 128)
		
		data[i] = clamp(val, 0, 255)
	
	stream.data = data
	player.stream = stream
	player.pitch_scale = p_shift
	player.play()
	
	player.finished.connect(func(): player.queue_free())
