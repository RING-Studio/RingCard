extends Control

@export var card_data: CardData

var is_dragging := false
var initial_position: Vector2
var drag_offset: Vector2

func _ready():
	self.gui_input.connect(_on_gui_input)
	mouse_filter = MOUSE_FILTER_PASS
	update_card_display()

func update_card_display():
	if card_data:
		$CostLabel.text = "%d" % card_data.cost

# 使用Control的GUI输入事件
func _on_gui_input(event: InputEvent):
	# 左键拖拽
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				print("开始拖拽")
				start_drag(event)
			else:
				end_drag()
		# 右键取消
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			cancel_drag()
	
	# 拖拽移动
	if event is InputEventMouseMotion and is_dragging:
		global_position = get_global_mouse_position() - drag_offset

func start_drag(event: InputEventMouseButton):
	initial_position = global_position
	drag_offset = event.position
	is_dragging = true
	z_index = 100  # 提升层级
	# 禁用父级容器输入
	#get_parent().mouse_filter = MOUSE_FILTER_IGNORE

func end_drag():
	is_dragging = false
	z_index = 0
	#get_parent().mouse_filter = MOUSE_FILTER_PASS
	
	if is_in_play_area():
		play_card()
	else:
		return_to_hand()

func cancel_drag():
	if is_dragging:
		return_to_hand()
		is_dragging = false
		get_parent().mouse_filter = MOUSE_FILTER_PASS
		
func play_card():
	print("打出卡牌:", card_data.card_name)
	var parent = get_parent()
	if parent.get_parent() && parent.get_parent().name == "Hand":
		# 触发卡牌打出信号
		get_parent().card_played(self)
		queue_free()  # 或移动到游戏区域
	
func return_to_hand():
	var tween = create_tween()
	tween.tween_property(self, "global_position", initial_position, 0.2)\
		 .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		
func is_in_play_area() -> bool:
	# 转换为全局坐标判断
	var parent = get_parent()
	if parent.get_parent() && parent.get_parent().name == "Hand":
		var hand_global_pos = get_parent().get_global_rect().position
		return get_global_rect().position.y < hand_global_pos.y - 200
	else:
		return true
