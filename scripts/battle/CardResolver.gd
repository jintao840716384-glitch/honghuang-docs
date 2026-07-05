extends RefCounted
class_name CardResolver

const CardDatabaseScript = preload("res://scripts/data/CardDatabase.gd")

func apply_player_turn_start(battle) -> void:
	for card in battle.player.spell_zone:
		var effect: Dictionary = card.get("effect", {})
		if effect.get("kind", "") == "persistent_sword_per_turn":
			var amount := int(effect.get("value", 0))
			battle.player.add_sword(amount)
			battle.add_log("%s：获得 %d 点剑势。" % [card.get("name", ""), amount])

	for card in battle.player.equipment:
		var effect: Dictionary = card.get("effect", {})
		if effect.get("kind", "") == "equipment_sword_per_turn":
			if str(effect.get("job", "")) != "" and str(effect.get("job", "")) != battle.player.job_id:
				continue
			var amount := int(effect.get("value", 0))
			battle.player.add_sword(amount)
			battle.add_log("%s：获得 %d 点剑势。" % [card.get("name", ""), amount])
			battle.emit_combat_event({"type": "sword_power_changed", "target": "player", "value": amount, "source": card.get("name", "")})

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

func play_spell_card(battle, uid: String) -> void:
	var card: Dictionary = battle.deck.find_hand_card(uid)
	if card.is_empty():
		return
	if not can_play_spell(battle, card, true):
		return
	if str(card.get("after_use", "")) == "equipment" and battle.player.equipment.size() >= battle.player.equipment_limit:
		_start_equipment_replacement(battle, uid, card)
		return
	var effect: Dictionary = card.get("effect", {})
	match effect.get("kind", ""):
		"recover_graveyard_tag":
			_start_pick_from_graveyard(battle, uid, str(effect.get("tag", "")))
		"discard_search_deck_tag":
			_start_discard_for_search(battle, uid, str(effect.get("tag", "")))
		_:
			card = battle.deck.remove_from_hand(uid)
			battle.emit_combat_event({"type": "card_played", "card": card})
			resolve_and_finish_spell(battle, card)

func can_play_spell(battle, card: Dictionary, allow_equipment_replace := false) -> bool:
	var effect: Dictionary = card.get("effect", {})
	var sword_cost := int(effect.get("sword_cost", 0))
	if sword_cost > battle.player.sword_momentum:
		battle.add_log("%s 需要 %d 点剑势。" % [card.get("name", ""), sword_cost])
		return false
	var after_use := str(card.get("after_use", "graveyard"))
	if after_use == "spell_zone" and battle.player.spell_zone.size() >= 5:
		battle.add_log("法防区已满，不能使用 %s。" % card.get("name", ""))
		return false
	if after_use == "equipment" and battle.player.equipment.size() >= battle.player.equipment_limit:
		if allow_equipment_replace:
			return true
		battle.add_log("装备区已满，不能使用 %s。" % card.get("name", ""))
		return false
	if effect.get("kind", "") == "discard_search_deck_tag" and battle.deck.hand.size() <= 1:
		battle.add_log("%s 需要弃置 1 张其他手牌。" % card.get("name", ""))
		return false
	return true

func _start_equipment_replacement(battle, uid: String, card: Dictionary) -> void:
	battle.pending_equipment_replace = {
		"source_uid": uid,
		"source_card": card.duplicate(true)
	}
	battle.add_log("装备区已满，请选择 1 张装备替换。")
	battle.emit_combat_event({"type": "equipment_replace_started", "card": card})

func choose_equipment_replacement(battle, equipment_uid: String) -> void:
	if battle.pending_equipment_replace.is_empty():
		return
	var source_uid := str(battle.pending_equipment_replace.get("source_uid", ""))
	var source_card: Dictionary = battle.deck.remove_from_hand(source_uid)
	if source_card.is_empty():
		battle.pending_equipment_replace.clear()
		battle.add_log("找不到要装备的卡牌，取消替换。")
		return
	var old_card := _remove_equipment_by_uid(battle, equipment_uid)
	if old_card.is_empty():
		battle.deck.add_to_hand(source_card)
		battle.pending_equipment_replace.clear()
		battle.add_log("没有找到要替换的装备。")
		return
	_remove_equipment_effect(battle, old_card)
	battle.deck.add_to_graveyard(old_card)
	battle.pending_equipment_replace.clear()
	battle.add_log("替换装备：%s 进入墓地，装备 %s。" % [old_card.get("name", "装备"), source_card.get("name", "装备")])
	battle.emit_combat_event({"type": "equipment_replaced", "old_card": old_card, "new_card": source_card})
	battle.emit_combat_event({"type": "card_moved_to_graveyard", "card": old_card})
	battle.emit_combat_event({"type": "card_played", "card": source_card})
	resolve_and_finish_spell(battle, source_card)

func _remove_equipment_by_uid(battle, equipment_uid: String) -> Dictionary:
	for i in range(battle.player.equipment.size()):
		var card: Dictionary = battle.player.equipment[i]
		if str(card.get("uid", "")) == equipment_uid:
			battle.player.equipment.remove_at(i)
			return card
	return {}

