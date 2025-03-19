extends Control

func _enter_tree(): unpop()

func pop_at(point: Vector2, text):
    unpop()
    % Label.text = text
    % PopupPanel.popup(Rect2i(point - Vector2( % PopupPanel.size.x / 2.0, 0.0), % PopupPanel.size))

func unpop():
    % PopupPanel.hide()
    % Label.text = ""
    % PopupPanel.size = Vector2(0, 0)
