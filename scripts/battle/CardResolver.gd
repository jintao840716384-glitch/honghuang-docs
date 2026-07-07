extends RefCounted
class_name CardResolver

const CardDatabaseScript = preload("res://scripts/data/CardDatabase.gd")

func apply_player_turn_start(battle) -> void:
	_process_spell_zone_turn_start(battle)

	for card in battle.player.spell_zone:
		var effect: Dictionary = card.get("effect", {})
		if effect.get("kind", "") == "persistent_sword_per_turn":
			var amount := int(effect.get("value", 0))
			battle.player.add_sword(amount)
			battle.add_log("%s：获得 %d 点剑势。" % [card.get("name", ""), amount])

	for unit in battle.formation.living_units("player"):
		_apply_unit_turn_start_equipment(battle, unit)

func _process_spell_zone_turn_start(battle) -> void:
	for card_variant in battle.player.spell_zone.duplicate():
		var card: Dictionary = card_variant
		var effect: Dictionary = card.get("effect", {})
		match str(effect.get("kind", "")):
			"zone_delayed_effect", "zone_attach_search":
				var countdown: int = int(card.get("zone_countdown", effect.get("countdown", 0)))
				if countdown > 0:
					countdown -= 1
					card["zone_countdown"] = countdown
					battle.add_log("%s：倒计时 %d。" % [card.get("name", "放置牌"), countdown])
				if countdown <= 0:
					_resolve_zone_card(battle, card)

func _resolve_zone_card(battle, card: Dictionary) -> void:
	var effect: Dictionary = card.get("effect", {})
	match str(effect.get("kind", "")):
		"zone_attach_search":
			var attached_cards: Array = card.get("attached_cards", [])
			for attached_card_variant in attached_cards:
				var attached_card: Dictionary = attached_card_variant
				battle.deck.add_to_hand(attached_card)
				battle.add_log("%s：%s 加入手牌。" % [card.get("name", "放置牌"), attached_card.get("name", "卡牌")])
			card["attached_cards"] = []
		"zone_delayed_effect":
			var delayed_effect: Dictionary = effect.get("delayed_effect", {})
			var delayed_card: Dictionary = card.duplicate(true)
			delayed_card["effect"] = delayed_effect
			resolve_spell_effect(battle, delayed_card, 1.0, {"source_zone_card": card})
	move_spell_zone_card_to_destination(battle, card)

func play_hand_card(battle, uid: String) -> void:
	if battle.phase != "player":
		battle.add_log("现在不是玩家回合。")
		return
	if not battle.pending_choice.is_empty():
		battle.add_log("请先完成当前选择。")
		return
	if not battle.pending_equipment_replace.is_empty():
		battle.add_log("请先完成装备替换。")
		return
	var card: Dictionary = battle.deck.find_hand_card(uid)
	if card.is_empty():
		battle.add_log("手牌中找不到这张牌。")
		return
	if card.get("type", "") == CardDatabaseScript.TYPE_DEFENSE:
		cover_defense_card(battle, uid)
	else:
		play_spell_card(battle, uid)

func cover_defense_card(battle, uid: String) -> void:
	if battle.player.spell_zone.size() >= 5:
		battle.add_log("法防区已满，不能继续盖伏防御牌。")
		return
	var card: Dictionary = battle.deck.remove_from_hand(uid)
	if card.is_empty():
		return
	card["set_turn"] = battle.turn_number
	card["set_turn_owner"] = "player"
	card["cover_turn"] = battle.turn_number
	card["face_down"] = true
	card["ready"] = false
	card["sealed"] = false
	card["already_in_chain"] = false
	battle.player.spell_zone.append(card)
	battle.add_log("盖伏防御牌：%s。" % card.get("name", ""))
	battle.emit_combat_event({"type": "defense_card_set", "card": card})

func play_spell_card(battle, uid: String, skip_target_selection := false, context := {}) -> void:
	var card: Dictionary = battle.deck.find_hand_card(uid)
	if card.is_empty():
		return
	var play_context: Dictionary = context.duplicate(true)
	if str(card.get("after_use", "")) == "equipment":
		var equipment_target = _equipment_target_unit(battle, play_context)
		if equipment_target == null:
			battle.add_log("没有可装备的目标。")
			return
		play_context["equipment_target_uid"] = str(equipment_target.uid)
		play_context["target_unit"] = equipment_target
	if not can_play_spell(battle, card, true, play_context):
		return
	if str(card.get("after_use", "")) == "equipment" and _equipment_target_full(battle, play_context):
		_start_equipment_replacement(battle, uid, card, play_context)
		return
	var effect: Dictionary = card.get("effect", {})
	match effect.get("kind", ""):
		"recover_graveyard_tag":
			_start_pick_from_graveyard(battle, uid, str(effect.get("tag", "")))
		"discard_search_deck_tag":
			_start_discard_for_search(battle, uid, str(effect.get("tag", "")))
		"search_deck_tag":
			_start_search_deck_tag(battle, uid, str(effect.get("tag", "")))
		"search_deck_filter_to_hand":
			_start_search_deck_filter_to_hand(battle, uid, effect)
		"discard_draw":
			_start_discard_draw(battle, uid, effect)
		"draw_then_discard":
			_start_draw_then_discard(battle, uid, effect)
		"zone_attach_search":
			_start_zone_attach_search(battle, uid, effect)
		_:
			if not skip_target_selection and _needs_enemy_target(effect) and battle.enemy_target_count() > 1:
				battle.begin_enemy_target_selection({
					"type": "hand_card",
					"uid": uid
				}, "选择 %s 的目标" % card.get("name", "卡牌"))
				return
			card = battle.deck.remove_from_hand(uid)
			battle.emit_combat_event({"type": "card_played", "card": card})
			resolve_and_finish_spell(battle, card, play_context)

