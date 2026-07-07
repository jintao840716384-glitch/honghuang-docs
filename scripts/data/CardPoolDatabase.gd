extends RefCounted
class_name CardPoolDatabase

const CardDefinitionDatabaseScript = preload("res://scripts/data/CardDefinitionDatabase.gd")

const COMMON_PACK_PREFIX := "common"
const CARD_PACK_SLOT_COUNT := 5

const CARD_UNLOCK_PACKS := {
	"火球符": ["common_1"],
	"金刃符": ["common_1"],
	"回春符": ["common_1"],
	"小还丹": ["common_1"],
	"固元符": ["common_1"],
	"血墨符": ["common_1"],
	"换气符": ["common_1"],
	"破甲符": ["common_1"],
	"护身符": ["common_1"],
	"幻象术": ["common_1"],
	"青锋剑": ["common_1"],
	"铁木甲": ["common_1"],
	"雷击符": ["common_2"],
	"裂石符": ["common_2"],
	"甘露符": ["common_2"],
	"引路符": ["common_2"],
	"清囊术": ["common_2"],
	"封存秘卷": ["common_2"],
	"缚身符": ["common_2"],
	"折光符": ["common_2"],
	"护阵符": ["common_2"],
	"反震符": ["common_2"],
	"破法符": ["common_2"],
	"护心符": ["common_2"],
	"封藏符": ["common_2"],
	"凝神香": ["common_2"],
	"护法灯": ["common_2"],
	"锁妖符": ["common_2"],
	"木偶侍": ["common_2"],
	"纸甲兵": ["common_2"],
	"炽火符": ["common_3"],
	"天雷符": ["common_3"],
	"灭灵符": ["common_3"],
	"玉露丹": ["common_3"],
	"攻击无效符": ["common_3"],
	"替身纸人": ["common_3"],
	"落雷阵": ["common_3"],
	"伏雷符": ["common_3"],
	"玄铁剑": ["common_3"],
	"护心镜": ["common_3"],
	"起剑诀": ["sword_1"],
	"引剑入体": ["sword_1"],
	"藏锋": ["sword_1"],
	"疾剑诀": ["sword_1"],
	"养剑匣": ["sword_2"],
	"剑气横扫": ["sword_2"],
	"召剑诀": ["sword_2"],
	"万剑回风": ["sword_3"],
	"小无相剑": ["sword_3"],
	"万剑诀": ["sword_3"],
	"一剑开天": ["sword_3"],
	"拾符诀": ["talisman_1"],
	"复符诀": ["talisman_2"],
	"灵墨重描": ["talisman_2"],
	"符匣": ["talisman_2"]
}


static func card_unlock_tier(card_id: String) -> int:
	var packs: Array = card_unlock_packs(card_id)
	if packs.is_empty():
		return 0
	return _tier_from_pack(str(packs[0]))


static func card_unlock_pack(card_id: String) -> String:
	var packs: Array = card_unlock_packs(card_id)
	return "common_1" if packs.is_empty() else str(packs[0])


static func card_unlock_packs(card_id: String) -> Array:
	var packs: Array = CARD_UNLOCK_PACKS.get(card_id, [])
	return packs.duplicate()


static func unlocked_packs_for_job(job_id: String, unlock_tier := 0) -> Array:
	var result: Array = []
	var max_tier: int = max(0, int(unlock_tier))
	for tier_index in range(max_tier + 1):
		result.append("%s_%d" % [COMMON_PACK_PREFIX, tier_index + 1])
		var job_prefix := _pack_prefix_for_job(job_id)
		if job_prefix != "":
			result.append("%s_%d" % [job_prefix, tier_index + 1])
	return _deduplicate_strings(result)


static func pack_ids_for_job(job_id: String, pack_count := CARD_PACK_SLOT_COUNT) -> Array:
	var result: Array = []
	var count: int = max(1, int(pack_count))
	var job_prefix := _pack_prefix_for_job(job_id)
	for tier_index in range(count):
		result.append("%s_%d" % [COMMON_PACK_PREFIX, tier_index + 1])
		if job_prefix != "":
			result.append("%s_%d" % [job_prefix, tier_index + 1])
	return _deduplicate_strings(result)


