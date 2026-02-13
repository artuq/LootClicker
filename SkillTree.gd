extends Panel

var player: PlayerStats

@onready var points_label = $VBoxContainer/PointsLabel
@onready var btn_str = $VBoxContainer/GridContainer/BtnStr
@onready var btn_crit = $VBoxContainer/GridContainer/BtnCrit
@onready var btn_gold = $VBoxContainer/GridContainer/BtnGold
@onready var btn_spd = $VBoxContainer/GridContainer/BtnSpd
@onready var btn_def = $VBoxContainer/GridContainer/BtnDef
@onready var btn_heal = $VBoxContainer/GridContainer/BtnHeal

func setup(p_ref: PlayerStats):
	player = p_ref
	if not player.skills_updated.is_connected(update_ui):
		player.skills_updated.connect(update_ui)
	if not player.gold_changed.is_connected(func(_g): update_ui()):
		player.gold_changed.connect(func(_g): update_ui())
	update_ui()

func update_ui():
	if player == null or not is_node_ready() or points_label == null: return
	
	points_label.text = "Gold: " + str(player.gold)
	
	_upd(btn_str, "str", "Strength +1", player.str_lvl)
	_upd(btn_crit, "crit", "Crit +1%", player.crit_lvl)
	_upd(btn_gold, "greed", "Gold +5%", player.greed_lvl)
	_upd(btn_spd, "speed", "Speed (Wait: %.2fs)" % player.get_attack_speed(), player.speed_lvl)
	_upd(btn_def, "def", "Defense +1", player.def_lvl)
	
	# --- LOGIKA HEAL ---
	if btn_heal:
		var cost = player.get_skill_cost("heal")
		var is_full = player.current_hp >= player.max_hp
		
		if is_full:
			btn_heal.text = "HP FULL"
			btn_heal.disabled = true
			btn_heal.modulate = Color(0.5, 1, 0.5, 0.5) # Zielonkawy, ale przezroczysty
		else:
			# Używamy %% dla znaku procenta
			btn_heal.text = "HEAL 100%%\nCost: %d G" % cost
			btn_heal.disabled = player.gold < cost
			btn_heal.modulate = Color(1, 1, 1, 1) if not btn_heal.disabled else Color(0.5, 0.5, 0.5)

func _upd(btn, id, text, lvl):
	if btn:
		var cost = player.get_skill_cost(id)
		btn.text = "%s (L%d)\n%d G" % [text, lvl, cost]
		btn.disabled = player.gold < cost

# --- SYGNAŁY ---
func _on_btn_str_pressed(): _buy("str")
func _on_btn_crit_pressed(): _buy("crit")
func _on_btn_gold_pressed(): _buy("greed")
func _on_btn_def_pressed(): _buy("def")
func _on_btn_spd_pressed(): _buy("speed")

# --- TO MUSI BYĆ PODŁĄCZONE W EDYTORZE ---
func _on_btn_heal_pressed():
	# Sprawdzamy warunki jeszcze raz dla bezpieczeństwa
	if player.current_hp >= player.max_hp: return
	
	var cost = player.get_skill_cost("heal")
	if player.gold >= cost:
		player.gold -= cost
		player.heal_player()
		player.gold_changed.emit(player.gold)
		# update_ui() wywoła się automatycznie przez sygnał z heal_player
		
func _buy(id: String):
	var cost = player.get_skill_cost(id)
	if player.gold >= cost:
		player.gold -= cost
		match id:
			"str": player.str_lvl += 1
			"crit": player.crit_lvl += 1
			"greed": player.greed_lvl += 1
			"speed": player.speed_lvl += 1
			"def": player.def_lvl += 1
		
		player.gold_changed.emit(player.gold)
		player.skills_updated.emit()