func can_play_spell(battle, card: Dictionary, allow_equipment_replace := false, context := {}) -> bool:
	var effect: Dictionary = card.get("effect", {})
	var sword_cost := int(effect.get("sword_cost", 0))
	if sword_cost > battle.player.sword_momentum:
		battle.add_log("%s 需要 %d 点剑势。" % [card.get("name", ""), sword_cost])
		return false
	var after_use := str(card.get("after_use", "graveyard"))
	if after_use == "spell_zone" and battle.player.spell_zone.size() >= 5:
		battle.add_log("法防区已满，不能使用 %s。" % card.get("name", ""))
		return false
	if after_use == "equipment" and _equipment_target_full(battle, context):
		if allow_equipment_replace:
			return true
		battle.add_log("装备区已满，不能使用 %s。" % card.get("name", ""))
		return false
	if effect.get("kind", "") == "discard_search_deck_tag" and battle.deck.hand.size() <= 1:
		battle.add_log("%s 需要弃置 1 张其他手牌。" % card.get("name", ""))
		return false
	if effect.get("kind", "") == "discard_draw" and battle.deck.hand.size() <= 1:
		battle.add_log("%s 需要弃置 1 张其他手牌。" % card.get("name", ""))
		return false
	if effect.get("kind", "") == "pay_life_draw":
		var life_cost := int(effect.get("life_cost", 0))
		if battle.player.hp <= life_cost:
			battle.add_log("%s 需要支付 %d 点生命。" % [card.get("name", ""), life_cost])
			return false
	return true

func _start_equipment_replacement(battle, uid: String, card: Dictionary, context := {}) -> void:
	var target_unit = _equipment_target_unit(battle, context)
	battle.pending_equipment_replace = {
		"source_uid": uid,
		"source_card": card.duplicate(true),
		"target_uid": "" if target_unit == null else str(target_unit.uid)
	}
	battle.add_log("装备区已满，请选择 1 张装备替换。")
	battle.emit_combat_event({"type": "equipment_replace_started", "card": card})

func choose_equipment_replacement(battle, equipment_uid: String) -> void:
	if battle.pending_equipment_replace.is_empty():
		return
	var source_uid := str(battle.pending_equipment_replace.get("source_uid", ""))
	var target_uid := str(battle.pending_equipment_replace.get("target_uid", ""))
	var target_unit = battle.formation.unit_by_uid(target_uid)
	if target_unit == null:
		target_unit = battle.player
	var source_card: Dictionary = battle.deck.remove_from_hand(source_uid)
	if source_card.is_empty():
		battle.pending_equipment_replace.clear()
		battle.add_log("找不到要装备的卡牌，取消替换。")
		return
	var old_card := _remove_equipment_by_uid(target_unit, equipment_uid)
	if old_card.is_empty():
		battle.deck.add_to_hand(source_card)
		battle.pending_equipment_replace.clear()
		battle.add_log("没有找到要替换的装备。")
		return
	_remove_equipment_effect(target_unit, old_card)
	battle.deck.add_to_graveyard(old_card)
	battle.pending_equipment_replace.clear()
	battle.add_log("替换装备：%s 进入墓地，装备 %s。" % [old_card.get("name", "装备"), source_card.get("name", "装备")])
	battle.emit_combat_event({"type": "equipment_replaced", "old_card": old_card, "new_card": source_card})
	battle.emit_combat_event({"type": "card_moved_to_graveyard", "card": old_card})
	battle.emit_combat_event({"type": "card_played", "card": source_card})
	resolve_and_finish_spell(battle, source_card, {"equipment_target_uid": target_uid, "target_unit": target_unit})

func _remove_equipment_by_uid(unit, equipment_uid: String) -> Dictionary:
	if unit == null:
		return {}
	for i in range(unit.equipment.size()):
		var card: Dictionary = unit.equipment[i]
		if str(card.get("uid", "")) == equipment_uid:
			unit.equipment.remove_at(i)
			return card
	return {}

func _remove_equipment_effect(unit, card: Dictionary) -> void:
	if unit == null:
		return
	_remove_equipment_effect_recursive(unit, card.get("effect", {}))

func _remove_equipment_effect_recursive(unit, effect: Dictionary) -> void:
	match str(effect.get("kind", "")):
		"equipment_attack_bonus":
			unit.equipment_attack_bonus -= int(effect.get("value", 0))
		"equipment_defense_bonus":
			unit.equipment_defense_bonus -= int(effect.get("value", 0))
		"multi":
			for sub_effect_variant in effect.get("effects", []):
				var sub_effect: Dictionary = sub_effect_variant
				_remove_equipment_effect_recursive(unit, sub_effect)

func _start_pick_from_graveyard(battle, uid: String, tag: String) -> void:
	var source: Dictionary = battle.deck.remove_from_hand(uid)
	var options: Array = battle.deck.cards_in_graveyard_with_tag(tag)
	if options.is_empty():
		battle.add_log("墓地没有带“%s”标签的卡牌，%s 没有回收目标。" % [tag, source.get("name", "")])
		finish_used_spell(battle, source, false)
		battle.check_victory_or_defeat()
		return
	battle.pending_choice = {
		"type": "grave_tag_to_hand",
		"tag": tag,
		"source_card": source,
		"prompt": "选择 1 张墓地中的“%s”牌加入手牌" % tag
	}
	battle.add_log("%s：请选择墓地中的 1 张“%s”牌。" % [source.get("name", ""), tag])

func _start_discard_for_search(battle, uid: String, tag: String) -> void:
	var source: Dictionary = battle.deck.remove_from_hand(uid)
	battle.pending_choice = {
		"type": "discard_for_search",
		"tag": tag,
		"source_card": source,
		"prompt": "选择 1 张手牌弃置"
	}
	battle.add_log("%s：请选择 1 张手牌弃置。" % source.get("name", ""))

