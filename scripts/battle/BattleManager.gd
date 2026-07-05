extends RefCounted
class_name BattleManager

signal combat_event(payload: Dictionary)

const CardDatabaseScript = preload("res://scripts/data/CardDatabase.gd")
const JobDatabaseScript = preload("res://scripts/data/JobDatabase.gd")
const EnemyDatabaseScript = preload("res://scripts/data/EnemyDatabase.gd")
const PlayerStateScript = preload("res://scripts/battle/PlayerState.gd")
const EnemyStateScript = preload("res://scripts/battle/EnemyState.gd")
const DeckManagerScript = preload("res://scripts/battle/DeckManager.gd")
const CardResolverScript = preload("res://scripts/battle/CardResolver.gd")

var player: PlayerState
var enemy: EnemyState
var deck: DeckManager
var resolver: CardResolver
var job_id := ""
var battle_number := 1
var turn_number := 0
var phase := "player"
var master_deck_ids: Array = []
var reward_options: Array = []
var pending_choice: Dictionary = {}
var pending_equipment_replace: Dictionary = {}
var messages: Array = []
var rng := RandomNumberGenerator.new()
var current_event: Dictionary = {}
var chain_stack: Array = []
var response_loop_guard := 0
var auto_advance_after_reward := true
var current_encounter_type := "normal"

const MAX_CHAIN_ACTIONS := 32

func _init() -> void:
	player = PlayerStateScript.new()
	enemy = EnemyStateScript.new()
	deck = DeckManagerScript.new()
	resolver = CardResolverScript.new()
	rng.randomize()

func start_run(selected_job_id: String) -> void:
	job_id = selected_job_id
	auto_advance_after_reward = true
	current_encounter_type = "normal"
	var job := JobDatabaseScript.get_job(job_id)
	player.setup_from_job(job)
	master_deck_ids = player.start_deck_from_job(job)
	battle_number = 1
	messages.clear()
	start_battle()

func start_run_with_deck(selected_job_id: String, deck_ids: Array, selected_battle_number := 1, encounter_type := "normal", auto_advance := false) -> void:
	job_id = selected_job_id
	auto_advance_after_reward = auto_advance
	current_encounter_type = encounter_type
	var job := JobDatabaseScript.get_job(job_id)
	player.setup_from_job(job)
	master_deck_ids = deck_ids.duplicate()
	battle_number = max(1, int(selected_battle_number))
	messages.clear()
	start_battle()

func restart_run() -> void:
	if auto_advance_after_reward:
		start_run(job_id)
	else:
		start_run_with_deck(job_id, master_deck_ids, battle_number, current_encounter_type, false)

func start_battle() -> void:
	pending_choice.clear()
	pending_equipment_replace.clear()
	reward_options.clear()
	current_event.clear()
	chain_stack.clear()
	phase = "player"
	turn_number = 0
	player.reset_for_battle()
	enemy = EnemyStateScript.new()
	enemy.setup(_enemy_data_for_current_battle())
	deck.setup_battle(master_deck_ids)
	add_log("进入第 %d 场战斗：%s。" % [battle_number, enemy.name])
	deck.draw(5)
	_flush_deck_messages()
	start_player_turn()

func start_player_turn() -> void:
	if phase == "defeat":
		return
	phase = "player"
	turn_number += 1
	player.start_turn()
	add_log("玩家第 %d 回合开始。" % turn_number)
	resolver.apply_player_turn_start(self)
	deck.draw(1)
	_flush_deck_messages()
	enemy.current_intent = enemy.peek_action().get("intent", "")

func play_hand_card(uid: String) -> void:
	resolver.play_hand_card(self, uid)

func activate_spell_zone_card(uid: String) -> void:
	resolver.activate_spell_zone_card(self, uid)

func get_pending_options() -> Array:
	return resolver.get_pending_options(self)

func choose_pending(uid: String) -> void:
	resolver.choose_pending(self, uid)

func choose_equipment_replacement(uid: String) -> void:
	resolver.choose_equipment_replacement(self, uid)

func cancel_equipment_replacement() -> void:
	if pending_equipment_replace.is_empty():
		return
	pending_equipment_replace.clear()
	add_log("取消装备替换。")

