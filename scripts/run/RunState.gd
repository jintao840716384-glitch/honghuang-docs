extends RefCounted
class_name RunState

const JobDatabaseScript = preload("res://scripts/data/JobDatabase.gd")
const MapGeneratorScript = preload("res://scripts/run/MapGenerator.gd")

var job_id := ""
var job_name := ""
var deck_ids: Array = []
var map_nodes: Array = []
var completed_node_ids: Dictionary = {}
var current_node_id := ""
var pending_node_id := ""

func start(selected_job_id: String) -> void:
	job_id = selected_job_id
	var job := JobDatabaseScript.get_job(job_id)
	job_name = str(job.get("name", job_id))
	deck_ids = job.get("start_deck", []).duplicate()
	map_nodes = MapGeneratorScript.generate()
	completed_node_ids.clear()
	current_node_id = ""
	pending_node_id = ""

func available_nodes() -> Array:
	var ids := available_node_ids()
	var result: Array = []
	for node in map_nodes:
		if ids.has(str(node.get("id", ""))):
			result.append(node)
	return result

func available_node_ids() -> Dictionary:
	var result: Dictionary = {}
	if is_complete():
		return result
	if current_node_id == "":
		for node in map_nodes:
			if int(node.get("floor", 0)) == 0:
				result[str(node.get("id", ""))] = true
		return result

	var current_node := get_node_data(current_node_id)
	for next_id in current_node.get("next", []):
		var id := str(next_id)
		if not completed_node_ids.has(id):
			result[id] = true
	return result

func begin_node(node_id: String) -> void:
	if is_node_available(node_id):
		pending_node_id = node_id

func complete_node(node_id: String) -> void:
	if node_id == "":
		return
	completed_node_ids[node_id] = true
	current_node_id = node_id
	pending_node_id = ""

func update_deck(new_deck_ids: Array) -> void:
	deck_ids = new_deck_ids.duplicate()

func is_node_completed(node_id: String) -> bool:
	return completed_node_ids.has(node_id)

func is_node_available(node_id: String) -> bool:
	return available_node_ids().has(node_id)

func is_complete() -> bool:
	if current_node_id == "" or not completed_node_ids.has(current_node_id):
		return false
	var node := get_node_data(current_node_id)
	return str(node.get("type", "")) == "boss"

func battle_number_for_node(node: Dictionary) -> int:
	return int(node.get("floor", 0)) + 1

func get_node_data(node_id: String) -> Dictionary:
	for node in map_nodes:
		if str(node.get("id", "")) == node_id:
			return node
	return {}
