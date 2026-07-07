extends SceneTree

const BattleManagerScript = preload("res://scripts/battle/BattleManager.gd")
const CardDatabaseScript = preload("res://scripts/data/CardDatabase.gd")
const DeckBuildRulesScript = preload("res://scripts/run/DeckBuildRules.gd")

const PLAYER_BASE_HP := 35
const SCORE_LIMIT := 20

const DECKS := {
	"starter_sword": [
		"青锋剑",
		"起剑诀", "起剑诀",
		"引剑入体",
		"藏锋",
		"小无相剑",
		"护身符",
		"回春符",
		"疾剑诀",
		"金刃符"
	],
	"common_basic": [
		"火球符", "火球符",
		"金刃符", "金刃符",
		"回春符", "回春符",
		"小还丹",
		"护身符", "护身符",
		"青锋剑"
	],
	"common_toolbox": [
		"火球符",
		"金刃符",
		"回春符",
		"小还丹",
		"固元符",
		"换气符",
		"破甲符",
		"护身符",
		"青锋剑",
		"铁木甲"
	],
	"sword_no_weapon": [
		"起剑诀", "起剑诀", "起剑诀",
		"引剑入体", "引剑入体",
		"疾剑诀",
		"藏锋",
		"护身符",
		"回春符",
		"金刃符"
	]
}

const ROUTES := {
	"easy_route": [
		{"battle_number": 1, "type": "normal", "after": "reward"},
		{"battle_number": 2, "type": "normal", "after": "reward"},
		{"battle_number": 3, "type": "normal", "after": "treasure"},
		{"battle_number": 5, "type": "normal", "after": "rest"},
		{"battle_number": 7, "type": "boss", "after": "reward"}
	],
	"mixed_route": [
		{"battle_number": 1, "type": "normal", "after": "reward"},
		{"battle_number": 2, "type": "normal", "after": "reward"},
		{"battle_number": 3, "type": "elite", "after": "treasure"},
		{"battle_number": 5, "type": "normal", "after": "rest"},
		{"battle_number": 7, "type": "boss", "after": "reward"}
	],
	"combat_heavy": [
		{"battle_number": 1, "type": "normal", "after": "reward"},
		{"battle_number": 2, "type": "normal", "after": "reward"},
		{"battle_number": 3, "type": "elite", "after": "reward"},
		{"battle_number": 4, "type": "elite", "after": "treasure"},
		{"battle_number": 5, "type": "elite", "after": "rest"},
		{"battle_number": 6, "type": "elite", "after": "reward"},
		{"battle_number": 7, "type": "boss", "after": "reward"}
	]
}

var rng := RandomNumberGenerator.new()

func _init() -> void:
	rng.seed = 20260707
	var report: Array = []
	for deck_name in DECKS.keys():
		for route_name in ROUTES.keys():
			report.append(_run_case(str(deck_name), DECKS[deck_name], str(route_name), ROUTES[route_name], 80))
	for line in report:
		print(line)
	quit(0)

func _run_case(deck_name: String, base_deck: Array, route_name: String, route: Array, runs: int) -> String:
	var wins := 0
	var hp_total := 0
	var fail_stage_total := 0
	var worst_stage := 999
	for run_index in range(runs):
		var state := {
			"deck": base_deck.duplicate(),
			"reserve": [],
			"hp": PLAYER_BASE_HP,
			"max_hp": PLAYER_BASE_HP
		}
		var failed_stage := 0
		for stage_index in range(route.size()):
			var node: Dictionary = route[stage_index]
			var result: Dictionary = _run_battle(state, int(node.get("battle_number", 1)), str(node.get("type", "normal")))
			state["deck"] = result.get("deck", state["deck"])
			state["reserve"] = result.get("reserve", state["reserve"])
			state["hp"] = int(result.get("hp", 0))
			state["max_hp"] = int(result.get("max_hp", PLAYER_BASE_HP))
			if int(state.get("hp", 0)) <= 0:
				failed_stage = stage_index + 1
				break
			_apply_after_node_reward(state, str(node.get("after", "")))
		if failed_stage == 0:
			wins += 1
			hp_total += int(state.get("hp", 0))
		else:
			fail_stage_total += failed_stage
			worst_stage = min(worst_stage, failed_stage)
	var losses := runs - wins
	var avg_hp := 0.0 if wins <= 0 else float(hp_total) / float(wins)
	var avg_fail_stage := 0.0 if losses <= 0 else float(fail_stage_total) / float(losses)
	var deck_score: int = DeckBuildRulesScript.deck_score(base_deck)
	return "%s | %s | score %d | win %d/%d (%.1f%%) | avg_win_hp %.1f | avg_fail_stage %.1f | earliest_fail %s" % [
		deck_name,
		route_name,
		deck_score,
		wins,
		runs,
		100.0 * float(wins) / float(runs),
		avg_hp,
		avg_fail_stage,
		"-" if losses == 0 else str(worst_stage)
	]