func player_normal_attack() -> void:
	if phase != "player":
		add_log("现在不是玩家回合。")
		return
	if not pending_choice.is_empty():
		add_log("请先完成当前选择。")
		return
	if not pending_equipment_replace.is_empty():
		add_log("请先完成装备替换。")
		return
	if player.normal_attack_used:
		add_log("本回合已经进行过普通攻击。")
		return
	player.normal_attack_used = true
	emit_combat_event({"type": "attack_started", "source": "player", "target": "enemy"})
	var damage: int = max(0, player.current_attack() - enemy.current_defense())
	if damage <= 0:
		add_log("普通攻击未造成伤害。")
		emit_combat_event({"type": "attack_finished", "source": "player", "target": "enemy"})
		return
	enemy.hp -= damage
	add_log("普通攻击命中，造成 %d 点伤害。" % damage)
	emit_combat_event({"type": "damage_applied", "target": "enemy", "value": damage, "source": "normal_attack"})
	if player.job_id == "sword":
		var sword_gain := 1 + player.extra_sword_on_attack_hit
		player.add_sword(sword_gain)
		add_log("剑修普通攻击命中：获得 %d 点剑势。" % sword_gain)
		emit_combat_event({"type": "sword_power_changed", "target": "player", "value": sword_gain})
	emit_combat_event({"type": "attack_finished", "source": "player", "target": "enemy"})
	check_victory_or_defeat()

func end_player_turn() -> void:
	if phase != "player":
		return
	if not pending_choice.is_empty():
		add_log("请先完成当前选择。")
		return
	if not pending_equipment_replace.is_empty():
		add_log("请先完成装备替换。")
		return
	resolver.ready_defenses_after_player_turn(self)
	player.end_turn()
	phase = "enemy"
	_enemy_take_turn()
	if phase == "enemy":
		start_player_turn()

func _enemy_take_turn() -> void:
	enemy.clear_temporary_defense()
	var action := enemy.next_action()
	add_log("%s 行动：%s。" % [enemy.name, action.get("intent", "")])
	match action.get("kind", ""):
		"normal_attack":
			_enemy_attack(enemy.attack)
		"charge":
			add_log("%s 正在蓄力。" % enemy.name)
			_finish_enemy_action()
		"strong_attack":
			_enemy_attack(enemy.attack + int(action.get("attack_bonus", 0)))
		"defense_stance":
			enemy.temp_defense_delta = int(action.get("defense_delta", 0))
			add_log("%s 防御力 +%d，持续 1 回合。" % [enemy.name, enemy.temp_defense_delta])
			_finish_enemy_action()
		"weakness":
			enemy.temp_defense_delta = int(action.get("defense_delta", 0))
			add_log("%s 防御力 %d，持续 1 回合。" % [enemy.name, enemy.temp_defense_delta])
			_finish_enemy_action()
		"destroy_spell_zone":
			_enemy_destroy_spell_zone()
		"spell_attack":
			_enemy_spell_attack()

func _enemy_attack(power: int) -> void:
	add_log("敌人准备攻击。")
	emit_combat_event({"type": "enemy_intent_started", "intent": "攻击"})
	open_timing_window(create_event("enemy_attack_declared", "enemy", "player", power))

func _enemy_spell_attack() -> void:
	add_log("敌人准备施法。")
	emit_combat_event({"type": "enemy_intent_started", "intent": "施法"})
	open_timing_window(create_event("enemy_spell_declared", "enemy", "player", enemy.attack))

func _enemy_destroy_spell_zone() -> void:
	if player.spell_zone.is_empty():
		add_log("法防区为空，敌人没有破坏目标。")
		_finish_enemy_action()
		return
	var card: Dictionary = player.spell_zone[0]
	add_log("敌人准备破坏法防区的 %s。" % card.get("name", ""))
	emit_combat_event({"type": "enemy_intent_started", "intent": "破坏法防区"})
	open_timing_window(create_event("enemy_destroy_zone_card_declared", "enemy", card, 1))

func _apply_damage_to_player(base_damage: int, attack_trigger: bool, source_name: String) -> void:
	var damage := base_damage
	player.hp -= damage
	add_log("%s 造成 %d 点伤害。" % [source_name, damage])

