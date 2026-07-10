extends SceneTree

const BattleManagerScript = preload("res://scripts/battle/BattleManager.gd")
const CardDatabaseScript = preload("res://scripts/data/CardDatabase.gd")
const CardPoolDatabaseScript = preload("res://scripts/data/CardPoolDatabase.gd")
const DeckBuildRulesScript = preload("res://scripts/run/DeckBuildRules.gd")

const PLAYER_BASE_HP := 35
const JOB_ID := "sword"
const BASE_SEED := 73421
const ROUTE := [
	{"battle_number": 1, "type": "normal"},
	{"battle_number": 2, "type": "normal"},
	{"battle_number": 3, "type": "elite"},
	{"battle_number": 5, "type": "normal"},
	{"battle_number": 7, "type": "boss"}
]

const STARTER_SWORD := [
	"break_defense_setup", "break_defense_setup",
	"weaken_attack_setup", "weaken_attack_setup",
	"defense_setup", "defense_setup",
	"heal_wound",
	"clear_buff",
	"poison", "poison"
]

const SCENARIOS := [
	{
		"id": "p0_no_meta_pack1",
		"spent_hint": 0,
		"max_hp": 35,
		"draw_per_turn": 1,
		"deck_score_limit": 20,
		"meta_bonuses": {"card_unlock_tier": 0}
	},
	{
		"id": "p1_hp2_pack1",
		"spent_hint": 30,
		"max_hp": 41,
		"draw_per_turn": 1,
		"deck_score_limit": 20,
		"meta_bonuses": {"max_hp": 6, "card_unlock_tier": 0}
	},
	{
		"id": "p2_hp2_attack1_pack1",
		"spent_hint": 58,
		"max_hp": 41,
		"draw_per_turn": 1,
		"deck_score_limit": 20,
		"meta_bonuses": {"max_hp": 6, "attack": 1, "card_unlock_tier": 0}
	},
	{
		"id": "p3_unlock2_score1",
		"spent_hint": 116,
		"max_hp": 41,
		"draw_per_turn": 1,
		"deck_score_limit": 22,
		"meta_bonuses": {"max_hp": 6, "attack": 1, "deck_score_limit": 2, "card_unlock_tier": 1}
	},
	{
		"id": "p4_mature_pack3",
		"spent_hint": 350,
		"max_hp": 44,
		"draw_per_turn": 1,
		"deck_score_limit": 24,
		"meta_bonuses": {"max_hp": 9, "attack": 1, "defense": 1, "deck_score_limit": 4, "starting_sword": 1, "card_unlock_tier": 2}
	},
	{
		"id": "p5_draw_breakpoint",
		"spent_hint": 633,
		"max_hp": 47,
		"draw_per_turn": 2,
		"deck_score_limit": 26,
		"meta_bonuses": {"max_hp": 12, "attack": 2, "defense": 1, "deck_score_limit": 6, "draw_per_turn": 1, "starting_sword": 1, "card_unlock_tier": 2}
	}
]

func _init() -> void:
	_print_pool_audit()
	var scenario_index := 0
	for scenario_variant in SCENARIOS:
		var scenario: Dictionary = scenario_variant
		print(_run_case(scenario, 80, scenario_index))
		scenario_index += 1
	quit(0)

func _print_pool_audit() -> void:
	for tier in [0, 1, 2]:
		var normal_pool: Array = CardPoolDatabaseScript.reward_pool_for_job(JOB_ID, "normal", int(tier))
		var elite_pool: Array = CardPoolDatabaseScript.reward_pool_for_job(JOB_ID, "elite", int(tier))
		var boss_pool: Array = CardPoolDatabaseScript.reward_pool_for_job(JOB_ID, "boss", int(tier))
		var packs: Array = CardPoolDatabaseScript.unlocked_packs_for_job(JOB_ID, int(tier))
		print("pack_tier %d | packs %s | normal %d | elite %d | boss %d" % [
			tier,
			_pack_summary(packs),
			normal_pool.size(),
			elite_pool.size(),
			boss_pool.size()
		])
	var locked_starter_cards: Array = []
	for card_id_variant in STARTER_SWORD:
		var card_id := str(card_id_variant)
		if not CardPoolDatabaseScript.card_unlocked_for_job(card_id, JOB_ID, 0):
			locked_starter_cards.append(card_id)
	print("starter_sword | score %d | reward_locked_at_pack1 %s" % [
		DeckBuildRulesScript.deck_score(STARTER_SWORD),
		"none" if locked_starter_cards.is_empty() else ", ".join(locked_starter_cards)
	])

