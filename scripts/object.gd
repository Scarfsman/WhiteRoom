#https://www.youtube.com/watch?v=2dzBKXzGG5s

extends Sprite2D

var dragging: bool = false
var offsetPos: Vector2 = Vector2(0, 0)
var offsetParent: Vector2
var leftBound: float
var rightBound: float
var upperBound: float
var lowerBound: float
var FOV_incrament = 2 *  PI / 60
var maxDist: float
var travelDist
var M: float = 14
var neighbours = []

var startPos: Vector2 = Vector2(0, 0)
var temp1: Vector2
var temp2: Vector2

@onready var space_state = get_world_2d().direct_space_state

func _ready():
    maxDist = globals.inchesToPixels(M)
    offsetParent = get_parent().global_position
    var boundries = get_parent().get_size()
    leftBound = offsetParent[0]
    rightBound = offsetParent[0] + boundries[0]
    upperBound = offsetParent[1]
    lowerBound = offsetParent[1] + boundries[1]
    var angle = FOV_incrament
    while angle <= 2 * PI:
        var newRay = RayCast2D.new()
        newRay.target_position = Vector2(0, maxDist).rotated(angle)
        newRay.visible = false
        $Rays.add_child(newRay)
        angle += FOV_incrament
    set_start_position()

func get_FOV_circle(from: Vector2, radius):
    var angle = FOV_incrament
    var points = PackedVector2Array()
    
    for ray in $Rays.get_children():
        ray.target_position =  ray.target_position.normalized() * radius
        if ray.is_colliding():
            print
            points.append((ray.get_collision_point() - ray.global_position))
        else:
            points.append(ray.target_position)

    return points
        
func draw_target_area(position: Vector2, distance:float ) -> void:
    var points = get_FOV_circle(position, distance)
    set_target_area(points)

func _draw() -> void: 
    draw_line(temp1, temp2, Color.WHITE)
      
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:   
    if dragging:
        var prevPos = position
        var targetPos = get_global_mouse_position() - offsetPos
        #make sure the object isn't being moved outside the bounds of the 
        #gameboard
        targetPos[0] = float(max(leftBound, min(rightBound, targetPos[0])))
        targetPos[1] = float(max(upperBound, min(lowerBound, targetPos[1])))
        
        var x = (targetPos[0] - startPos[0])
        var y = (targetPos[1] - startPos[1])
        var travelDist: float = (x**2) + (y**2)
        travelDist = pow(travelDist, 1/2.0)
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
        draw_target_area(Vector2(0, 0), maxDist - min(travelDist, maxDist) + 50)      
    
func _on_button_button_down() -> void:
    dragging = true
    offsetPos = get_global_mouse_position() - global_position
    travelDist = maxDist

func _on_button_button_up() -> void:
    dragging = false
    clear_target_area()

func set_target_area(points: PackedVector2Array) -> void:
    $Area.polygon = points
    
func clear_target_area() -> void:
    set_target_area(PackedVector2Array())


func _input(ev):
    if Input.is_key_pressed(KEY_SPACE):
        set_start_position()
    if Input.is_key_pressed(KEY_R):
        print('reseting')
        reset_sprite()

func set_start_position() -> void:
    startPos = global_position
    maxDist = globals.inchesToPixels(M) 
    
func reset_sprite() -> void:
    position = startPos - offsetParent
    maxDist = globals.inchesToPixels(M)
    
