extends RefCounted
class_name SideController


func action_queue_for_units(units: Array) -> Array:
	return units.duplicate()


func prepare_unit_turn(_battle, _source_unit) -> void:
	pass


func next_unit_action(_battle, _source_unit) -> Dictionary:
	return {}


func side_card_source_unit(_battle):
	return null


func select_next_side_card(_battle, _source_unit) -> Dictionary:
	return {}


func side_card_profile(_card_id: String) -> Dictionary:
	return {}
