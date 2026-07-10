extends RefCounted
class_name MapContentDatabase

const CONTENT_STATE_ACTIVE := "active"
const LAYOUT_ID := "main_story_layout_01"
const TREASURE_ID := "treasure_card_choice_01"

const NODE_TITLES := {
	"normal": "战斗",
	"elite": "精英",
	"boss": "首领",
	"event": "事件",
	"treasure": "宝箱",
	"shop": "坊市",
	"rest": "休息"
}

const NODE_TITLE_KEYS := {
	"normal": "map.node.normal",
	"elite": "map.node.elite",
	"boss": "map.node.boss",
	"event": "map.node.event",
	"treasure": "map.node.treasure",
	"shop": "map.node.shop",
	"rest": "map.node.rest"
}

const LAYOUT_DEFINITION := {
	"layout_id": LAYOUT_ID,
	"content_state": CONTENT_STATE_ACTIVE,
	"floors": [
		[
			{"lane": -1.0, "type": "normal"},
			{"lane": 0.0, "type": "normal"},
			{"lane": 1.0, "type": "normal"}
		],
		[
			{"lane": -0.6, "type": "normal"},
			{"lane": 0.8, "type": "event"}
		],
		[
			{"lane": -1.1, "type": "normal"},
			{"lane": 0.0, "type": "elite"},
			{"lane": 1.1, "type": "shop"}
		],
		[
			{"lane": -0.7, "type": "event"},
			{"lane": 0.0, "type": "treasure"},
			{"lane": 0.7, "type": "elite"}
		],
		[
			{"lane": -1.0, "type": "elite"},
			{"lane": 0.0, "type": "rest"},
			{"lane": 1.0, "type": "normal"}
		],
		[
			{"lane": -0.55, "type": "elite"},
			{"lane": 0.55, "type": "event"}
		],
		[
			{"lane": 0.0, "type": "boss"}
		]
	]
}

const TREASURE_DEFINITION := {
	"treasure_id": TREASURE_ID,
	"content_state": CONTENT_STATE_ACTIVE,
	"reward_kind": "card_choice",
	"choice_count": 3
}


static func layout_definitions() -> Array:
	return [LAYOUT_DEFINITION.duplicate(true)]


static func active_layout() -> Dictionary:
	return LAYOUT_DEFINITION.duplicate(true)


static func treasure_definitions() -> Array:
	return [TREASURE_DEFINITION.duplicate(true)]


static func active_treasure() -> Dictionary:
	return TREASURE_DEFINITION.duplicate(true)


static func node_title(node_type: String) -> String:
	return str(NODE_TITLES.get(node_type, NODE_TITLES["normal"]))


static func node_title_key(node_type: String) -> String:
	return str(NODE_TITLE_KEYS.get(node_type, NODE_TITLE_KEYS["normal"]))