func _pack_summary(packs: Array) -> String:
	var names: Array = []
	for pack_variant in packs:
		names.append(CardPoolDatabaseScript.pack_display_name(str(pack_variant)))
	return ",".join(names)

func _run_case(scenario: Dictionary, runs: int, scenario_index: int) -> String:
	var wins := 0
	var hp_total := 0
	var fail_layer_total := 0
	var fail_stage_total := 0
	for i in range(runs):
		var result: Dictionary = _run_three_layer(STARTER_SWORD, scenario, scenario_index, i)
		if bool(result.get("win", false)):
			wins += 1
			hp_total += int(result.get("hp", 0))
		else:
			fail_layer_total += int(result.get("fail_layer", 0))
			fail_stage_total += int(result.get("fail_stage", 0))
	var losses := runs - wins
	var avg_hp := 0.0 if wins <= 0 else float(hp_total) / float(wins)
	var avg_fail_layer := 0.0 if losses <= 0 else float(fail_layer_total) / float(losses)
	var avg_fail_stage := 0.0 if losses <= 0 else float(fail_stage_total) / float(losses)
	var meta_bonuses: Dictionary = scenario.get("meta_bonuses", {})
	return "%s | spent~%d | hp %d | atk+%d def+%d draw %d | score_limit %d | unlock_tier %d | win %d/%d (%.1f%%) | avg_win_hp %.1f | avg_fail_layer %.1f | avg_fail_stage %.1f" % [
		str(scenario.get("id", "")),
		int(scenario.get("spent_hint", 0)),
		int(scenario.get("max_hp", PLAYER_BASE_HP)),
		int(meta_bonuses.get("attack", 0)),
		int(meta_bonuses.get("defense", 0)),
		int(scenario.get("draw_per_turn", 1)),
		int(scenario.get("deck_score_limit", 20)),
		int(meta_bonuses.get("card_unlock_tier", 0)),
		wins,
		runs,
		100.0 * float(wins) / float(runs),
		avg_hp,
		avg_fail_layer,
		avg_fail_stage
	]

func _run_three_layer(base_deck: Array, scenario: Dictionary, scenario_index: int, run_index: int) -> Dictionary:
	var max_hp: int = int(scenario.get("max_hp", PLAYER_BASE_HP))
	var hp := max_hp
	var deck: Array = base_deck.duplicate()
	var reserve: Array = []
	for layer_index in range(3):
		hp = max_hp if layer_index > 0 else hp
		for stage_index in range(ROUTE.size()):
			var node: Dictionary = ROUTE[stage_index]
			var seed_value: int = BASE_SEED + scenario_index * 100000 + run_index * 1000 + layer_index * 100 + stage_index
			var result: Dictionary = _run_battle(deck, reserve, hp, max_hp, int(node.get("battle_number", 1)), str(node.get("type", "normal")), layer_index, scenario, seed_value)
			deck = result.get("deck", deck)
			reserve = result.get("reserve", reserve)
			hp = int(result.get("hp", 0))
			max_hp = int(result.get("max_hp", max_hp))
			if hp <= 0:
				return {
					"win": false,
					"fail_layer": layer_index + 1,
					"fail_stage": stage_index + 1
				}
			if stage_index == 3:
				hp = max_hp
	return {"win": true, "hp": hp}

