extends Node

func await_time(time: int):
	await get_tree().create_timer(time).timeout
	return

func get_site_select_current_card() -> Card:
	var battle = get_tree().get_first_node_in_group("battle") as Battle
	if !battle:
		return null
	return battle.site_select_hud.current_card

func get_sites_by_name(site_names: Array[String]) -> Array[Node]:
	var targets = []
	var sites = get_tree().get_nodes_in_group("site") as Array[Site]
	for site in sites:
		if site.site_data.site_name in site_names:
			targets.append(site)
	return targets
