extends Sprite2D

var dragging: bool = false
var offsetPos: Vector2 = Vector2(0, 0)
var offsetParent: Vector2
var leftBound: float
var rightBound: float
var upperBound: float
var lowerBound: float
var maxDist: float =  globals.inchesToPixels(24)

var startPos: Vector2 = Vector2(0, 0)

func _ready():
    offsetParent = get_parent().get_transform()[2]
    var boundries = get_parent().get_size()
    leftBound = offsetParent[0]
    rightBound = offsetParent[0] + boundries[0]
    upperBound = offsetParent[1]
    lowerBound = offsetParent[1] + boundries[1]

func _draw() -> void:
    if dragging:
        print(startPos)
        draw_circle(startPos - global_position,
                    maxDist,
                    Color.GRAY,
                    false)
    

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if dragging:
        var targetPos = get_global_mouse_position() - offsetPos 
        #make sure the object isn't being moved outside the bounds of the 
        #gameboard
        targetPos[0] = float(max(leftBound, min(rightBound, targetPos[0])))
        targetPos[1] = float(max(upperBound, min(lowerBound, targetPos[1])))
        
        var x = (targetPos[0] - startPos[0])
        var y = (targetPos[1] - startPos[1])
        var travelDist: float = (x**2) + (y**2)
        travelDist = pow(travelDist, 1/2.0)
        print(travelDist)
        #if we are traveling further than we are allowed, stop that
        if travelDist > maxDist:
            #get the angle of instance based on our current target
            var angle = atan2(y, x)
            #re-calculate the the target position using the old angle but
            #set the hypotenuse to be the maxdistance we can travel
            var xNew = startPos[0] + (maxDist * cos(angle))
            var yNew = startPos[1] + (maxDist * sin(angle))
            targetPos = Vector2(xNew, yNew)
        position = targetPos - offsetParent
        queue_redraw()
    
func _on_button_button_down() -> void:
    dragging = true
    startPos = global_position
    offsetPos = get_global_mouse_position() - global_position

func _on_button_button_up() -> void:
    dragging = false
    startPos = Vector2(0, 0)