func _start_search_deck_tag(battle, uid: String, tag: String) -> void:
	var source: Dictionary = battle.deck.remove_from_hand(uid)
	var deck_options: Array = battle.deck.cards_in_deck_with_tag(tag)
	if deck_options.is_empty():
		battle.add_log("卡组没有带“%s”标签的卡牌，%s 没有检索目标。" % [tag, source.get("name", "")])
		finish_used_spell(battle, source, false)
		battle.check_victory_or_defeat()
		return
	battle.pending_choice = {
		"type": "deck_search_tag_to_hand",
		"tag": tag,
		"source_card": source,
		"prompt": "选择 1 张卡组中的“%s”牌加入手牌" % tag
	}
	battle.add_log("%s：请选择卡组中的 1 张“%s”牌。" % [source.get("name", ""), tag])

func _start_search_deck_filter_to_hand(battle, uid: String, effect: Dictionary) -> void:
	var source: Dictionary = battle.deck.remove_from_hand(uid)
	var deck_options: Array = _cards_in_deck_matching_filter(battle, effect.get("filter", {}))
	if deck_options.is_empty():
		battle.add_log("卡组没有符合条件的卡牌，%s 没有检索目标。" % source.get("name", ""))
		finish_used_spell(battle, source, false)
		battle.check_victory_or_defeat()
		return
	battle.pending_choice = {
		"type": "deck_filter_to_hand",
		"filter": effect.get("filter", {}).duplicate(true),
		"source_card": source,
		"prompt": str(effect.get("prompt", "选择 1 张卡组中的牌加入手牌"))
	}
	battle.add_log("%s：%s。" % [source.get("name", ""), battle.pending_choice.get("prompt", "")])

func _start_discard_draw(battle, uid: String, effect: Dictionary) -> void:
	var source: Dictionary = battle.deck.remove_from_hand(uid)
	battle.pending_choice = {
		"type": "discard_then_draw",
		"draw": int(effect.get("draw", 1)),
		"source_card": source,
		"prompt": "选择 1 张手牌弃置"
	}
	battle.add_log("%s：请选择 1 张手牌弃置。" % source.get("name", ""))

func _start_draw_then_discard(battle, uid: String, effect: Dictionary) -> void:
	var source: Dictionary = battle.deck.remove_from_hand(uid)
	var draw_count: int = int(effect.get("draw", 1))
	battle.call("_draw_player_cards", draw_count, "card")
	battle.call("_flush_deck_messages")
	if battle.deck.hand.is_empty():
		finish_used_spell(battle, source, false)
		battle.check_victory_or_defeat()
		return
	battle.pending_choice = {
		"type": "discard_only",
		"source_card": source,
		"prompt": "选择 1 张手牌弃置"
	}
	battle.add_log("%s：抽 %d 张牌，请弃置 1 张手牌。" % [source.get("name", ""), draw_count])

func _start_zone_attach_search(battle, uid: String, effect: Dictionary) -> void:
	var source: Dictionary = battle.deck.remove_from_hand(uid)
	var deck_options: Array = _cards_in_deck_matching_filter(battle, effect.get("filter", {}))
	if deck_options.is_empty():
		battle.add_log("卡组没有符合条件的卡牌，%s 没有封藏目标。" % source.get("name", ""))
		finish_used_spell(battle, source, false)
		battle.check_victory_or_defeat()
		return
	battle.pending_choice = {
		"type": "deck_attach_to_zone",
		"filter": effect.get("filter", {}).duplicate(true),
		"source_card": source,
		"prompt": str(effect.get("prompt", "选择 1 张卡组中的牌压在此牌下"))
	}
	battle.add_log("%s：%s。" % [source.get("name", ""), battle.pending_choice.get("prompt", "")])

func get_pending_options(battle) -> Array:
	if battle.pending_choice.is_empty():
		return []
	var tag := str(battle.pending_choice.get("tag", ""))
	match battle.pending_choice.get("type", ""):
		"grave_tag_to_hand":
			return battle.deck.cards_in_graveyard_with_tag(tag)
		"discard_for_search":
			return battle.deck.hand
		"deck_search_tag_to_hand":
			return battle.deck.cards_in_deck_with_tag(tag)
		"deck_filter_to_hand", "deck_attach_to_zone":
			return _cards_in_deck_matching_filter(battle, battle.pending_choice.get("filter", {}))
		"discard_then_draw", "discard_only":
			return battle.deck.hand
	return []

