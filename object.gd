extends Sprite2D

var dragging: bool = false
var offsetPos: Vector2 = Vector2(0, 0)
var offsetParent: Vector2
var leftBound: float
var rightBound: float
var upperBound: float
var lowerBound: float

func _ready():
    offsetParent = get_parent().get_transform()[2]
    var boundries = get_parent().get_size()
    leftBound = offsetParent[0]
    rightBound = offsetParent[0] + boundries[0]
    upperBound = offsetParent[1]
    lowerBound = offsetParent[1] + boundries[1]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if dragging:
        var targetPos = get_global_mouse_position() - offsetPos 
        targetPos[0] = max(leftBound, min(rightBound, targetPos[0]))
        targetPos[1] = max(upperBound, min(lowerBound, targetPos[1]))
        position = targetPos - offsetParent
    
func _on_button_button_down() -> void:
    dragging = true
    offsetPos = get_global_mouse_position() - global_position

func _on_button_button_up() -> void:
    dragging = false
