extends RefCounted
class_name BattleUnit

const TEAM_PLAYER := "player"
const TEAM_ENEMY := "enemy"
const TYPE_PLAYER := "player"
const TYPE_ENEMY := "enemy"
const TYPE_SUMMON := "summon"
const TYPE_ARTIFACT := "artifact"
const RANK_MAIN := "main"
const RANK_NORMAL := "normal"
const RANK_ELITE := "elite"
const RANK_BOSS := "boss"

var uid := ""
var unit_id := ""
var name := ""
var team := ""
var unit_type := ""
var unit_rank := RANK_NORMAL
var unit_tags: Array = []
var visual_profile_id := ""
var portrait_asset_id := ""
var battle_sprite_asset_id := ""
var battle_animation_profile_id := ""
var icon_asset_id := ""
var slot_index := 0
var max_hp := 0
var hp := 0
var attack := 0
var defense := 0
var equipment: Array = []
var equipment_limit := 1
var equipment_attack_bonus := 0
var equipment_defense_bonus := 0
var temp_attack_delta := 0
var temp_defense_delta := 0
var status_counters: Dictionary = {}
var resource_counters: Dictionary = {}
var selectable := true
var alive := true

func setup_unit(data: Dictionary, default_team := "", default_type := "") -> void:
	unit_id = str(data.get("id", data.get("unit_id", "")))
	uid = str(data.get("uid", unit_id))
	name = str(data.get("name", data.get("display_name", unit_id)))
	team = str(data.get("team", default_team))
	unit_type = str(data.get("unit_type", default_type))
	unit_rank = str(data.get("unit_rank", data.get("rank", _default_rank_for_type(unit_type))))
	unit_tags = data.get("unit_tags", []).duplicate()
	visual_profile_id = str(data.get("visual_profile_id", data.get("visual_id", data.get("animation_profile", ""))))
	portrait_asset_id = str(data.get("portrait_asset_id", ""))
	battle_sprite_asset_id = str(data.get("battle_sprite_asset_id", ""))
	battle_animation_profile_id = str(data.get("battle_animation_profile_id", data.get("animation_profile", visual_profile_id)))
	icon_asset_id = str(data.get("icon_asset_id", ""))
	slot_index = int(data.get("slot_index", 0))
	max_hp = int(data.get("max_hp", 0))
	hp = int(data.get("hp", max_hp))
	attack = int(data.get("attack", 0))
	defense = int(data.get("defense", 0))
	equipment = data.get("equipment", []).duplicate(true)
	equipment_limit = int(data.get("equipment_limit", _default_equipment_limit(unit_rank)))
	equipment_attack_bonus = int(data.get("equipment_attack_bonus", 0))
	equipment_defense_bonus = int(data.get("equipment_defense_bonus", 0))
	temp_attack_delta = int(data.get("temp_attack_delta", 0))
	temp_defense_delta = int(data.get("temp_defense_delta", 0))
	status_counters = data.get("status_counters", {}).duplicate(true)
	resource_counters = data.get("resource_counters", {}).duplicate(true)
	selectable = bool(data.get("selectable", true))
	alive = hp > 0

func current_attack() -> int:
	return max(0, attack + temp_attack_delta + equipment_attack_bonus - get_status("虚弱"))

func current_defense() -> int:
	return max(0, defense + temp_defense_delta + equipment_defense_bonus - get_status("破甲"))

func has_equipment(card_id: String) -> bool:
	for card in equipment:
		if str(card.get("id", "")) == card_id:
			return true
	return false

func has_unit_tag(tag: String) -> bool:
	return unit_tags.has(tag)

func add_unit_tag(tag: String) -> void:
	if tag != "" and not unit_tags.has(tag):
		unit_tags.append(tag)

func apply_damage(amount: int) -> int:
	var value: int = max(0, amount)
	hp = max(0, hp - value)
	alive = hp > 0
	return value

func heal(amount: int) -> int:
	var before: int = hp
	hp = min(max_hp, hp + max(0, amount))
	alive = hp > 0
	return hp - before

func add_resource(resource_id: String, amount: int, min_value := 0) -> int:
	var current := int(resource_counters.get(resource_id, 0))
	var next_value: int = max(min_value, current + amount)
	resource_counters[resource_id] = next_value
	return next_value

func set_resource(resource_id: String, value: int) -> void:
	resource_counters[resource_id] = value

func get_resource(resource_id: String) -> int:
	return int(resource_counters.get(resource_id, 0))

func add_status(status_id: String, amount: int, min_value := 0) -> int:
	var current := int(status_counters.get(status_id, 0))
	var next_value: int = max(min_value, current + amount)
	if next_value <= 0:
		status_counters.erase(status_id)
	else:
		status_counters[status_id] = next_value
	return next_value

func get_status(status_id: String) -> int:
	return int(status_counters.get(status_id, 0))

func clear_temporary_stats() -> void:
	temp_attack_delta = 0
	temp_defense_delta = 0

func _default_rank_for_type(type_id: String) -> String:
	if type_id == TYPE_PLAYER:
		return RANK_MAIN
	return RANK_NORMAL

func _default_equipment_limit(rank_id: String) -> int:
	match rank_id:
		RANK_MAIN:
			return 2
		RANK_ELITE:
			return 2
		RANK_BOSS:
			return 3
	return 1
