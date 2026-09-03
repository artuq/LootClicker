extends Control

@onready var product_title: Label = %ProductTitle
@onready var product_description: Label = %ProductDescription
@onready var buy_button: Button = %BuyButton
@onready var restore_button: Button = %RestoreButton
@onready var status_label: Label = %StatusLabel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var purchases := get_node_or_null("/root/PurchaseManager")
	if purchases:
		purchases.entitlement_changed.connect(_on_entitlement_changed)
		purchases.billing_state_changed.connect(_on_billing_state_changed)
		purchases.product_details_changed.connect(_refresh)
		purchases.purchase_failed.connect(_on_billing_state_changed)
	_refresh()


func _refresh() -> void:
	var purchases := get_node_or_null("/root/PurchaseManager")
	product_title.text = "REMOVE ALL ADS"
	product_description.text = (
		"Permanently removes every ad: banners, automatic interstitials, "
		+ "and rewarded videos.\nFull Heal, offline x2 Gold, and revive bonuses "
		+ "remain available without watching an ad."
	)
	if purchases == null:
		buy_button.text = "UNAVAILABLE"
		buy_button.disabled = true
		restore_button.disabled = true
		status_label.text = "Google Play Billing is not initialized."
		return
	if purchases.has_remove_ads():
		buy_button.text = "OWNED ✓"
		buy_button.disabled = true
		status_label.text = "Remove Ads is active on this Google Play account."
	else:
		var price: String = str(purchases.get_remove_ads_price())
		buy_button.text = "BUY%s" % (" — " + price if not price.is_empty() else "")
		buy_button.disabled = not purchases.is_purchase_ready()
		status_label.text = purchases.billing_state
	restore_button.disabled = not OS.has_feature("android")


func _on_buy_button_pressed() -> void:
	var purchases := get_node_or_null("/root/PurchaseManager")
	if purchases:
		purchases.purchase_remove_ads()


func _on_restore_button_pressed() -> void:
	var purchases := get_node_or_null("/root/PurchaseManager")
	if purchases:
		purchases.restore_purchases()


func _on_entitlement_changed(_owned: bool) -> void:
	_refresh()


func _on_billing_state_changed(state: String) -> void:
	status_label.text = state
	_refresh()


func _on_close_button_pressed() -> void:
	var layer := get_parent()
	if layer is CanvasLayer:
		layer.queue_free()
	else:
		queue_free()
