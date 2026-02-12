extends Label

func _ready():
	# 1. Ustawiamy punkt centralny tekstu na środku
	pivot_offset = size / 2
	
	# 2. Tworzymy "Tween" - narzędzie do prostych animacji
	var tween = create_tween()
	tween.set_parallel(true) # Pozwala na dwie animacje jednocześnie

	# Animacja 1: Ruch do góry o 50 pikseli w ciągu 1 sekundy
	tween.tween_property(self, "position:y", position.y - 50, 1.0).set_ease(Tween.EASE_OUT)
	
	# Animacja 2: Znikanie (alpha do 0) w ciągu 1 sekundy
	tween.tween_property(self, "modulate:a", 0.0, 1.0).set_ease(Tween.EASE_IN)
	
	# 3. Po zakończeniu animacji, usuń cyferkę z gry, żeby nie zaśmiecała pamięci
	tween.chain().tween_callback(queue_free)
