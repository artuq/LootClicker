extends SplashScreen

const TITLE_SCENE_PATH := "res://src/scenes/TitleScreen.tscn"

var _is_transitioning: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	skip_input_action = "ui_accept"
	if not finished.is_connected(_on_splash_finished):
		finished.connect(_on_splash_finished)
	super._ready()


func _on_splash_finished() -> void:
	if _is_transitioning:
		return
	_is_transitioning = true

	var out := create_tween()
	out.tween_property(self, "modulate:a", 0.0, 0.18)
	await out.finished

	var err := get_tree().change_scene_to_file(TITLE_SCENE_PATH)
	if err != OK:
		push_error("Splash transition failed: %s" % err)
