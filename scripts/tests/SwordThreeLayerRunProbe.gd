extends SceneTree

const BattleManagerScript = preload("res://scripts/battle/BattleManager.gd")
const CardDatabaseScript = preload("res://scripts/data/CardDatabase.gd")

const ROUTE := [
	{"battle_number": 1, "type": "normal"},
	{"battle_number": 2, "type": "normal"},
	{"battle_number": 3, "type": "elite"},
	{"battle_number": 5, "type": "normal"},
	{"battle_number": 7, "type": "boss"}
]

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
	]
}

func _init() -> void:
	for deck_name in DECKS.keys():
		print(_run_case(str(deck_name), DECKS[deck_name], 80))
	quit(0)

func _run_case(deck_name: String, deck_ids: Array, runs: int) -> String:
	var wins := 0
	var hp_total := 0
	var fail_layer_total := 0
	var fail_stage_total := 0
	for i in range(runs):
		var result: Dictionary = _run_three_layer(deck_ids)
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
	return "%s | three_layer | score %d | win %d/%d (%.1f%%) | avg_win_hp %.1f | avg_fail_layer %.1f | avg_fail_stage %.1f" % [
		deck_name,
		CardDatabaseScript.deck_score(deck_ids),
		wins,
		runs,
		100.0 * float(wins) / float(runs),
		avg_hp,
		avg_fail_layer,
		avg_fail_stage
	]

func _run_three_layer(base_deck: Array) -> Dictionary:
	var hp := 35
	var max_hp := 35
	var deck: Array = base_deck.duplicate()
	var reserve: Array = []
	for layer_index in range(3):
		hp = max_hp if layer_index > 0 else hp
		for stage_index in range(ROUTE.size()):
			var node: Dictionary = ROUTE[stage_index]
			var result: Dictionary = _run_battle(deck, reserve, hp, max_hp, int(node.get("battle_number", 1)), str(node.get("type", "normal")), layer_index)
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

func _run_battle(deck_ids: Array, reserve_ids: Array, hp: int, max_hp: int, battle_number: int, encounter_type: String, realm_index: int) -> Dictionary:
	var battle = BattleManagerScript.new()
	battle.start_run_with_deck("sword", deck_ids, battle_number, encounter_type, false, {
		"current_hp": hp,
		"max_hp": max_hp,
		"draw_per_turn": 1,
		"deck_score_limit": 20,
		"reserve_ids": reserve_ids,
		"realm_index": realm_index,
		"realm_name": "三层压力测试",
		"meta_bonuses": {}
	})
	var guard := 0
	while guard < 30 and battle.phase != "reward" and battle.phase != "defeat":
		guard += 1
		_play_turn(battle)
	if battle.phase == "reward" and not battle.reward_options.is_empty():
		battle.choose_reward(_pick_reward(battle.reward_options))
	return {
		"deck": battle.master_deck_ids.duplicate(),
		"reserve": battle.master_reserve_ids.duplicate(),
		"hp": battle.player.hp,
		"max_hp": battle.player.max_hp
	}

func _pick_reward(reward_options: Array) -> String:
	var priority := ["回春符", "小还丹", "护身符", "破甲符", "缚身符", "起剑诀", "引剑入体", "疾剑诀", "火球符", "金刃符", "青锋剑"]
	for wanted in priority:
		if reward_options.has(wanted):
			return wanted
	return str(reward_options[0])

func _play_turn(battle) -> void:
	var loop := 0
	while battle.phase == "player" and loop < 40:
		loop += 1
		if _play_card(battle):
			continue
		if _act(battle):
			continue
		battle.end_player_turn()
	while battle.phase == "response":
		var responses: Array = battle.get_available_responses_for_current_event()
		if responses.is_empty():
			battle.skip_response()
		else:
			battle.add_card_to_chain(str(responses[0].get("uid", "")))
	while battle.phase == "target_select":
		battle.confirm_target_selection(str(battle.enemy.uid))

func _play_card(battle) -> bool:
	for card_id in ["青锋剑", "护身符", "回春符", "小还丹", "起剑诀", "引剑入体", "疾剑诀", "破甲符", "缚身符", "火球符", "金刃符"]:
		for card_variant in battle.deck.hand:
			var card: Dictionary = card_variant
			if str(card.get("id", "")) != card_id:
				continue
			if card_id in ["回春符", "小还丹"] and battle.player.hp > battle.player.max_hp - 4:
				continue
			if int(card.get("effect", {}).get("sword_cost", 0)) > battle.player.sword_momentum:
				continue
			if not battle.resolver.can_play_spell(battle, card, true, {"equipment_target_uid": str(battle.player.uid)}):
				continue
			var uid := str(card.get("uid", ""))
			if str(card.get("after_use", "")) == "equipment":
				battle.play_hand_card_on_unit_target(uid, str(battle.player.uid))
			elif str(card.get("effect", {}).get("kind", "")) == "direct_damage":
				battle.play_hand_card_on_enemy_target(uid, str(battle.enemy.uid))
			else:
				battle.play_hand_card(uid)
			return true
	return false

func _act(battle) -> bool:
	for unit in battle.formation.living_units("player"):
		if unit == null or battle.player_unit_action_used(unit):
			continue
		if unit.current_attack() > battle.enemy.current_defense():
			battle.player_unit_attack(str(unit.uid))
			if battle.phase == "target_select":
				battle.confirm_target_selection(str(battle.enemy.uid))
		else:
			battle.player_unit_defend(str(unit.uid))
		return true
	return false
