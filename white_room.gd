extends TabBar

@onready var unit = preload("res://unit.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.


func _on_load_pressed() -> void:
    var newUnit = unit.instantiate()
    $Panel.add_child(newUnit)
