extends RefCounted
class_name BattleAudioRouter

static func events_for_combat_event(event: Dictionary) -> Array:
	match str(event.get("type", "")):
		"attack_started":
			return ["attack"]
		"damage_applied":
			return ["hit"]
		"heal_applied":
			return ["heal"]
		"card_played":
			return ["card_play"]
		"defense_card_set":
			return ["card_set"]
		"card_placed_in_spell_zone":
			return ["card_place"]
		"card_equipped":
			return ["card_equip"]
		"card_destroyed":
			return ["card_break"]
		"defense_card_activated":
			return ["defense_activate"]
		"chain_started":
			return ["chain_start"]
		"chain_card_resolved":
			return ["chain_resolve"]
	return []
