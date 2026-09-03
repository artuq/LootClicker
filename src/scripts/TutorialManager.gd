extends Node

# Tutorial permanently disabled as requested in v53
signal tutorial_completed
signal request_timer_stop
signal request_timer_start

var tutorial_shown: bool = true
var tutorial_active: bool = false
var tutorial_step: int = 5
var tutorial_tap_count: int = 0
var tutorial_click_cooldown: bool = false

const TUTORIAL_NONE := 0
const TUTORIAL_COMBAT_TAPS := 1
const TUTORIAL_AUTO_ATTACK := 2
const TUTORIAL_LEVEL_UP := 3
const TUTORIAL_STAGE_PROGRESS := 4
const TUTORIAL_DONE := 5

func setup(_refs: Dictionary) -> void:
	pass

func show_tutorial() -> void:
	tutorial_completed.emit()

func clear_overlay() -> void:
	pass

func enter_auto_attack_step(_current_enemy: Node = null) -> void:
	pass

func show_xp_hint_step() -> void:
	pass

func show_stage_progress_step() -> void:
	pass

func finish() -> void:
	tutorial_active = false
	tutorial_step = TUTORIAL_DONE
	tutorial_completed.emit()
