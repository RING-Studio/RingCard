extends Node

signal card_start_dragging(card: Card)
signal card_end_dragging(card: Card)
signal card_start_targeting(card: Card)
signal card_end_targeting(card: Card)
signal card_played(card: Card)

signal start_site_selecting(card: Card)
signal end_site_selecting(targets: Array[Node])