func choose_pending(battle, uid: String) -> void:
	if battle.pending_choice.is_empty():
		return
	var source: Dictionary = battle.pending_choice.get("source_card", {})
	var tag := str(battle.pending_choice.get("tag", ""))
	match battle.pending_choice.get("type", ""):
		"grave_tag_to_hand":
			var picked: Dictionary = battle.deck.remove_from_graveyard(uid)
			if not picked.is_empty():
				battle.deck.add_to_hand(picked)
				battle.add_log("%s：%s 加入手牌。" % [source.get("name", ""), picked.get("name", "")])
			finish_used_spell(battle, source, false)
			battle.pending_choice.clear()
			battle.check_victory_or_defeat()
		"discard_for_search":
			var discarded: Dictionary = battle.deck.discard_from_hand(uid)
			if discarded.is_empty():
				battle.add_log("没有弃置卡牌。")
				return
			battle.add_log("%s：弃置 %s。" % [source.get("name", ""), discarded.get("name", "")])
			var deck_options: Array = battle.deck.cards_in_deck_with_tag(tag)
			if deck_options.is_empty():
				battle.add_log("卡组没有带“%s”标签的卡牌。" % tag)
				finish_used_spell(battle, source, false)
				battle.pending_choice.clear()
				battle.check_victory_or_defeat()
				return
			battle.pending_choice = {
				"type": "deck_search_tag_to_hand",
				"tag": tag,
				"source_card": source,
				"prompt": "选择 1 张卡组中的“%s”牌加入手牌" % tag
			}
		"deck_search_tag_to_hand":
			var picked_from_deck: Dictionary = battle.deck.remove_from_deck(uid)
			if not picked_from_deck.is_empty():
				battle.deck.add_to_hand(picked_from_deck)
				battle.add_log("%s：%s 加入手牌。" % [source.get("name", ""), picked_from_deck.get("name", "")])
			finish_used_spell(battle, source, false)
			battle.pending_choice.clear()
			battle.check_victory_or_defeat()
		"deck_filter_to_hand":
			var picked_filter_card: Dictionary = battle.deck.remove_from_deck(uid)
			if not picked_filter_card.is_empty():
				battle.deck.add_to_hand(picked_filter_card)
				battle.add_log("%s：%s 加入手牌。" % [source.get("name", ""), picked_filter_card.get("name", "")])
			finish_used_spell(battle, source, false)
			battle.pending_choice.clear()
			battle.check_victory_or_defeat()
		"deck_attach_to_zone":
			var attached_card: Dictionary = battle.deck.remove_from_deck(uid)
			if not attached_card.is_empty():
				var attached_cards: Array = source.get("attached_cards", [])
				attached_cards.append(attached_card)
				source["attached_cards"] = attached_cards
				battle.add_log("%s：%s 压在此牌下。" % [source.get("name", ""), attached_card.get("name", "")])
			finish_used_spell(battle, source, false)
			battle.pending_choice.clear()
			battle.check_victory_or_defeat()
		"discard_then_draw":
			var discarded_for_draw: Dictionary = battle.deck.discard_from_hand(uid)
			if discarded_for_draw.is_empty():
				battle.add_log("没有弃置卡牌。")
				return
			battle.add_log("%s：弃置 %s。" % [source.get("name", ""), discarded_for_draw.get("name", "")])
			var draw_count: int = int(battle.pending_choice.get("draw", 1))
			battle.call("_draw_player_cards", draw_count, "card")
			battle.call("_flush_deck_messages")
			finish_used_spell(battle, source, false)
			battle.pending_choice.clear()
			battle.check_victory_or_defeat()
		"discard_only":
			var discarded_only: Dictionary = battle.deck.discard_from_hand(uid)
			if discarded_only.is_empty():
				battle.add_log("没有弃置卡牌。")
				return
			battle.add_log("%s：弃置 %s。" % [source.get("name", ""), discarded_only.get("name", "")])
			finish_used_spell(battle, source, false)
			battle.pending_choice.clear()
			battle.check_victory_or_defeat()

func resolve_and_finish_spell(battle, card: Dictionary, context := {}) -> void:
	var effect: Dictionary = card.get("effect", {})
	var sword_cost := int(effect.get("sword_cost", 0))
	if sword_cost > 0:
		battle.player.add_sword(-sword_cost)
		battle.add_log("%s：消耗 %d 点剑势。" % [card.get("name", ""), sword_cost])

	var tags: Array = card.get("tags", [])
	var is_talisman: bool = "符" in tags
	var copy_talisman: bool = battle.player.copy_next_talisman and is_talisman
	if copy_talisman:
		battle.player.copy_next_talisman = false
		battle.add_log("复符诀生效：%s 将发动 2 次。" % card.get("name", ""))

	resolve_spell_effect(battle, card, 1.0, context)
	if copy_talisman:
		resolve_spell_effect(battle, card, float(effect.get("second_multiplier", 0.5)), context)
		battle.add_log("%s 的第二次效果按 50%% 结算。" % card.get("name", ""))

	finish_used_spell(battle, card, is_talisman, context)
	battle.check_victory_or_defeat()

