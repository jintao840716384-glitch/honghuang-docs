extends RefCounted
class_name DeckManager

const CardDatabaseScript = preload("res://scripts/data/CardDatabase.gd")

const DEFAULT_HAND_LIMIT := 6

var deck: Array = []
var hand: Array = []
var graveyard: Array = []
var exile: Array = []
var messages: Array = []
var hand_limit: int = DEFAULT_HAND_LIMIT
var reshuffle_pending: bool = false

func setup_battle(deck_ids: Array) -> void:
	deck.clear()
	hand.clear()
	graveyard.clear()
	exile.clear()
	messages.clear()
	reshuffle_pending = false
	for card_id in deck_ids:
		deck.append(CardDatabaseScript.make_card(str(card_id)))
	deck.shuffle()

func draw(amount: int) -> Array:
	var drawn: Array = []
	for i in range(max(0, amount)):
		if hand.size() >= hand_limit:
			messages.append("手牌已满，无法继续抽牌。")
			break
		if deck.is_empty():
			_mark_reshuffle_pending()
		if deck.is_empty():
			messages.append("牌库为空，等待回合结束重整。")
			break
		var card: Dictionary = deck.pop_back()
		hand.append(card)
		drawn.append(card)
		if deck.is_empty():
			_mark_reshuffle_pending()
	if drawn.size() > 0:
		messages.append("抽到 %d 张牌。" % drawn.size())
	return drawn

func process_pending_reshuffle() -> bool:
	if not reshuffle_pending:
		return false
	reshuffle_pending = false
	if graveyard.is_empty():
		return false
	deck = graveyard.duplicate(true)
	graveyard.clear()
	deck.shuffle()
	messages.append("回合结束，墓地洗回牌库。")
	return true

func take_messages() -> Array:
	var result := messages.duplicate()
	messages.clear()
	return result

func find_hand_card(uid: String) -> Dictionary:
	for card in hand:
		if str(card.get("uid", "")) == uid:
			return card
	return {}

func remove_from_hand(uid: String) -> Dictionary:
	for i in range(hand.size()):
		var card: Dictionary = hand[i]
		if str(card.get("uid", "")) == uid:
			hand.remove_at(i)
			return card
	return {}

func add_to_hand(card: Dictionary) -> void:
	if not card.is_empty():
		hand.append(card)

func discard_from_hand(uid: String) -> Dictionary:
	var card := remove_from_hand(uid)
	add_to_graveyard(card)
	return card

func remove_from_graveyard(uid: String) -> Dictionary:
	for i in range(graveyard.size()):
		var card: Dictionary = graveyard[i]
		if str(card.get("uid", "")) == uid:
			graveyard.remove_at(i)
			return card
	return {}

func remove_from_deck(uid: String) -> Dictionary:
	for i in range(deck.size()):
		var card: Dictionary = deck[i]
		if str(card.get("uid", "")) == uid:
			deck.remove_at(i)
			return card
	return {}

func add_to_graveyard(card: Dictionary) -> void:
	if not card.is_empty():
		graveyard.append(card)

func add_to_exile(card: Dictionary) -> void:
	if not card.is_empty():
		exile.append(card)

func add_to_deck_top(card: Dictionary) -> void:
	if not card.is_empty():
		deck.append(card)

func cards_in_graveyard_with_tag(tag: String) -> Array:
	var result: Array = []
	for card in graveyard:
		if tag in card.get("tags", []):
			result.append(card)
	return result

func cards_in_deck_with_tag(tag: String) -> Array:
	var result: Array = []
	for card in deck:
		if tag in card.get("tags", []):
			result.append(card)
	return result

func _mark_reshuffle_pending() -> void:
	reshuffle_pending = true
