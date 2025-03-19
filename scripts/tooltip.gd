extends Control

func ModelPopup(item):
    %ModelPopup.popup()
    %ModelPopup.get_node('VBoxContainer/Label').text = item[0]
    %ModelPopup.get_node('VBoxContainer/Label2').text = item[1]
    
func HideModelPopup():
    %ModelPopup.hide()

func _process(delta: float) -> void:
    %ModelPopup.position = get_global_mouse_position() + Vector2(25, 0)