func resolve_spell_effect(battle, card: Dictionary, multiplier := 1.0, context := {}) -> void:
	var effect: Dictionary = card.get("effect", {})
	match effect.get("kind", ""):
		"multi":
			for sub_effect_variant in effect.get("effects", []):
				var sub_effect: Dictionary = sub_effect_variant
				var sub_card: Dictionary = card.duplicate(true)
				sub_card["effect"] = sub_effect
				resolve_spell_effect(battle, sub_card, multiplier, context)
		"gain_sword_power":
			var amount := _scaled(int(effect.get("value", 0)), multiplier)
			battle.add_unit_resource(battle.player, "sword_momentum", amount, str(card.get("name", "")))
			battle.add_log("%s：获得 %d 点剑势。" % [card.get("name", ""), amount])
		"attack_boost":
			var attack_bonus := _scaled(int(effect.get("attack_bonus", 0)), multiplier)
			var sword_on_hit := _scaled(int(effect.get("extra_sword_on_hit", 0)), multiplier)
			battle.player.attack_bonus_this_turn += attack_bonus
			battle.player.extra_sword_on_attack_hit += sword_on_hit
			battle.add_log("%s：本回合普通攻击攻击力 +%d。" % [card.get("name", ""), attack_bonus])
		"modify_player_attack":
			var amount := _scaled(int(effect.get("value", 0)), multiplier)
			battle.modify_unit_stat(battle.player, "attack", amount, false, str(card.get("name", "")))
		"increase_player_attack_actions":
			var amount := _scaled(int(effect.get("value", 0)), multiplier)
			battle.player.attack_actions_bonus += amount
			battle.add_log("%s：本场战斗玩家每回合基础攻击次数 +%d。" % [card.get("name", ""), amount])
		"extra_player_attack_this_turn":
			var amount := _scaled(int(effect.get("value", 0)), multiplier)
			battle.player.extra_attack_actions_this_turn += amount
			battle.add_log("%s：本回合玩家可额外攻击 %d 次。" % [card.get("name", ""), amount])
		"next_attack_all_enemies":
			battle.player.next_attack_all_enemies = true
			battle.add_log("%s：玩家下一次基础攻击将攻击敌方全体。" % card.get("name", ""))
		"next_attack_random_multi":
			battle.player.next_attack_random_min = max(1, int(effect.get("min_hits", 1)))
			battle.player.next_attack_random_max = max(battle.player.next_attack_random_min, int(effect.get("max_hits", battle.player.next_attack_random_min)))
			battle.add_log("%s：玩家下一次基础攻击将随机攻击 %d-%d 次。" % [card.get("name", ""), battle.player.next_attack_random_min, battle.player.next_attack_random_max])
		"next_attack_damage_multiplier":
			var next_multiplier: float = max(1.0, float(effect.get("multiplier", 1.0)) * multiplier)
			battle.player.next_attack_damage_multiplier = max(battle.player.next_attack_damage_multiplier, next_multiplier)
			battle.add_log("%s：玩家下一次基础攻击最终伤害 x%.1f。" % [card.get("name", ""), next_multiplier])
		"direct_damage":
			var damage: int = _scaled(int(effect.get("value", 0)), multiplier)
			var ignore_defense: bool = bool(effect.get("ignore_defense", false))
			var target_units: Array = battle.resolve_target_units("enemy", battle.player, context)
			for target_unit in target_units:
				if target_unit == null:
					continue
				var final_damage: int = damage if ignore_defense else max(0, damage - target_unit.current_defense())
				battle.apply_damage_to_unit(target_unit, final_damage, str(card.get("name", "")))
				if ignore_defense:
					battle.add_log("%s：对 %s 造成 %d 点无视防御伤害。" % [card.get("name", ""), target_unit.name, final_damage])
				else:
					battle.add_log("%s：对 %s 造成 %d 点伤害。" % [card.get("name", ""), target_unit.name, final_damage])
		"heal":
			var amount := _scaled(int(effect.get("value", 0)), multiplier)
			var before: int = battle.player.hp
			battle.effect_resolver.apply_steps(battle, battle.player, [{
				"kind": "heal",
				"target": "player",
				"value": amount,
				"source": card.get("name", "")
			}])
			battle.add_log("%s：回复 %d 点生命。" % [card.get("name", ""), battle.player.hp - before])
		"draw_cards":
			var amount := _scaled(int(effect.get("value", 0)), multiplier)
			battle.call("_draw_player_cards", amount, "card")
			battle.call("_flush_deck_messages")
			battle.add_log("%s：抽 %d 张牌。" % [card.get("name", ""), amount])
		"pay_life_draw":
			var life_cost := int(effect.get("life_cost", 0))
			var draw_count := _scaled(int(effect.get("draw", 0)), multiplier)
			battle.apply_damage_to_unit(battle.player, life_cost, str(card.get("name", "")))
			battle.call("_draw_player_cards", draw_count, "card")
			battle.call("_flush_deck_messages")
			battle.add_log("%s：失去 %d 点生命，抽 %d 张牌。" % [card.get("name", ""), life_cost, draw_count])
		"reduce_enemy_defense":
			var amount := _scaled(int(effect.get("value", 0)), multiplier)
			battle.effect_resolver.apply_steps(battle, battle.player, [{
				"kind": "modify_stat",
				"target": "enemy",
				"stat": "defense",
				"value": -amount,
				"source": card.get("name", "")
			}])
			battle.add_log("%s：敌人防御力 -%d。" % [card.get("name", ""), amount])
		"add_status":
			var amount := _scaled(int(effect.get("value", 0)), multiplier)
			battle.effect_resolver.apply_steps(battle, battle.player, [{
				"kind": "add_status",
				"target": str(effect.get("target", "enemy")),
				"status": str(effect.get("status", "")),
				"value": amount,
				"source": card.get("name", "")
			}], context)
		"random_enemy_damage":
			var damage: int = _scaled(int(effect.get("value", 0)), multiplier)
			var enemies: Array = battle.formation.living_units("enemy")
			if enemies.is_empty():
				return
			var target_unit = enemies[battle.rng.randi_range(0, enemies.size() - 1)]
			var final_damage: int = damage if bool(effect.get("ignore_defense", false)) else max(0, damage - target_unit.current_defense())
			battle.apply_damage_to_unit(target_unit, final_damage, str(card.get("name", "")))
			battle.add_log("%s：随机命中 %s，造成 %d 点伤害。" % [card.get("name", ""), target_unit.name, final_damage])
		"summon":
			var count: int = max(0, _scaled(int(effect.get("count", 1)), multiplier))
			battle.effect_resolver.apply_steps(battle, battle.player, [{
				"kind": "summon",
				"count": count,
				"unit": effect.get("unit", {}),
				"source": card.get("name", "")
			}])
		"copy_next_tag":
			battle.player.copy_next_talisman = true
			battle.add_log("%s：本回合下一张“%s”牌将发动 2 次。" % [card.get("name", ""), effect.get("tag", "")])
		"persistent_sword_per_turn":
			battle.add_log("%s：放置到法防区。" % card.get("name", ""))
		"zone_delayed_effect":
			battle.add_log("%s：明牌放置，等待倒计时结算。" % card.get("name", ""))
		"zone_attach_search":
			battle.add_log("%s：明牌放置，被压牌将在倒计时后加入手牌。" % card.get("name", ""))
		"zone_damage_reduction":
			battle.add_log("%s：明牌放置，将在受伤时自动减伤。" % card.get("name", ""))
		"zone_next_enemy_action_status":
			battle.add_log("%s：明牌放置，将影响下一名敌方行动单位。" % card.get("name", ""))
		"equipment_recycle_first_tag":
			battle.add_log("%s：装备到装备区。" % card.get("name", ""))
		"equipment_attack_bonus":
			var amount := int(effect.get("value", 0))
			_apply_equipment_stat_delta(battle, card, context, "attack", amount)
			battle.add_log("%s：装备后攻击力 +%d。" % [card.get("name", ""), amount])
		"equipment_defense_bonus":
			var amount := int(effect.get("value", 0))
			_apply_equipment_stat_delta(battle, card, context, "defense", amount)
			battle.add_log("%s：装备后防御力 +%d。" % [card.get("name", ""), amount])
		"equipment_lethal_save":
			battle.add_log("%s：装备后可抵挡一次致命伤害。" % card.get("name", ""))
		"equipment_sword_per_turn":
			battle.add_log("%s：装备后将在玩家回合开始时生效。" % card.get("name", ""))
		_:
			battle.add_log("%s 没有可立即结算的效果。" % card.get("name", "卡牌"))