func create_event(event_type: String, source, target, value := 0) -> Dictionary:
	return {
		"event_type": event_type,
		"source": source,
		"target": target,
		"value": int(value),
		"cancelled": false,
		"modifiers": [],
		"protected_targets": []
	}

func open_timing_window(event: Dictionary) -> void:
	current_event = event
	chain_stack.clear()
	response_loop_guard = 0
	add_log("进入时点：%s。" % get_event_description(event))
	var responses := get_available_responses(event)
	if responses.is_empty():
		add_log("没有可响应防御牌。")
		resolve_chain(event)
		return
	add_log("发现可响应防御牌：%s。" % _response_names(responses))
	phase = "response"

func get_available_responses(event: Dictionary) -> Array:
	return resolver.get_available_responses(self, event)

func get_available_responses_for_current_event() -> Array:
	if current_event.is_empty():
		return []
	return get_available_responses(current_event)

func add_card_to_chain(uid: String) -> void:
	if phase != "response":
		return
	response_loop_guard += 1
	if response_loop_guard > MAX_CHAIN_ACTIONS:
		add_log("响应循环超过安全上限，强制结算当前连锁。")
		resolve_chain(current_event)
		return
	var available := get_available_responses(current_event)
	var can_use := false
	for card in available:
		if str(card.get("uid", "")) == uid:
			can_use = true
			break
	if not can_use:
		add_log("该防御牌当前不能响应。")
		return
	var chain_card := resolver.mark_card_in_chain(self, uid)
	if chain_card.is_empty():
		return
	chain_stack.append(chain_card.duplicate(true))
	add_log("玩家发动：%s。" % chain_card.get("name", ""))
	emit_combat_event({"type": "defense_card_activated", "card": chain_card})
	if get_available_responses(current_event).is_empty():
		resolve_chain(current_event)

func skip_response() -> void:
	if phase != "response":
		return
	add_log("玩家跳过响应。")
	resolve_chain(current_event)

func resolve_chain(event: Dictionary) -> void:
	if not chain_stack.is_empty():
		add_log("连锁开始结算。")
		emit_combat_event({"type": "chain_started"})
	var order := 1
	while not chain_stack.is_empty():
		var card: Dictionary = chain_stack.pop_back()
		add_log("连锁结算 %d：%s。" % [order, card.get("name", "")])
		emit_combat_event({"type": "chain_card_resolved", "card": card, "order": order})
		resolver.resolve_chain_card(self, card, event)
		order += 1
	if order > 1:
		add_log("连锁结束。")
		emit_combat_event({"type": "chain_finished"})
	resolve_original_event(event)

func resolve_original_event(event: Dictionary) -> void:
	if bool(event.get("cancelled", false)):
		add_log("原始事件被打断，不再结算。")
		_finish_enemy_action()
		return
	match event.get("event_type", ""):
		"enemy_attack_declared":
			add_log("敌人攻击继续结算。")
			emit_combat_event({"type": "attack_started", "source": "enemy", "target": "player"})
			var damage: int = max(0, int(event.get("value", 0)) - player.current_defense())
			open_timing_window(create_event("player_damage_before", "enemy_attack", "player", damage))
		"enemy_spell_declared":
			add_log("敌人施法继续结算。")
			var damage: int = max(0, int(event.get("value", 0)) - player.current_defense())
			open_timing_window(create_event("player_damage_before", "enemy_spell", "player", damage))
		"enemy_destroy_zone_card_declared":
			_resolve_destroy_zone_event(event)
			_finish_enemy_action()
		"player_damage_before":
			var damage := int(event.get("value", 0))
			if damage >= player.hp and damage > 0:
				open_timing_window(create_event("player_lethal_damage_before", event.get("source", ""), "player", damage))
			else:
				_apply_final_damage(damage, str(event.get("source", "伤害")))
		"player_lethal_damage_before":
			_apply_final_damage(int(event.get("value", 0)), str(event.get("source", "致命伤害")))

func _resolve_destroy_zone_event(event: Dictionary) -> void:
	var target: Dictionary = event.get("target", {})
	var target_key := _target_key(target)
	if target_key in event.get("protected_targets", []):
		add_log("%s 被保护，本次破坏无效。" % target.get("name", "目标"))
		return
	_destroy_spell_zone_card(target)

