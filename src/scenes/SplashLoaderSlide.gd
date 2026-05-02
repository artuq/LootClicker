extends SplashScreenSlide

const TITLE_SCENE_PATH := "res://src/scenes/TitleScreen.tscn"
const SPLASH_SFX_PATH := "res://assets/audio/Crystal System Boot.mp3"
const MIN_SHOW_TIME := 7.5
const FAILSAFE_TIMEOUT := 10.0
const INTRO_TIME := 0.32
const PROGRESS_SPEED := 85.0

@onready var logo: TextureRect = $Logo
@onready var loading_bar: ProgressBar = $LoadingBar
@onready var loading_label: Label = get_node_or_null("LoadingLabel") as Label

var _elapsed: float = 0.0
var _load_started: bool = false
var _load_progress: Array = []
var _loaded: bool = false
var _target_progress: float = 0.0
var _display_progress: float = 0.0
var _sfx_player: AudioStreamPlayer = null


func _ready() -> void:
	continue_after_duration = false
	skippable = false
	if logo == null or loading_bar == null:
		push_error("SplashLoaderSlide: Missing child nodes 'Logo' or 'LoadingBar'.")
		return
	_ensure_loading_label()
	_style_loading_bar()
	loading_bar.max_value = 100.0
	loading_bar.value = 0.0
	loading_bar.show_percentage = false
	logo.modulate.a = 0.0
	logo.scale = Vector2(0.92, 0.92)
	_update_loading_label()


func _slide() -> void:
	if logo == null or loading_bar == null:
		slide_finished.emit()
		return
	var req_err := ResourceLoader.load_threaded_request(TITLE_SCENE_PATH)
	_load_started = (req_err == OK)
	_play_splash_sfx()
	_play_intro()

	while not _can_finish():
		await get_tree().process_frame
		var delta := get_process_delta_time()
		_elapsed += delta
		if _load_started and not _loaded:
			_poll_loading()
		_update_progress_visual(delta)
		if _elapsed >= FAILSAFE_TIMEOUT:
			break

	_target_progress = 100.0
	_display_progress = 100.0
	loading_bar.value = 100.0
	_update_loading_label()
	slide_finished.emit()


func _can_finish() -> bool:
	return _elapsed >= MIN_SHOW_TIME and (_loaded or _elapsed >= FAILSAFE_TIMEOUT) and _display_progress >= 99.0


func _poll_loading() -> void:
	var status := ResourceLoader.load_threaded_get_status(TITLE_SCENE_PATH, _load_progress)
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if _load_progress.size() > 0:
				var pct := clampf(float(_load_progress[0]) * 100.0, 0.0, 100.0)
				_target_progress = max(_target_progress, pct)
		ResourceLoader.THREAD_LOAD_LOADED:
			var res := ResourceLoader.load_threaded_get(TITLE_SCENE_PATH)
			_loaded = (res is PackedScene)
			_target_progress = 100.0
		ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			_loaded = false
			_target_progress = max(_target_progress, 95.0)


func _play_splash_sfx() -> void:
	var stream := load(SPLASH_SFX_PATH) as AudioStream
	if stream == null:
		return
	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.stream = stream
	_sfx_player.volume_db = 0.0
	_sfx_player.bus = "Master"
	add_child(_sfx_player)
	_sfx_player.play()


func _play_intro() -> void:
	var tween := create_tween()
	tween.tween_property(logo, "modulate:a", 1.0, INTRO_TIME)
	tween.parallel().tween_property(logo, "scale", Vector2.ONE, INTRO_TIME).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _update_progress_visual(delta: float) -> void:
	_display_progress = move_toward(_display_progress, _target_progress, PROGRESS_SPEED * delta)
	loading_bar.value = _display_progress
	_update_loading_label()


func _update_loading_label() -> void:
	if loading_label == null:
		return
	var dots: int = int(floor(_elapsed * 3.0)) % 4
	# Pulsing "LOADING..." without percentage — cleaner feel
	loading_label.text = "LOADING%s" % ".".repeat(dots)
	# Subtle pulse on the label alpha for extra life
	var pulse: float = 0.7 + 0.3 * abs(sin(_elapsed * 2.5))
	loading_label.modulate.a = pulse


func _ensure_loading_label() -> void:
	if loading_label != null:
		return
	loading_label = Label.new()
	loading_label.name = "LoadingLabel"
	add_child(loading_label)
	loading_label.anchor_left = 0.5
	loading_label.anchor_top = 0.5
	loading_label.anchor_right = 0.5
	loading_label.anchor_bottom = 0.5
	loading_label.offset_left = -130.0
	loading_label.offset_top = 96.0
	loading_label.offset_right = 130.0
	loading_label.offset_bottom = 124.0
	loading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loading_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	loading_label.add_theme_color_override("font_color", Color(0.86, 0.94, 1.0, 0.95))


func _style_loading_bar() -> void:
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.08, 0.1, 0.18, 0.9)
	bg.set_corner_radius_all(8)
	bg.set_border_width_all(2)
	bg.border_color = Color(0.2, 0.27, 0.42, 1.0)

	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.22, 0.82, 0.49, 1.0)
	fill.set_corner_radius_all(7)

	loading_bar.add_theme_stylebox_override("background", bg)
	loading_bar.add_theme_stylebox_override("fill", fill)
