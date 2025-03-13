extends TabBar

@onready var unit = preload("res://Scenes/unit.tscn")
@onready var model = preload("res://Scenes/model.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _on_load_pressed() -> void:
    var newUnit = unit.instantiate()
    for i in range(5):
        var newModel = model.instantiate()
        newUnit.add_child(newModel)
        newModel.position = Vector2(i*100 + 100, 100)
        newModel.get_node('Sprite2D').scale = Vector2(0.2, 0.2)
    $Panel.add_child(newUnit)