func finish_used_spell(battle, card: Dictionary, is_talisman: bool, context := {}) -> void:
	if card.is_empty():
		return
	if is_talisman and str(card.get("after_use", "graveyard")) == "graveyard" and battle.player.has_equipment("符匣") and not battle.player.first_talisman_recycled:
		battle.player.first_talisman_recycled = true
		battle.deck.add_to_deck_top(card)
		battle.add_log("符匣：本场第一张“符”牌使用后放回卡组顶。")
		return

	match card.get("after_use", "graveyard"):
		"graveyard":
			battle.deck.add_to_graveyard(card)
			battle.emit_combat_event({"type": "card_moved_to_graveyard", "card": card})
		"exile":
			battle.deck.add_to_exile(card)
			battle.emit_combat_event({"type": "card_moved_to_banish", "card": card})
		"spell_zone":
			card["face_down"] = false
			card["ready"] = true
			_prepare_spell_zone_card(card)
			battle.player.spell_zone.append(card)
			battle.emit_combat_event({"type": "card_placed_in_spell_zone", "card": card})
		"equipment":
			var target_unit = _attach_equipment_to_target(battle, card, context)
			battle.emit_combat_event({"type": "card_equipped", "card": card, "target": _unit_event_key(battle, target_unit), "target_uid": "" if target_unit == null else str(target_unit.uid)})
		_:
			battle.deck.add_to_graveyard(card)

func _prepare_spell_zone_card(card: Dictionary) -> void:
	var effect: Dictionary = card.get("effect", {})
	if effect.has("countdown"):
		card["zone_countdown"] = int(effect.get("countdown", 0))
	if effect.has("uses"):
		card["zone_uses_remaining"] = int(effect.get("uses", 0))

func _apply_unit_turn_start_equipment(battle, unit) -> void:
	if unit == null:
		return
	for card in unit.equipment:
		var effect: Dictionary = card.get("effect", {})
		if effect.get("kind", "") != "equipment_sword_per_turn":
			continue
		if unit != battle.player:
			continue
		if str(effect.get("job", "")) != "" and str(effect.get("job", "")) != battle.player.job_id:
			continue
		var amount := int(effect.get("value", 0))
		battle.player.add_sword(amount)
		battle.add_log("%s：获得 %d 点剑势。" % [card.get("name", ""), amount])
		battle.emit_combat_event({"type": "sword_power_changed", "target": _unit_event_key(battle, unit), "value": amount, "source": card.get("name", "")})

func _equipment_target_unit(battle, context := {}):
	var context_target = context.get("target_unit", null)
	if context_target != null:
		return context_target
	var target_uid := str(context.get("equipment_target_uid", ""))
	if target_uid != "":
		var target_unit = battle.formation.unit_by_uid(target_uid)
		if target_unit != null and int(target_unit.hp) > 0:
			return target_unit
	return battle.player

func _equipment_target_full(battle, context := {}) -> bool:
	var target_unit = _equipment_target_unit(battle, context)
	if target_unit == null:
		return true
	return target_unit.equipment.size() >= int(target_unit.equipment_limit)

func _apply_equipment_stat_delta(battle, card: Dictionary, context := {}, stat := "", amount := 0) -> void:
	var target_unit = _equipment_target_unit(battle, context)
	if target_unit == null:
		return
	match stat:
		"attack":
			target_unit.equipment_attack_bonus += amount
		"defense":
			target_unit.equipment_defense_bonus += amount
	card["equipped_to_uid"] = str(target_unit.uid)

func _attach_equipment_to_target(battle, card: Dictionary, context := {}):
	var target_unit = _equipment_target_unit(battle, context)
	if target_unit == null:
		target_unit = battle.player
	card["equipped_to_uid"] = str(target_unit.uid)
	target_unit.equipment.append(card)
	return target_unit

func _unit_event_key(battle, unit) -> String:
	if unit == null:
		return ""
	if battle.has_method("_unit_event_key"):
		return str(battle.call("_unit_event_key", unit))
	if unit == battle.player:
		return "player"
	if unit == battle.enemy:
		return "enemy"
	return str(unit.uid)

func activate_spell_zone_card(battle, uid: String) -> void:
	for card in battle.player.spell_zone:
		if str(card.get("uid", "")) == uid:
			if card.get("type", "") == CardDatabaseScript.TYPE_DEFENSE and not defense_ready(battle, card):
				battle.add_log("%s 盖伏当回合不能发动。" % card.get("name", ""))
				return
			battle.add_log("%s 没有可主动发动的效果。" % card.get("name", ""))
			return

func get_available_responses(battle, event: Dictionary) -> Array:
	var result: Array = []
	var event_type := str(event.get("event_type", ""))
	for card in battle.player.spell_zone:
		if card.get("type", "") != CardDatabaseScript.TYPE_DEFENSE:
			continue
		if not defense_ready(battle, card):
			continue
		if bool(card.get("sealed", false)):
			continue
		if bool(card.get("already_in_chain", false)):
			continue
		if not (event_type in card.get("trigger_timing", [])):
			continue
		if not _response_target_matches(battle, card, event):
			continue
		if not _extra_condition_met(battle, card, event):
			continue
		var effect: Dictionary = card.get("effect", {})
		var sword_cost := int(effect.get("sword_cost", 0))
		if sword_cost > battle.player.sword_momentum:
			continue
		result.append(card)
	return result

func mark_card_in_chain(battle, uid: String) -> Dictionary:
	for card in battle.player.spell_zone:
		if str(card.get("uid", "")) == uid:
			card["already_in_chain"] = true
			return card
	return {}

func resolve_chain_card(battle, card: Dictionary, event: Dictionary) -> void:
	if card.is_empty():
		return
	resolve_timing_effect(battle, card.get("effect", {}), event, card)
	move_spell_zone_card_to_destination(battle, card)