func _run_battle(state: Dictionary, battle_number: int, encounter_type: String) -> Dictionary:
	var battle = BattleManagerScript.new()
	battle.start_run_with_deck("sword", state.get("deck", []).duplicate(), battle_number, encounter_type, false, {
		"current_hp": int(state.get("hp", PLAYER_BASE_HP)),
		"max_hp": int(state.get("max_hp", PLAYER_BASE_HP)),
		"draw_per_turn": 1,
		"deck_score_limit": SCORE_LIMIT,
		"reserve_ids": state.get("reserve", []).duplicate(),
		"realm_index": 0,
		"realm_name": "练气剑修",
		"meta_bonuses": {}
	})
	var guard := 0
	while guard < 24 and battle.phase != "reward" and battle.phase != "defeat":
		guard += 1
		_play_player_turn(battle)
	if battle.phase == "reward" and not battle.reward_options.is_empty():
		var reward_id := _pick_reward(battle.reward_options, battle.master_deck_ids)
		battle.choose_reward(reward_id)
	return {
		"deck": battle.master_deck_ids.duplicate(),
		"reserve": battle.master_reserve_ids.duplicate(),
		"hp": battle.player.hp,
		"max_hp": battle.player.max_hp
	}

func _play_player_turn(battle) -> void:
	var action_guard := 0
	while battle.phase == "player" and action_guard < 40:
		action_guard += 1
		if _resolve_pending(battle):
			continue
		if _play_next_useful_card(battle):
			continue
		if _take_best_unit_action(battle):
			continue
		battle.end_player_turn()
	while battle.phase == "response" and action_guard < 55:
		action_guard += 1
		var responses: Array = battle.get_available_responses_for_current_event()
		var chosen_uid := _best_response_uid(responses)
		if chosen_uid == "":
			battle.skip_response()
		else:
			battle.add_card_to_chain(chosen_uid)
	while battle.phase == "target_select":
		battle.confirm_target_selection(str(battle.enemy.uid))

func _resolve_pending(battle) -> bool:
	if not battle.pending_equipment_replace.is_empty():
		var target_uid := str(battle.pending_equipment_replace.get("target_uid", ""))
		var target = battle.formation.unit_by_uid(target_uid)
		if target != null and not target.equipment.is_empty():
			battle.choose_equipment_replacement(str(target.equipment[0].get("uid", "")))
			return true
	if not battle.pending_choice.is_empty():
		var options: Array = battle.get_pending_options()
		if options.is_empty():
			battle.pending_choice.clear()
			return true
		battle.choose_pending(str(options[0].get("uid", "")))
		return true
	return false

func _play_next_useful_card(battle) -> bool:
	var priority := [
		"青锋剑", "玄铁剑", "护心镜", "铁木甲",
		"护身符", "藏锋",
		"回春符", "小还丹", "甘露符",
		"起剑诀", "引剑入体", "小无相剑", "疾剑诀",
		"破甲符", "固元符",
		"雷击符", "裂石符", "火球符", "金刃符"
	]
	for wanted in priority:
		var card := _find_hand_card(battle, wanted)
		if card.is_empty():
			continue
		if not _should_play_card(battle, card):
			continue
		var before_hand: int = battle.deck.hand.size()
		var uid := str(card.get("uid", ""))
		if str(card.get("after_use", "")) == "equipment":
			battle.play_hand_card_on_unit_target(uid, str(battle.player.uid))
		elif _is_enemy_target_card(card):
			battle.play_hand_card_on_enemy_target(uid, str(battle.enemy.uid))
		else:
			battle.play_hand_card(uid)
		if battle.phase == "target_select":
			battle.confirm_target_selection(str(battle.enemy.uid))
		return battle.deck.hand.size() != before_hand or not battle.pending_choice.is_empty() or not battle.pending_equipment_replace.is_empty()
	return false

