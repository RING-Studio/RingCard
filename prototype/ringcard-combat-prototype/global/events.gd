extends Node

signal card_start_dragging(card: Card)
signal card_end_dragging(card: Card)
signal card_start_targeting(card: Card)
signal card_end_targeting(card: Card)
signal card_play_failed(card: Card)
signal card_start_playing(card: Card)
signal card_end_playing(card: Card)

signal start_site_selecting(card: Card)
signal end_site_selecting(targets: Array[Node])
