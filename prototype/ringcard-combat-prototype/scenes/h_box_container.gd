extends HBoxContainer

@export var card_scene: PackedScene

func add_card() -> void:
	var new_card = card_scene.instantiate() as Card
	add_child(new_card)
	# 初始化卡牌数据（如颜色、数值）
	new_card.color = Color(randf(), randf(), randf())
	# 连接信号
	#new_card.put_back.connect(_on_card_put_back.bind(new_card))
	update_layout()

func update_layout() -> void:
	var card_count = get_child_count()
	if card_count == 0: return
	
	# 计算总宽度和起始位置
	var total_width = 0.0
	for card in get_children():
		total_width += card.size.x
	
	var spacing = (size.x - total_width) / (card_count + 1)
	var start_x = spacing
	
	# 设置每张卡牌的位置
	for card in get_children():
		card.position.x = start_x
		start_x += card.size.x + spacing
		card.position.y = size.y / 2 - card.size.y / 2  # 垂直居中
		
func _on_card_dragged(is_dragging: bool, card: Control) -> void:
	if is_dragging:
		card.z_index = 1  # 被拖拽的卡牌置顶
		# 其他卡牌向两侧移动
		var index = card.get_index()
		for i in range(get_child_count()):
			var c = get_child(i)
			if c == card: continue
			var target_x = c.position.x
			if i < index:
				target_x -= 50  # 左侧卡牌左移
			else:
				target_x += 50  # 右侧卡牌右移
			create_tween().tween_property(c, "position:x", target_x, 0.2)
	else:
		card.z_index = 0
		# 恢复原位
		update_layout()