func _should_play_card(battle, card: Dictionary) -> bool:
	var id := str(card.get("id", ""))
	if id in ["回春符", "小还丹", "甘露符"]:
		return battle.player.hp <= battle.player.max_hp - 4
	if id == "小无相剑":
		return battle.player.sword_momentum >= 5 and battle.player.attack_actions_bonus <= 0
	if id == "疾剑诀":
		return battle.player.sword_momentum >= 3
	if id == "引剑入体":
		return battle.player.sword_momentum >= 2
	if id == "青锋剑" and battle.player.has_equipment("青锋剑"):
		return false
	if id == "铁木甲" and battle.player.has_equipment("铁木甲"):
		return false
	if id == "玄铁剑" and battle.player.has_equipment("玄铁剑"):
		return false
	if int(card.get("effect", {}).get("sword_cost", 0)) > battle.player.sword_momentum:
		return false
	return battle.resolver.can_play_spell(battle, card, true, {"equipment_target_uid": str(battle.player.uid)})

func _take_best_unit_action(battle) -> bool:
	var units: Array = battle.formation.living_units("player")
	for unit in units:
		if unit == null or battle.player_unit_action_used(unit):
			continue
		var damage: int = max(0, unit.current_attack() - battle.enemy.current_defense())
		if damage > 0:
			battle.player_unit_attack(str(unit.uid))
			if battle.phase == "target_select":
				battle.confirm_target_selection(str(battle.enemy.uid))
		else:
			battle.player_unit_defend(str(unit.uid))
		return true
	return false

func _best_response_uid(responses: Array) -> String:
	var priority := ["攻击无效符", "护身符", "反震符", "藏锋", "破法符", "护心符"]
	for wanted in priority:
		for card_variant in responses:
			var card: Dictionary = card_variant
			if str(card.get("id", "")) == wanted:
				return str(card.get("uid", ""))
	return ""

func _pick_reward(options: Array, deck: Array) -> String:
	var best_id := str(options[0])
	var best_score := -999
	var weights := {
		"回春符": 12,
		"小还丹": 10,
		"青锋剑": 10,
		"起剑诀": 9,
		"引剑入体": 8,
		"火球符": 8,
		"金刃符": 8,
		"护身符": 7,
		"破甲符": 6
	}
	for id_variant in options:
		var id := str(id_variant)
		if not DeckBuildRulesScript.can_add_card_to_deck(id, deck, SCORE_LIMIT):
			continue
		var score: int = int(weights.get(id, 0)) - DeckBuildRulesScript.card_score(id)
		if score > best_score:
			best_score = score
			best_id = id
	return best_id

func _apply_after_node_reward(state: Dictionary, reward_type: String) -> void:
	match reward_type:
		"rest":
			state["hp"] = state.get("max_hp", PLAYER_BASE_HP)
		"treasure":
			var deck: Array = state.get("deck", [])
			for id in ["回春符", "火球符", "护身符", "起剑诀"]:
				if DeckBuildRulesScript.can_add_card_to_deck(id, deck, SCORE_LIMIT):
					deck.append(id)
					state["deck"] = deck
					return

func _find_hand_card(battle, card_id: String) -> Dictionary:
	for card_variant in battle.deck.hand:
		var card: Dictionary = card_variant
		if str(card.get("id", "")) == card_id:
			return card
	return {}

func _is_enemy_target_card(card: Dictionary) -> bool:
	var effect: Dictionary = card.get("effect", {})
	var kind := str(effect.get("kind", ""))
	return kind in ["direct_damage", "reduce_enemy_defense"] or (kind == "multi" and str(card.get("after_use", "")) != "equipment")