func _run_battle(deck_ids: Array, reserve_ids: Array, hp: int, max_hp: int, battle_number: int, encounter_type: String, realm_index: int, scenario: Dictionary, seed_value: int) -> Dictionary:
	seed(seed_value)
	var battle = BattleManagerScript.new()
	battle.rng.seed = seed_value
	var meta_bonuses: Dictionary = (scenario.get("meta_bonuses", {}) as Dictionary).duplicate(true)
	battle.start_run_with_deck(JOB_ID, deck_ids, battle_number, encounter_type, false, {
		"current_hp": hp,
		"max_hp": max_hp,
		"draw_per_turn": int(scenario.get("draw_per_turn", 1)),
		"deck_score_limit": int(scenario.get("deck_score_limit", 20)),
		"reserve_ids": reserve_ids,
		"realm_index": realm_index,
		"realm_name": "progression_probe",
		"meta_bonuses": meta_bonuses
	})
	var guard := 0
	while guard < 30 and battle.phase != "reward" and battle.phase != "defeat":
		guard += 1
		_play_turn(battle)
	if battle.phase == "reward" and not battle.reward_options.is_empty():
		battle.choose_reward(_pick_reward(battle.reward_options, battle.master_deck_ids, int(scenario.get("deck_score_limit", 20))))
	return {
		"deck": battle.master_deck_ids.duplicate(),
		"reserve": battle.master_reserve_ids.duplicate(),
		"hp": battle.player.hp,
		"max_hp": battle.player.max_hp
	}

func _play_turn(battle) -> void:
	var loop := 0
	while battle.phase == "player" and loop < 50:
		loop += 1
		if _resolve_pending(battle):
			continue
		if _play_card(battle):
			continue
		if _act(battle):
			continue
		battle.end_player_turn()
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

func _play_card(battle) -> bool:
	var priority := [
		"heal_wound",
		"defense_setup",
		"break_defense_setup", "weaken_attack_setup",
		"clear_buff",
		"poison",
		"quick_draw"
	]
	for wanted in priority:
		var card := _find_hand_card(battle, wanted)
		if card.is_empty():
			continue
		if not _should_play_card(battle, card):
			continue
		var before_hand: int = battle.deck.hand.size()
		var uid := str(card.get("uid", ""))
		if str(card.get("target_scope", "")) == "ally_unit":
			battle.play_hand_card_on_unit_target(uid, str(battle.player.uid))
		elif str(card.get("after_use", "")) == "equipment":
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
	if id == "heal_wound":
		return battle.player.hp <= battle.player.max_hp - 8 and not battle.player_unit_action_used(battle.player)
	if id in ["break_defense_setup", "weaken_attack_setup"]:
		return not battle.player_unit_action_used(battle.player)
	if id == "defense_setup":
		return battle.player.get_status("next_damage_reduce") <= 0
	if id == "clear_buff":
		return battle.unit_has_positive_status(battle.enemy)
	if int(card.get("effect", {}).get("sword_cost", 0)) > battle.player.sword_momentum:
		return false
	var context: Dictionary = {"equipment_target_uid": str(battle.player.uid)}
	match str(card.get("target_scope", "")):
		"ally_unit":
			context["target_unit"] = battle.player
		"enemy_unit":
			context["target_unit"] = battle.enemy
	return battle.resolver.can_play_spell(battle, card, true, context)

func _act(battle) -> bool:
	for unit in battle.formation.living_units("player"):
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

func _pick_reward(options: Array, deck: Array, score_limit: int) -> String:
	var best_id := str(options[0])
	var best_score := -999
	var weights := {
		"heal_wound": 14,
		"break_defense_setup": 11,
		"weaken_attack_setup": 11,
		"defense_setup": 9,
		"poison": 8,
		"clear_buff": 6,
		"quick_draw": 5
	}
	for id_variant in options:
		var id := str(id_variant)
		if not DeckBuildRulesScript.can_add_card_to_deck(id, deck, score_limit):
			continue
		var score: int = int(weights.get(id, 0)) - DeckBuildRulesScript.card_score(id)
		if score > best_score:
			best_score = score
			best_id = id
	return best_id

func _find_hand_card(battle, card_id: String) -> Dictionary:
	for card_variant in battle.deck.hand:
		var card: Dictionary = card_variant
		if str(card.get("id", "")) == card_id:
			return card
	return {}

func _is_enemy_target_card(card: Dictionary) -> bool:
	if str(card.get("target_scope", "")) == "enemy_unit":
		return true
	var effect: Dictionary = card.get("effect", {})
	var kind := str(effect.get("kind", ""))
	return kind in ["direct_damage", "reduce_enemy_defense"] or (kind == "multi" and str(card.get("after_use", "")) != "equipment")