func resolve_timing_effect(battle, effect: Dictionary, event: Dictionary, source_card: Dictionary) -> void:
	var sword_cost := int(effect.get("sword_cost", 0))
	if sword_cost > 0:
		battle.player.add_sword(-sword_cost)
		battle.add_log("%s：消耗 %d 点剑势。" % [source_card.get("name", ""), sword_cost])
	match effect.get("kind", ""):
		"modify_damage":
			var before: int = int(event.get("value", 0))
			var after: int = max(0, before + int(effect.get("value", 0)))
			event["value"] = after
			event["modifiers"].append({
				"source": source_card.get("name", ""),
				"value": int(effect.get("value", 0))
			})
			battle.add_log("%s：本次伤害 %d -> %d。" % [source_card.get("name", ""), before, after])
			battle.emit_combat_event({"type": "damage_reduced", "target": _event_target_key(battle, event), "value": before - after, "source": source_card.get("name", "")})
		"gain_sword_power":
			var amount := int(effect.get("value", 0))
			battle.player.add_sword(amount)
			battle.add_log("%s：获得 %d 点剑势。" % [source_card.get("name", ""), amount])
			battle.emit_combat_event({"type": "sword_power_changed", "target": "player", "value": amount, "source": source_card.get("name", "")})
		"counter_attack_source":
			var source_unit = _event_source_unit(battle, event)
			if source_unit != null:
				var damage: int = max(0, battle.player.current_attack() - source_unit.current_defense())
				var counter_multiplier: float = float(effect.get("multiplier", 1.0))
				damage = int(floor(float(damage) * counter_multiplier))
				battle.apply_damage_to_unit(source_unit, damage, str(source_card.get("name", "")))
				battle.add_log("%s：反击 %s，造成 %d 点伤害。" % [source_card.get("name", ""), source_unit.name, damage])
				battle.call("_cleanup_defeated_units")
		"random_counter_attacks":
			var min_hits: int = max(1, int(effect.get("min_hits", 1)))
			var max_hits: int = max(min_hits, int(effect.get("max_hits", min_hits)))
			var hit_count: int = battle.rng.randi_range(min_hits, max_hits)
			for _i in range(hit_count):
				var enemies: Array = battle.formation.living_units("enemy")
				if enemies.is_empty():
					break
				var target_unit = enemies[battle.rng.randi_range(0, enemies.size() - 1)]
				var damage: int = max(0, battle.player.current_attack() - target_unit.current_defense())
				battle.apply_damage_to_unit(target_unit, damage, str(source_card.get("name", "")))
				battle.add_log("%s：回风斩击 %s，造成 %d 点伤害。" % [source_card.get("name", ""), target_unit.name, damage])
				battle.call("_cleanup_defeated_units")
		"damage_event_source":
			var source_unit = _event_source_unit(battle, event)
			if source_unit != null:
				var damage: int = int(effect.get("value", 0))
				if not bool(effect.get("ignore_defense", false)):
					damage = max(0, damage - source_unit.current_defense())
				battle.apply_damage_to_unit(source_unit, damage, str(source_card.get("name", "")))
				battle.add_log("%s：对 %s 造成 %d 点伤害。" % [source_card.get("name", ""), source_unit.name, damage])
				battle.call("_cleanup_defeated_units")
				if int(source_unit.hp) <= 0:
					event["cancelled"] = true
		"interrupt_event":
			event["cancelled"] = true
			battle.add_log("%s：打断本次事件。" % source_card.get("name", ""))
			battle.emit_combat_event({"type": "event_interrupted", "target": "enemy", "source": source_card.get("name", "")})
		"cancel_or_reduce_event":
			var source_unit = _event_source_unit(battle, event)
			var is_boss := source_unit != null and str(source_unit.unit_rank) == "boss"
			if is_boss and effect.has("boss_reduce"):
				var before: int = int(event.get("value", 0))
				var after: int = max(0, before - int(effect.get("boss_reduce", 0)))
				event["value"] = after
				battle.add_log("%s：首领抗性，本次威力 %d -> %d。" % [source_card.get("name", ""), before, after])
				battle.emit_combat_event({"type": "damage_reduced", "target": _event_target_key(battle, event), "value": before - after, "source": source_card.get("name", "")})
			else:
				event["cancelled"] = true
				battle.add_log("%s：取消本次事件。" % source_card.get("name", ""))
				battle.emit_combat_event({"type": "event_interrupted", "target": "enemy", "source": source_card.get("name", "")})
		"protect_destroy_target":
			var protected_targets: Array = event.get("protected_targets", [])
			var target_key := _target_key(event.get("target", {}))
			if target_key != "":
				protected_targets.append(target_key)
			event["protected_targets"] = protected_targets
			battle.add_log("%s：保护本次破坏目标。" % source_card.get("name", ""))
		"set_player_hp_to_one_if_lethal":
			var damage := int(event.get("value", 0))
			if damage >= battle.player.hp:
				event["value"] = max(0, battle.player.hp - 1)
				battle.add_log("%s：本次致命伤害改为保留 1 点生命。" % source_card.get("name", ""))
		"multi":
			for sub_effect in effect.get("effects", []):
				resolve_timing_effect(battle, sub_effect, event, source_card)
		_:
			battle.add_log("%s 没有可在当前时点结算的效果。" % source_card.get("name", ""))

func apply_attack_defenses(battle, base_damage: int) -> int:
	var damage := base_damage
	if damage <= 0:
		return damage
	var triggered := ready_defenses(battle, "on_attack")
	for card in triggered:
		var effect: Dictionary = card.get("effect", {})
		damage = max(0, damage - int(effect.get("damage_reduction", 0)))
		if int(effect.get("sword_gain", 0)) > 0:
			battle.player.add_sword(int(effect.get("sword_gain", 0)))
		move_spell_zone_card_to_destination(battle, card)
		battle.add_log("%s 触发：本次伤害减少 %d。" % [card.get("name", ""), int(effect.get("damage_reduction", 0))])
	return damage

func apply_lethal_defense(battle, damage: int) -> int:
	if damage < battle.player.hp or damage <= 0:
		return damage
	var life_card := first_ready_defense(battle, "on_lethal")
	if life_card.is_empty():
		return damage
	move_spell_zone_card_to_destination(battle, life_card)
	battle.add_log("%s 触发：本次伤害改为使生命降到 1。" % life_card.get("name", ""))
	return max(0, battle.player.hp - 1)