func _remove_equipment_effect(battle, card: Dictionary) -> void:
	var effect: Dictionary = card.get("effect", {})
	match effect.get("kind", ""):
		"equipment_attack_bonus":
			battle.player.equipment_attack_bonus -= int(effect.get("value", 0))
		"equipment_defense_bonus":
			battle.player.equipment_defense_bonus -= int(effect.get("value", 0))

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

func resolve_and_finish_spell(battle, card: Dictionary) -> void:
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

	resolve_spell_effect(battle, card, 1.0)
	if copy_talisman:
		resolve_spell_effect(battle, card, float(effect.get("second_multiplier", 0.5)))
		battle.add_log("%s 的第二次效果按 50%% 结算。" % card.get("name", ""))

	finish_used_spell(battle, card, is_talisman)
	battle.check_victory_or_defeat()

func resolve_spell_effect(battle, card: Dictionary, multiplier := 1.0) -> void:
	var effect: Dictionary = card.get("effect", {})
	match effect.get("kind", ""):
		"attack_boost":
			var attack_bonus := _scaled(int(effect.get("attack_bonus", 0)), multiplier)
			var sword_on_hit := _scaled(int(effect.get("extra_sword_on_hit", 0)), multiplier)
			battle.player.attack_bonus_this_turn += attack_bonus
			battle.player.extra_sword_on_attack_hit += sword_on_hit
			battle.add_log("%s：本回合普通攻击攻击力 +%d。" % [card.get("name", ""), attack_bonus])
		"direct_damage":
			var damage := _scaled(int(effect.get("value", 0)), multiplier)
			battle.enemy.hp -= damage
			battle.add_log("%s：对敌人造成 %d 点直接伤害。" % [card.get("name", ""), damage])
			battle.emit_combat_event({"type": "damage_applied", "target": "enemy", "value": damage, "source": card.get("name", "")})
		"heal":
			var amount := _scaled(int(effect.get("value", 0)), multiplier)
			var before: int = battle.player.hp
			battle.player.hp = min(battle.player.max_hp, battle.player.hp + amount)
			battle.add_log("%s：回复 %d 点生命。" % [card.get("name", ""), battle.player.hp - before])
			battle.emit_combat_event({"type": "heal_applied", "target": "player", "value": battle.player.hp - before, "source": card.get("name", "")})
		"reduce_enemy_defense":
			var amount := _scaled(int(effect.get("value", 0)), multiplier)
			battle.enemy.defense -= amount
			battle.add_log("%s：敌人防御力 -%d。" % [card.get("name", ""), amount])
		"copy_next_tag":
			battle.player.copy_next_talisman = true
			battle.add_log("%s：本回合下一张“%s”牌将发动 2 次。" % [card.get("name", ""), effect.get("tag", "")])
		"persistent_sword_per_turn":
			battle.add_log("%s：放置到法防区。" % card.get("name", ""))
		"equipment_recycle_first_tag":
			battle.add_log("%s：装备到装备区。" % card.get("name", ""))
		"equipment_attack_bonus":
			var amount := int(effect.get("value", 0))
			battle.player.equipment_attack_bonus += amount
			battle.add_log("%s：装备后攻击力 +%d。" % [card.get("name", ""), amount])
		"equipment_defense_bonus":
			var amount := int(effect.get("value", 0))
			battle.player.equipment_defense_bonus += amount
			battle.add_log("%s：装备后防御力 +%d。" % [card.get("name", ""), amount])
		"equipment_sword_per_turn":
			battle.add_log("%s：装备后将在玩家回合开始时生效。" % card.get("name", ""))
		_:
			battle.add_log("%s 没有可立即结算的效果。" % card.get("name", "卡牌"))

func finish_used_spell(battle, card: Dictionary, is_talisman: bool) -> void:
	if card.is_empty():
		return
	if is_talisman and battle.player.has_equipment("符匣") and not battle.player.first_talisman_recycled:
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
			battle.player.spell_zone.append(card)
			battle.emit_combat_event({"type": "card_placed_in_spell_zone", "card": card})
		"equipment":
			battle.player.equipment.append(card)
			battle.emit_combat_event({"type": "card_equipped", "card": card})
		_:
			battle.deck.add_to_graveyard(card)

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
		if not _extra_condition_met(battle, card, event):
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
			battle.emit_combat_event({"type": "damage_reduced", "target": "player", "value": before - after, "source": source_card.get("name", "")})
		"gain_sword_power":
			var amount := int(effect.get("value", 0))
			battle.player.add_sword(amount)
			battle.add_log("%s：获得 %d 点剑势。" % [source_card.get("name", ""), amount])
			battle.emit_combat_event({"type": "sword_power_changed", "target": "player", "value": amount, "source": source_card.get("name", "")})
		"interrupt_event":
			event["cancelled"] = true
			battle.add_log("%s：打断本次事件。" % source_card.get("name", ""))
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
	if effect.get("kind", "") == "set_player_hp_to_one_if_lethal":
		return int(event.get("value", 0)) >= battle.player.hp
	return true

func _target_key(target) -> String:
	if target is Dictionary:
		return str(target.get("uid", target.get("id", target.get("name", ""))))
	return str(target)

func _scaled(value: int, multiplier: float) -> int:
	if value <= 0:
		return 0
	return max(1, int(floor(float(value) * multiplier)))