static func pack_card_counts_for_job(job_id: String, pack_count := CARD_PACK_SLOT_COUNT) -> Dictionary:
	var result: Dictionary = {}
	for pack_id_variant in pack_ids_for_job(job_id, pack_count):
		result[str(pack_id_variant)] = 0
	var pool := common_pool()
	pool.append_array(job_pool(job_id))
	for card_id_variant in pool:
		for pack_variant in card_unlock_packs(str(card_id_variant)):
			var pack_id := str(pack_variant)
			if result.has(pack_id):
				result[pack_id] = int(result.get(pack_id, 0)) + 1
	return result


static func card_unlocked_for_job(card_id: String, job_id: String, unlock_tier := 0, unlocked_packs: Array = []) -> bool:
	var packs: Array = unlocked_packs.duplicate() if not unlocked_packs.is_empty() else unlocked_packs_for_job(job_id, unlock_tier)
	for pack_variant in card_unlock_packs(card_id):
		if packs.has(str(pack_variant)):
			return true
	return false


static func pack_display_name(pack_id: String) -> String:
	var parts := pack_id.split("_")
	if parts.size() < 2:
		return pack_id
	var prefix := str(parts[0])
	var number := str(parts[1])
	match prefix:
		"common":
			return "通用%s" % number
		"sword":
			return "剑修%s" % number
		"talisman":
			return "符修%s" % number
	return pack_id


static func shop_price(card_id: String) -> int:
	var card := CardDefinitionDatabaseScript.get_card(card_id)
	if card.is_empty():
		return 0
	if card.has("shop_price"):
		return int(card.get("shop_price", 0))
	return 12 + CardDefinitionDatabaseScript.card_score(card_id) * 8


static func sell_price(card_id: String) -> int:
	var price := shop_price(card_id)
	if price <= 0:
		return 0
	return max(4, int(round(float(price) * 0.45)))


static func common_pool() -> Array:
	return [
		"火球符", "金刃符", "雷击符", "裂石符", "炽火符", "天雷符", "灭灵符",
		"回春符", "小还丹", "甘露符", "玉露丹", "固元符",
		"血墨符", "换气符", "引路符", "清囊术", "封存秘卷",
		"破甲符", "缚身符",
		"护身符", "攻击无效符", "折光符", "护阵符", "反震符", "替身纸人", "破法符", "护心符", "落雷阵",
		"封藏符", "凝神香", "护法灯", "伏雷符", "锁妖符",
		"幻象术", "木偶侍", "纸甲兵",
		"青锋剑", "铁木甲", "玄铁剑", "护心镜"
	]


static func job_pool(job_id: String) -> Array:
	match job_id:
		"sword":
			return ["起剑诀", "引剑入体", "养剑匣", "疾剑诀", "剑气横扫", "藏锋", "万剑回风", "小无相剑", "召剑诀", "万剑诀", "一剑开天"]
		"talisman":
			return ["拾符诀", "复符诀", "灵墨重描", "符匣"]
	return []


static func reward_pool_for_job(job_id: String, encounter_type := "normal", unlock_tier := 0, unlocked_packs: Array = []) -> Array:
	var pool := common_pool()
	pool.append_array(job_pool(job_id))
	return _filter_reward_pool_by_encounter(_filter_pool_by_unlock(pool, job_id, unlock_tier, unlocked_packs), encounter_type)


static func reward_pool_for_cost(job_id: String, min_cost: int, max_cost: int, scope := "all", unlock_tier := 0, unlocked_packs: Array = []) -> Array:
	var pool: Array = []
	if scope == "all" or scope == "common":
		pool.append_array(common_pool())
	if scope == "all" or scope == "job":
		pool.append_array(job_pool(job_id))
	return _filter_pool_by_cost(_filter_pool_by_unlock(pool, job_id, unlock_tier, unlocked_packs), min_cost, max_cost)