func try_counter_spell(battle) -> bool:
	var counter := first_ready_defense(battle, "on_spell")
	if counter.is_empty():
		return false
	move_spell_zone_card_to_destination(battle, counter)
	battle.add_log("%s 触发：取消敌人本次施法。" % counter.get("name", ""))
	return true

func ready_defenses(battle, trigger: String) -> Array:
	var result: Array = []
	for card in battle.player.spell_zone:
		if card.get("type", "") == CardDatabaseScript.TYPE_DEFENSE and trigger in card.get("trigger_timing", []) and defense_ready(battle, card):
			result.append(card)
	return result

func first_ready_defense(battle, trigger: String) -> Dictionary:
	for card in battle.player.spell_zone:
		if card.get("type", "") == CardDatabaseScript.TYPE_DEFENSE and trigger in card.get("trigger_timing", []) and defense_ready(battle, card):
			return card
	return {}

func defense_ready(battle, card: Dictionary) -> bool:
	if card.has("ready"):
		return bool(card.get("ready", false))
	var ready: bool = int(card.get("set_turn", card.get("cover_turn", 999999))) < battle.turn_number
	card["ready"] = ready
	return ready

func ready_defenses_after_player_turn(battle) -> void:
	var names: Array = []
	for card in battle.player.spell_zone:
		if card.get("type", "") == CardDatabaseScript.TYPE_DEFENSE and bool(card.get("face_down", false)) and not bool(card.get("ready", false)):
			if str(card.get("set_turn_owner", "player")) == "player":
				card["ready"] = true
				names.append(card.get("name", "卡牌"))
	if names.is_empty():
		return
	battle.add_log("回合结束：%s 已就绪。" % "、".join(names))

func move_spell_zone_card_to_destination(battle, card: Dictionary) -> void:
	for i in range(battle.player.spell_zone.size()):
		if str(battle.player.spell_zone[i].get("uid", "")) == str(card.get("uid", "")):
			battle.player.spell_zone.remove_at(i)
			break
	if battle.has_method("_release_attached_cards_to_graveyard"):
		battle.call("_release_attached_cards_to_graveyard", card)
	card.erase("face_down")
	if card.get("after_use", "graveyard") == "exile":
		battle.deck.add_to_exile(card)
		battle.add_log("%s 进入除外区。" % card.get("name", ""))
		battle.emit_combat_event({"type": "card_moved_to_banish", "card": card})
	else:
		battle.deck.add_to_graveyard(card)
		battle.add_log("%s 进入墓地。" % card.get("name", ""))
		battle.emit_combat_event({"type": "card_moved_to_graveyard", "card": card})

func _extra_condition_met(battle, card: Dictionary, event: Dictionary) -> bool:
	var effect: Dictionary = card.get("effect", {})
	var event_sources: Array = card.get("event_sources", effect.get("event_sources", []))
	if not event_sources.is_empty() and not (str(event.get("source", "")) in event_sources):
		return false
	if effect.get("kind", "") == "set_player_hp_to_one_if_lethal":
		return int(event.get("value", 0)) >= battle.player.hp
	return true

func _response_target_matches(battle, card: Dictionary, event: Dictionary) -> bool:
	var scope := str(card.get("response_target", "any"))
	if scope == "" or scope == "any":
		return true
	var target = null
	if battle.has_method("_event_target_unit"):
		target = battle.call("_event_target_unit", event)
	match scope:
		"player", "primary_player":
			return target == battle.player
		"ally_unit":
			return target != null and str(target.team) == "player"
	return true

func _event_target_key(battle, event: Dictionary) -> String:
	if battle.has_method("_event_target_unit") and battle.has_method("_unit_event_key"):
		var target = battle.call("_event_target_unit", event)
		if target != null:
			return str(battle.call("_unit_event_key", target))
	return str(event.get("target_key", "player"))

func _event_source_unit(battle, event: Dictionary):
	var source_key := str(event.get("attack_source_key", event.get("source_key", "")))
	if battle.has_method("_event_target_unit"):
		var source_unit = battle.call("_event_target_unit", {
			"target": event.get("source", null),
			"target_key": source_key
		})
		if source_unit != null:
			return source_unit
	if source_key != "":
		return battle.formation.unit_by_uid(source_key)
	return null

func _target_key(target) -> String:
	if target is Dictionary:
		return str(target.get("uid", target.get("id", target.get("name", ""))))
	return str(target)

func _scaled(value: int, multiplier: float) -> int:
	if value <= 0:
		return 0
	return max(1, int(floor(float(value) * multiplier)))

func _needs_enemy_target(effect: Dictionary) -> bool:
	match str(effect.get("kind", "")):
		"direct_damage", "reduce_enemy_defense":
			return true
		"add_status":
			return str(effect.get("target", "")) in ["enemy", "primary_enemy"]
		"multi":
			for sub_effect in effect.get("effects", []):
				if _needs_enemy_target(sub_effect):
					return true
	return false

func _cards_in_deck_matching_filter(battle, filter: Dictionary) -> Array:
	var result: Array = []
	for card in battle.deck.deck:
		var card_dict: Dictionary = card
		if _card_matches_filter(card_dict, filter):
			result.append(card_dict)
	return result

func _card_matches_filter(card: Dictionary, filter: Dictionary) -> bool:
	if card.is_empty():
		return false
	if filter.has("tag") and not (str(filter.get("tag", "")) in card.get("tags", [])):
		return false
	if filter.has("required_tags"):
		for tag_variant in filter.get("required_tags", []):
			if not (str(tag_variant) in card.get("tags", [])):
				return false
	if filter.has("max_cost") and CardDatabaseScript.card_score(str(card.get("id", ""))) > int(filter.get("max_cost", 0)):
		return false
	if filter.has("min_cost") and CardDatabaseScript.card_score(str(card.get("id", ""))) < int(filter.get("min_cost", 0)):
		return false
	return true