func _destroy_spell_zone_card(card: Dictionary) -> void:
	for i in range(player.spell_zone.size()):
		if str(player.spell_zone[i].get("uid", "")) == str(card.get("uid", "")):
			player.spell_zone.remove_at(i)
			break
	deck.add_to_graveyard(card)
	add_log("%s 被破坏并进入墓地。" % card.get("name", "卡牌"))
	emit_combat_event({"type": "card_destroyed", "card": card})

func _apply_final_damage(damage: int, source_name: String) -> void:
	player.hp -= max(0, damage)
	add_log("%s 造成 %d 点伤害。" % [source_name, max(0, damage)])
	emit_combat_event({"type": "damage_applied", "target": "player", "value": max(0, damage), "source": source_name})
	if source_name == "enemy_attack":
		emit_combat_event({"type": "attack_finished", "source": "enemy", "target": "player"})
	_finish_enemy_action()

func _finish_enemy_action() -> void:
	current_event.clear()
	chain_stack.clear()
	if check_victory_or_defeat():
		return
	if phase != "reward" and phase != "defeat":
		phase = "enemy"
		start_player_turn()

func get_event_description(event: Dictionary) -> String:
	match event.get("event_type", ""):
		"enemy_attack_declared":
			return "敌人攻击前"
		"enemy_spell_declared":
			return "敌人施法前"
		"enemy_destroy_zone_card_declared":
			return "敌人破坏法防区前"
		"player_damage_before":
			return "玩家受到伤害前"
		"player_lethal_damage_before":
			return "玩家受到致命伤害前"
	return str(event.get("event_type", "未知时点"))

func _response_names(responses: Array) -> String:
	var names: Array = []
	for card in responses:
		names.append(card.get("name", "卡牌"))
	return "、".join(names)

func _target_key(target) -> String:
	if target is Dictionary:
		return str(target.get("uid", target.get("id", target.get("name", ""))))
	return str(target)

func choose_reward(card_id: String) -> void:
	if phase != "reward":
		return
	if not reward_options.has(card_id):
		return
	master_deck_ids.append(card_id)
	if not auto_advance_after_reward:
		phase = "map_complete"
		return
	add_log("选择奖励：%s 加入卡组。" % card_id)
	battle_number += 1
	if battle_number > 5:
		battle_number = 1
		add_log("第 5 场胜利后回到第 1 场循环。")
	start_battle()

func _enemy_data_for_current_battle() -> Dictionary:
	var data := EnemyDatabaseScript.get_enemy_for_battle(battle_number)
	match current_encounter_type:
		"elite":
			data["name"] = "精英·%s" % data.get("name", "")
			data["max_hp"] = int(data.get("max_hp", 0)) + 14 + battle_number * 2
			data["attack"] = int(data.get("attack", 0)) + 2
			data["defense"] = int(data.get("defense", 0)) + 1
		"boss":
			data["name"] = "首领·%s" % data.get("name", "")
			data["max_hp"] = int(data.get("max_hp", 0)) + 34 + battle_number * 3
			data["attack"] = int(data.get("attack", 0)) + 4
			data["defense"] = int(data.get("defense", 0)) + 2
	return data

func check_victory_or_defeat() -> bool:
	if enemy.hp <= 0 and phase != "reward":
		enemy.hp = 0
		player.sword_momentum = 0
		phase = "reward"
		reward_options = _generate_rewards()
		add_log("战斗胜利。请选择 1 张奖励卡。")
		return true
	if player.hp <= 0:
		player.hp = 0
		phase = "defeat"
		add_log("玩家生命降为 0，战斗失败。")
		return true
	return false

func _generate_rewards() -> Array:
	var pool := CardDatabaseScript.reward_pool_for_job(job_id)
	var rewards: Array = []
	var attempts := 0
	while rewards.size() < 3 and attempts < 100:
		attempts += 1
		var card_id := str(pool[rng.randi_range(0, pool.size() - 1)])
		if not rewards.has(card_id):
			rewards.append(card_id)
	return rewards

func _flush_deck_messages() -> void:
	for message in deck.take_messages():
		add_log(message)

func add_log(message: String) -> void:
	messages.append(message)
	while messages.size() > 12:
		messages.pop_front()

func emit_combat_event(payload: Dictionary) -> void:
	combat_event.emit(payload)
