extends RefCounted
class_name BattleSide

const DeckManagerScript = preload("res://scripts/battle/DeckManager.gd")

var side_id: String = ""
var team: String = ""
var core_unit = null
var units: Array = []
var deck_manager: DeckManager
var spell_zone: Array = []
var equipment: Array = []
var draw_per_turn: int = 1
var deck_ids: Array = []
var visible_zones: Dictionary = {}

func _init() -> void:
	deck_manager = DeckManagerScript.new()
	visible_zones = {
		"spell_zone": true,
		"hand": false,
		"deck": false,
		"graveyard": false,
		"exile": false
	}

func setup(side_id_value: String, team_value: String, side_core, source_units: Array, source_deck_manager = null) -> void:
	side_id = side_id_value
	team = team_value
	core_unit = side_core
	units = source_units
	if source_deck_manager != null:
		deck_manager = source_deck_manager

func set_units(source_units: Array) -> void:
	units = source_units

func bind_player_state(player_state) -> void:
	if player_state == null:
		return
	spell_zone = player_state.spell_zone
	equipment = player_state.equipment

func reset_visible_zones() -> void:
	spell_zone.clear()
	equipment.clear()

func setup_deck(card_ids: Array) -> void:
	deck_ids = card_ids.duplicate()
	if deck_manager != null:
		deck_manager.setup_battle(deck_ids)

func draw_cards(amount: int) -> Array:
	if deck_manager == null:
		return []
	return deck_manager.draw(max(0, amount))

func process_pending_reshuffle() -> bool:
	if deck_manager == null:
		return false
	return deck_manager.process_pending_reshuffle()

func take_deck_messages() -> Array:
	if deck_manager == null:
		return []
	return deck_manager.take_messages()
