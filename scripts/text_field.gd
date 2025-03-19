extends Control

var rowNumber: int = 0

func _on_line_edit_text_submitted(new_text: String) -> void:
    globals.Units.data[rowNumber][-1] = int(new_text)
    
