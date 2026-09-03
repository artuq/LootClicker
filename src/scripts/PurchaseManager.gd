extends Node

## Google Play is the source of truth for durable entitlements. The local file is
## only an offline cache, refreshed by query_purchases() at startup and resume.

signal entitlement_changed(remove_ads_owned: bool)
signal billing_state_changed(state: String)
signal product_details_changed
signal purchase_completed(product_id: String)
signal purchase_failed(message: String)

const REMOVE_ADS_PRODUCT_ID := "remove_ads_lifetime"
const REMOVE_ADS_PURCHASE_OPTION_ID := "standard"
const CACHE_PATH := "user://purchase_entitlements.cfg"

var remove_ads_owned: bool = false
var billing_state: String = "unavailable"
var localized_remove_ads_price: String = ""

var _billing_client: BillingClient
var _product_details_ready: bool = false
var _pending_acknowledgements: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_cache()

	if not OS.has_feature("android"):
		_set_billing_state("Google Play purchases are available in the Android app.")
		return

	_billing_client = BillingClient.new()
	add_child(_billing_client)
	_billing_client.connected.connect(_on_billing_connected)
	_billing_client.disconnected.connect(_on_billing_disconnected)
	_billing_client.connect_error.connect(_on_billing_connect_error)
	_billing_client.query_product_details_response.connect(_on_product_details_response)
	_billing_client.query_purchases_response.connect(_on_query_purchases_response)
	_billing_client.on_purchase_updated.connect(_on_purchase_updated)
	_billing_client.acknowledge_purchase_response.connect(_on_acknowledge_purchase_response)
	_set_billing_state("Connecting to Google Play…")
	_billing_client.start_connection()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_RESUMED:
		call_deferred("restore_purchases", false)
	elif what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_cache()


func has_remove_ads() -> bool:
	return remove_ads_owned


func is_purchase_ready() -> bool:
	return (
		_billing_client != null
		and _billing_client.is_ready()
		and _product_details_ready
		and not remove_ads_owned
	)


func get_remove_ads_price() -> String:
	return localized_remove_ads_price


func purchase_remove_ads() -> void:
	if remove_ads_owned:
		_set_billing_state("Remove Ads is already active.")
		return
	if _billing_client == null or not _billing_client.is_ready():
		_fail("Google Play is not connected. Try again in a moment.")
		return
	if not _product_details_ready:
		_set_billing_state("Loading the Google Play product…")
		_billing_client.query_product_details(
			PackedStringArray([REMOVE_ADS_PRODUCT_ID]), BillingClient.ProductType.INAPP
		)
		return

	_set_billing_state("Opening Google Play…")
	var result: Dictionary = _billing_client.purchase(
		REMOVE_ADS_PRODUCT_ID,
		REMOVE_ADS_PURCHASE_OPTION_ID
	)
	if int(result.get("response_code", BillingClient.BillingResponseCode.ERROR)) != BillingClient.BillingResponseCode.OK:
		_fail(str(result.get("debug_message", "Could not start the purchase.")))


func restore_purchases(show_status: bool = true) -> void:
	if _billing_client == null:
		if show_status:
			_fail("Purchase restore is available only in the Android app.")
		return
	if not _billing_client.is_ready():
		if _billing_client.get_connection_state() == BillingClient.ConnectionState.DISCONNECTED:
			_billing_client.start_connection()
		if show_status:
			_set_billing_state("Connecting to Google Play…")
		return
	if show_status:
		_set_billing_state("Restoring purchases…")
	_billing_client.query_purchases(BillingClient.ProductType.INAPP)


func _on_billing_connected() -> void:
	_set_billing_state("Connected to Google Play.")
	_billing_client.query_product_details(
		PackedStringArray([REMOVE_ADS_PRODUCT_ID]), BillingClient.ProductType.INAPP
	)
	_billing_client.query_purchases(BillingClient.ProductType.INAPP)


func _on_billing_disconnected() -> void:
	_product_details_ready = false
	_set_billing_state("Google Play disconnected. Your saved entitlement remains active offline.")


func _on_billing_connect_error(_response_code: int, debug_message: String) -> void:
	_set_billing_state("Google Play connection failed: %s" % debug_message)


func _on_product_details_response(response: Dictionary) -> void:
	if int(response.get("response_code", BillingClient.BillingResponseCode.ERROR)) != BillingClient.BillingResponseCode.OK:
		_product_details_ready = false
		_set_billing_state(str(response.get("debug_message", "Product is unavailable.")))
		product_details_changed.emit()
		return

	_product_details_ready = false
	localized_remove_ads_price = ""
	for raw_product: Variant in response.get("product_details", []):
		if not raw_product is Dictionary:
			continue
		var product := raw_product as Dictionary
		if str(product.get("product_id", "")) != REMOVE_ADS_PRODUCT_ID:
			continue
		_product_details_ready = true
		localized_remove_ads_price = _extract_formatted_price(product)
		break

	if _product_details_ready:
		_set_billing_state("Remove Ads is ready.")
	else:
		_set_billing_state("Remove Ads is not configured in Google Play yet.")
	product_details_changed.emit()


func _on_query_purchases_response(response: Dictionary) -> void:
	if int(response.get("response_code", BillingClient.BillingResponseCode.ERROR)) != BillingClient.BillingResponseCode.OK:
		_set_billing_state(str(response.get("debug_message", "Could not restore purchases.")))
		return

	_process_purchase_snapshot(response.get("purchases", []), true)


