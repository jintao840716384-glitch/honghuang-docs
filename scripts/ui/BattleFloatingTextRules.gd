extends RefCounted
class_name BattleFloatingTextRules

static func entries_for_combat_event(event: Dictionary) -> Array:
	match str(event.get("type", "")):
		"damage_applied":
			return [{
				"target": str(event.get("target", "")),
				"text": "-%d" % int(event.get("value", 0)),
				"color": Color(1.0, 0.22, 0.18, 1.0),
				"hit": true
			}]
		"heal_applied":
			return [{
				"target": str(event.get("target", "player")),
				"text": "+%d" % int(event.get("value", 0)),
				"color": Color(0.30, 1.0, 0.45, 1.0)
			}]
		"sword_power_changed":
			return [{
				"target": "player",
				"text": "剑势 +%d" % int(event.get("value", 0)),
				"color": Color(0.55, 0.78, 1.0, 1.0)
			}]
		"damage_reduced":
			return [{
				"target": str(event.get("target", "player")),
				"text": "减伤 %d" % int(event.get("value", 0)),
				"color": Color(0.65, 0.85, 1.0, 1.0)
			}]
		"unit_defended":
			return [{
				"target": str(event.get("target", "player")),
				"text": "防御 +%d" % int(event.get("value", 0)),
				"color": Color(0.58, 0.78, 1.0, 1.0)
			}]
	return []