static func random_reward_card(job_id: String, rng, min_cost: int, max_cost: int, unlock_tier := 0, unlocked_packs: Array = []) -> String:
	var scopes := ["common", "job"]
	if _rng_float(rng) < 0.5:
		scopes.reverse()
	for scope in scopes:
		var scoped_pool: Array = reward_pool_for_cost(job_id, min_cost, max_cost, scope, unlock_tier, unlocked_packs)
		if not scoped_pool.is_empty():
			return str(scoped_pool[_rng_range(rng, 0, scoped_pool.size() - 1)])
	var fallback: Array = reward_pool_for_cost(job_id, 0, 99, "all", unlock_tier, unlocked_packs)
	if fallback.is_empty():
		return ""
	return str(fallback[_rng_range(rng, 0, fallback.size() - 1)])


static func shop_stock(job_id: String, realm_index: int, rng, count := 6, unlock_tier := 0, unlocked_packs: Array = []) -> Array:
	var stock: Array = []
	var attempts := 0
	var max_cost := 8 + realm_index * 4
	while stock.size() < count and attempts < 80:
		attempts += 1
		var card_id := random_reward_card(job_id, rng, 0, max_cost, unlock_tier, unlocked_packs)
		if card_id == "":
			break
		var duplicate := false
		for item in stock:
			if str((item as Dictionary).get("card_id", "")) == card_id:
				duplicate = true
				break
		if duplicate:
			continue
		stock.append({"card_id": card_id, "price": shop_price(card_id)})
	return stock


static func _filter_reward_pool_by_encounter(pool: Array, encounter_type: String) -> Array:
	var result: Array = []
	var min_cost := 0
	var max_cost := 6
	match encounter_type:
		"elite":
			min_cost = 1
			max_cost = 12
		"boss":
			min_cost = 3
			max_cost = 99
	for card_id_variant in pool:
		var card_id := str(card_id_variant)
		var cost := CardDefinitionDatabaseScript.card_score(card_id)
		if cost >= min_cost and cost <= max_cost:
			result.append(card_id)
	if result.size() >= 3:
		return result
	if encounter_type == "boss":
		var relaxed_boss: Array = _filter_pool_by_cost(pool, 1, 99)
		if relaxed_boss.size() >= 3:
			return relaxed_boss
	elif encounter_type == "elite":
		var relaxed_elite: Array = _filter_pool_by_cost(pool, 0, 12)
		if relaxed_elite.size() >= 3:
			return relaxed_elite
	if result.is_empty():
		return pool
	return result


static func _filter_pool_by_cost(pool: Array, min_cost: int, max_cost: int) -> Array:
	var result: Array = []
	for card_id_variant in pool:
		var card_id := str(card_id_variant)
		var cost := CardDefinitionDatabaseScript.card_score(card_id)
		if cost >= min_cost and cost <= max_cost:
			result.append(card_id)
	return result


static func _filter_pool_by_unlock(pool: Array, job_id: String, unlock_tier: int, unlocked_packs: Array = []) -> Array:
	var result: Array = []
	var packs: Array = unlocked_packs.duplicate() if not unlocked_packs.is_empty() else unlocked_packs_for_job(job_id, unlock_tier)
	for card_id_variant in pool:
		var card_id := str(card_id_variant)
		if card_unlocked_for_job(card_id, job_id, unlock_tier, packs):
			result.append(card_id)
	return result


static func _tier_from_pack(pack_id: String) -> int:
	var parts := pack_id.split("_")
	if parts.size() < 2:
		return 0
	return max(0, int(parts[1]) - 1)


static func _pack_prefix_for_job(job_id: String) -> String:
	match job_id:
		"sword":
			return "sword"
		"talisman":
			return "talisman"
	return ""


static func _deduplicate_strings(values: Array) -> Array:
	var result: Array = []
	for value in values:
		var text := str(value)
		if text != "" and not result.has(text):
			result.append(text)
	return result


static func _rng_float(rng) -> float:
	if rng != null and rng.has_method("randf"):
		return float(rng.call("randf"))
	return randf()


static func _rng_range(rng, from_value: int, to_value: int) -> int:
	if to_value <= from_value:
		return from_value
	if rng != null and rng.has_method("randi_range"):
		return int(rng.call("randi_range", from_value, to_value))
	return randi_range(from_value, to_value)