func _on_purchase_updated(response: Dictionary) -> void:
	var code := int(response.get("response_code", BillingClient.BillingResponseCode.ERROR))
	if code == BillingClient.BillingResponseCode.USER_CANCELED:
		_fail("Purchase cancelled.")
		return
	if code != BillingClient.BillingResponseCode.OK:
		_fail(str(response.get("debug_message", "Purchase failed.")))
		return

	_process_purchase_snapshot(response.get("purchases", []), false)


func _process_purchase_snapshot(purchases: Variant, authoritative: bool) -> void:
	var owns_product := false
	var has_pending_product := false
	if purchases is Array or purchases is PackedStringArray:
		for raw_purchase: Variant in purchases:
			if not raw_purchase is Dictionary:
				continue
			var purchase := raw_purchase as Dictionary
			if not _purchase_contains_remove_ads(purchase):
				continue
			var state := int(purchase.get("purchase_state", BillingClient.PurchaseState.UNSPECIFIED_STATE))
			if state == BillingClient.PurchaseState.PENDING:
				has_pending_product = true
				continue
			if state != BillingClient.PurchaseState.PURCHASED:
				continue
			owns_product = true
			var token := str(purchase.get("purchase_token", ""))
			if not bool(purchase.get("is_acknowledged", false)) and not token.is_empty():
				_pending_acknowledgements[token] = REMOVE_ADS_PRODUCT_ID
				_billing_client.acknowledge_purchase(token)

	if owns_product:
		_set_remove_ads_owned(true)
		_set_billing_state("Remove Ads is active.")
		purchase_completed.emit(REMOVE_ADS_PRODUCT_ID)
	elif has_pending_product:
		_set_billing_state("Purchase pending in Google Play. Ads remain until payment completes.")
	elif authoritative:
		# A successful Play query is authoritative and also handles refunds/revocations.
		_set_remove_ads_owned(false)
		_set_billing_state("Purchases restored. No Remove Ads purchase was found.")


func _on_acknowledge_purchase_response(response: Dictionary) -> void:
	var token := str(response.get("token", ""))
	if int(response.get("response_code", BillingClient.BillingResponseCode.ERROR)) == BillingClient.BillingResponseCode.OK:
		_pending_acknowledgements.erase(token)
		_set_billing_state("Remove Ads purchase confirmed by Google Play.")
	else:
		_set_billing_state(
			"Remove Ads is active, but Google Play confirmation will be retried: %s"
			% str(response.get("debug_message", "unknown error"))
		)


func _set_remove_ads_owned(value: bool) -> void:
	if remove_ads_owned == value:
		_save_cache()
		return
	remove_ads_owned = value
	_save_cache()
	entitlement_changed.emit(remove_ads_owned)


func _set_billing_state(value: String) -> void:
	billing_state = value
	billing_state_changed.emit(value)


func _fail(message: String) -> void:
	_set_billing_state(message)
	purchase_failed.emit(message)


func _load_cache() -> void:
	var config := ConfigFile.new()
	if config.load(CACHE_PATH) == OK:
		remove_ads_owned = bool(config.get_value("entitlements", "remove_ads_lifetime", false))


func _save_cache() -> void:
	var config := ConfigFile.new()
	config.set_value("entitlements", "remove_ads_lifetime", remove_ads_owned)
	config.set_value("entitlements", "last_local_update", Time.get_unix_time_from_system())
	var error := config.save(CACHE_PATH)
	if error != OK:
		push_warning("[PurchaseManager] Could not save entitlement cache: %s" % error)


static func purchase_snapshot_owns_remove_ads(purchases: Array) -> bool:
	for raw_purchase: Variant in purchases:
		if not raw_purchase is Dictionary:
			continue
		var purchase := raw_purchase as Dictionary
		if _purchase_contains_remove_ads(purchase) and int(
			purchase.get("purchase_state", BillingClient.PurchaseState.UNSPECIFIED_STATE)
		) == BillingClient.PurchaseState.PURCHASED:
			return true
	return false


static func _purchase_contains_remove_ads(purchase: Dictionary) -> bool:
	var product_ids: Variant = purchase.get("product_ids", [])
	if not (product_ids is Array or product_ids is PackedStringArray):
		return false
	return REMOVE_ADS_PRODUCT_ID in product_ids


static func _extract_formatted_price(product: Dictionary) -> String:
	var offer_list: Variant = product.get("one_time_purchase_offer_details_list", [])
	if offer_list is Array:
		var fallback_price := ""
		for raw_offer: Variant in offer_list:
			if raw_offer is Dictionary:
				var offer_data := raw_offer as Dictionary
				var listed_price := str(offer_data.get("formatted_price", ""))
				if listed_price.is_empty():
					continue
				if fallback_price.is_empty():
					fallback_price = listed_price
				if (
					str(offer_data.get("purchase_option_id", "")) == REMOVE_ADS_PURCHASE_OPTION_ID
					and (offer_data.get("offer_id", null) == null or str(offer_data.get("offer_id", "")).is_empty())
				):
					return listed_price
		if not fallback_price.is_empty():
			return fallback_price

	# Keep compatibility with responses produced by older plugin releases.
	var offer: Variant = product.get("one_time_purchase_offer_details", {})
	if not offer is Dictionary:
		return ""
	var offer_data := offer as Dictionary
	if offer_data.has("formatted_price"):
		return str(offer_data.get("formatted_price", ""))
	var keyed_offer: Variant = offer_data.get(REMOVE_ADS_PRODUCT_ID, {})
	if keyed_offer is Dictionary:
		return str((keyed_offer as Dictionary).get("formatted_price", ""))
	return ""
