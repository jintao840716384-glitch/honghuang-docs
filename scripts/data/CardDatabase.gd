extends RefCounted
class_name CardDatabase

const CardDefinitionDatabaseScript = preload("res://scripts/data/CardDefinitionDatabase.gd")
const CardPoolDatabaseScript = preload("res://scripts/data/CardPoolDatabase.gd")

const TYPE_SPELL := CardDefinitionDatabaseScript.TYPE_SPELL
const TYPE_DEFENSE := CardDefinitionDatabaseScript.TYPE_DEFENSE
const MIN_DECK_SIZE := CardDefinitionDatabaseScript.MIN_DECK_SIZE
const MAX_DECK_SIZE := CardDefinitionDatabaseScript.MAX_DECK_SIZE
const COMMON_PACK_PREFIX := CardPoolDatabaseScript.COMMON_PACK_PREFIX
const CARD_PACK_SLOT_COUNT := CardPoolDatabaseScript.CARD_PACK_SLOT_COUNT

static func get_cards() -> Dictionary:
	return CardDefinitionDatabaseScript.get_cards()

static func normalize_card_id(card_id: String) -> String:
	return CardDefinitionDatabaseScript.normalize_card_id(card_id)

static func make_card(card_id: String) -> Dictionary:
	var card: Dictionary = get_card(card_id)
	if card.is_empty():
		return {}
	var canonical_id := str(card.get("id", normalize_card_id(card_id)))
	card["uid"] = "%s_%d_%d" % [canonical_id, Time.get_ticks_usec(), randi()]
	return card

static func get_card(card_id: String) -> Dictionary:
	var card: Dictionary = CardDefinitionDatabaseScript.get_card(card_id)
	if card.is_empty():
		return {}
	return _with_unlock_metadata(card)

static func card_unlock_tier(card_id: String) -> int:
	return CardPoolDatabaseScript.card_unlock_tier(card_id)

static func card_unlock_pack(card_id: String) -> String:
	return CardPoolDatabaseScript.card_unlock_pack(card_id)

static func card_unlock_packs(card_id: String) -> Array:
	return CardPoolDatabaseScript.card_unlock_packs(card_id)

static func unlocked_packs_for_job(job_id: String, unlock_tier := 0) -> Array:
	return CardPoolDatabaseScript.unlocked_packs_for_job(job_id, unlock_tier)

static func pack_ids_for_job(job_id: String, pack_count := CARD_PACK_SLOT_COUNT) -> Array:
	return CardPoolDatabaseScript.pack_ids_for_job(job_id, pack_count)

static func pack_card_counts_for_job(job_id: String, pack_count := CARD_PACK_SLOT_COUNT) -> Dictionary:
	return CardPoolDatabaseScript.pack_card_counts_for_job(job_id, pack_count)

static func card_unlocked_for_job(card_id: String, job_id: String, unlock_tier := 0, unlocked_packs: Array = []) -> bool:
	return CardPoolDatabaseScript.card_unlocked_for_job(card_id, job_id, unlock_tier, unlocked_packs)

static func pack_display_name(pack_id: String) -> String:
	return CardPoolDatabaseScript.pack_display_name(pack_id)

static func card_score(card_id: String) -> int:
	return CardDefinitionDatabaseScript.card_score(card_id)

static func shop_price(card_id: String) -> int:
	return CardPoolDatabaseScript.shop_price(card_id)

static func sell_price(card_id: String) -> int:
	return CardPoolDatabaseScript.sell_price(card_id)

static func has_tag(card: Dictionary, tag: String) -> bool:
	return CardDefinitionDatabaseScript.has_tag(card, tag)

static func type_label(card_type: String) -> String:
	return CardDefinitionDatabaseScript.type_label(card_type)

static func common_pool() -> Array:
	return CardPoolDatabaseScript.common_pool()

static func job_pool(job_id: String) -> Array:
	return CardPoolDatabaseScript.job_pool(job_id)

static func sword_pool() -> Array:
	return job_pool("sword")

static func talisman_pool() -> Array:
	return job_pool("talisman")

static func reward_pool_for_job(job_id: String, encounter_type := "normal", unlock_tier := 0, unlocked_packs: Array = []) -> Array:
	return CardPoolDatabaseScript.reward_pool_for_job(job_id, encounter_type, unlock_tier, unlocked_packs)

static func reward_pool_for_cost(job_id: String, min_cost: int, max_cost: int, scope := "all", unlock_tier := 0, unlocked_packs: Array = []) -> Array:
	return CardPoolDatabaseScript.reward_pool_for_cost(job_id, min_cost, max_cost, scope, unlock_tier, unlocked_packs)

static func random_reward_card(job_id: String, rng, min_cost: int, max_cost: int, unlock_tier := 0, unlocked_packs: Array = []) -> String:
	return CardPoolDatabaseScript.random_reward_card(job_id, rng, min_cost, max_cost, unlock_tier, unlocked_packs)

static func shop_stock(job_id: String, realm_index: int, rng, count := 6, unlock_tier := 0, unlocked_packs: Array = []) -> Array:
	return CardPoolDatabaseScript.shop_stock(job_id, realm_index, rng, count, unlock_tier, unlocked_packs)

static func _with_unlock_metadata(card: Dictionary) -> Dictionary:
	var card_id := str(card.get("id", ""))
	var unlock_packs: Array = CardPoolDatabaseScript.card_unlock_packs(card_id)
	var has_unlock_source := not unlock_packs.is_empty()
	if not card.has("unlock_tier"):
		card["unlock_tier"] = CardPoolDatabaseScript.card_unlock_tier(card_id)
	if not card.has("unlock_pack"):
		card["unlock_pack"] = CardPoolDatabaseScript.card_unlock_pack(card_id)
	if not card.has("unlock_packs"):
		card["unlock_packs"] = unlock_packs.duplicate()
	if not card.has("default_unlocked"):
		card["default_unlocked"] = has_unlock_source and int(card.get("unlock_tier", 0)) <= 0
	return card
