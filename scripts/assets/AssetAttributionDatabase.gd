extends RefCounted
class_name AssetAttributionDatabase

const LICENSE_UNKNOWN := "unknown"
const LICENSE_ORIGINAL := "original"
const LICENSE_PURCHASED := "purchased"
const LICENSE_CC0 := "cc0"
const LICENSE_CC_BY := "cc_by"

static func attribution_records() -> Dictionary:
	return {
		"placeholder.internal": {
			"id": "placeholder.internal",
			"asset_ids": ["ui.default_background", "character.default_portrait", "music.main_menu"],
			"source": "internal_placeholder",
			"author": "project",
			"license": LICENSE_ORIGINAL,
			"commercial_use": true,
			"notes": "程序占位素材和占位事件，不代表最终素材。"
		}
	}

static func record(record_id: String) -> Dictionary:
	var records: Dictionary = attribution_records()
	if records.has(record_id):
		return (records[record_id] as Dictionary).duplicate(true)
	return {}

static func records_for_asset(asset_id: String) -> Array:
	var result: Array = []
	for record_variant in attribution_records().values():
		var record_data: Dictionary = record_variant
		var asset_ids: Array = record_data.get("asset_ids", [])
		if asset_ids.has(asset_id):
			result.append(record_data.duplicate(true))
	return result

static func has_commercial_clearance(asset_id: String) -> bool:
	var records := records_for_asset(asset_id)
	if records.is_empty():
		return false
	for record_data_variant in records:
		var record_data: Dictionary = record_data_variant
		if bool(record_data.get("commercial_use", false)):
			return true
	return false

static func unknown_assets(asset_ids: Array) -> Array:
	var result: Array = []
	for asset_id_variant in asset_ids:
		var asset_id := str(asset_id_variant)
		if not has_commercial_clearance(asset_id):
			result.append(asset_id)
	return result
