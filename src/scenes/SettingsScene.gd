extends Control

@onready var volume_slider = %VolumeSlider

const PRIVACY_TEXT := """Privacy Policy – Loot Clicker: Joanna Indiana
Effective date: 2026-03-02

This Privacy Policy explains how data is handled when you use Loot Clicker: Joanna Indiana.

1. Data We Collect
The developer does not require account registration and does not directly collect personal data such as name, email, or address.

The app uses third-party services that may collect device-related data:
• Google AdMob (ads delivery and monetization)
• Potential identifiers such as Advertising ID and basic diagnostics used by AdMob

For details about Google's data practices, see:
• https://policies.google.com/privacy
• https://support.google.com/admob/answer/6128543

2. Local Save Data
The game stores progress locally on your device (for example: level, stats, resources, inventory). This data is used only to provide gameplay features (save/load progression).

The developer does not receive this local save data from your device.

3. No Account / No Login
Loot Clicker does not require creating an account and does not provide login functionality.

4. Children
The app is not intentionally designed to collect personal information from children. If legal requirements for child-directed treatment apply in your region, ad behavior is governed by AdMob configuration and Google policies.

5. Data Sharing
The developer does not sell personal data. Data processed by third-party SDKs (such as AdMob) is subject to those providers' terms and privacy policies.

6. Security
Reasonable technical measures are used within the game project, but no method of transmission or storage is 100% secure.

7. Changes to This Policy
This policy may be updated from time to time. The updated version will include a new effective date.

8. Contact
For privacy-related questions, contact the developer through the contact email published in the Google Play listing."""

func _ready():
	# Initialize slider with current value
	if get_node_or_null("/root/SettingsManager"):
		volume_slider.value = get_node("/root/SettingsManager").master_volume
	
	# Hide save/load container (no longer used — auto-checkpoint system)
	var save_load_container = get_node_or_null("%SaveLoadContainer")
	if save_load_container:
		save_load_container.visible = false

func setup():
	pass  # Volume-only settings, no save/load needed

func _spawn_feedback(msg: String):
	var lbl = Label.new()
	lbl.text = msg
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", Color.GREEN_YELLOW)
	lbl.anchors_preset = Control.PRESET_CENTER_BOTTOM
	lbl.position.y -= 30
	add_child(lbl)
	var tw = create_tween()
	tw.tween_property(lbl, "modulate:a", 0.0, 1.2)
	tw.tween_callback(lbl.queue_free)

func _on_volume_slider_value_changed(value: float):
	if get_node_or_null("/root/SettingsManager"):
		var sm = get_node("/root/SettingsManager")
		sm.master_volume = value
		sm.apply_settings()

func _on_back_button_pressed():
	if get_node_or_null("/root/SettingsManager"):
		get_node("/root/SettingsManager").save_settings()
	
	# If we are an overlay (during pause), just remove ourselves
	if get_parent() is CanvasLayer:
		queue_free()
		get_tree().paused = false
	else:
		# If we are a separate scene from the main menu
		get_tree().change_scene_to_file("res://src/scenes/TitleScreen.tscn")

func _on_privacy_button_pressed():
	# Show privacy policy in-app — no external hosting needed
	var layer = CanvasLayer.new()
	layer.layer = 110
	add_child(layer)
	
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.07, 0.07, 0.07, 0.97)
	layer.add_child(bg)
	
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 40)
	margin.add_theme_constant_override("margin_bottom", 16)
	layer.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(vbox)
	
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)
	
	var lbl = Label.new()
	lbl.text = PRIVACY_TEXT
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var ls = LabelSettings.new()
	ls.font_size = 13
	ls.font_color = Color(0.94, 0.94, 0.94)
	lbl.label_settings = ls
	scroll.add_child(lbl)
	
	var close_btn = Button.new()
	close_btn.text = "✕ CLOSE"
	close_btn.custom_minimum_size = Vector2(0, 44)
	close_btn.add_theme_font_size_override("font_size", 16)
	close_btn.pressed.connect(layer.queue_free)
	vbox.add_child(close_btn)
