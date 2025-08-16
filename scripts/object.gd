#https://www.youtube.com/watch?v=2dzBKXzGG5s

extends Sprite2D

var dragging: bool = false
var offsetPos: Vector2 = Vector2(0, 0)
var offsetParent: Vector2
var leftBound: float
var rightBound: float
var upperBound: float
var lowerBound: float
var FOV_incrament = 2 *  PI / 180
var maxDist: float
var travelDist: float
var M: float
var neighbours = []

var radius: float
var startPos: Vector2 = Vector2(0, 0)
var temp1: Vector2
var temp2: Vector2

#movement variables
var pointsTest: PackedVector2Array
var targetTest: PackedVector2Array
var targetPos: Vector2
var FOV: PackedVector2Array

#data for tooltips
var data: Array
var circle: Array
var team: int

#debug options
var debugRays: bool = false

@onready var space_state = get_world_2d().direct_space_state

func _ready():
    
    maxDist = globals.inchesToPixels(maxDist) + radius
    offsetParent = get_parent().get_parent().global_position
    #limit the units movemnt to the panel area
    var boundries = get_parent().get_parent().get_size()
    leftBound = offsetParent[0]
    rightBound = offsetParent[0] + boundries[0]
    upperBound = offsetParent[1]
    lowerBound = offsetParent[1] + boundries[1]
    #instantiate the raycasts as child objects
    set_start_position()

func _draw() -> void: 
    draw_line(temp1, temp2, Color.WHITE)
    #Debug Raycasts by drawing them
    
    if debugRays:
        for point in pointsTest:
            draw_circle(point, 10, Color.WHITE)
        
        for point in targetTest:
            draw_circle(point, 5, Color.WHITE)
            
    var circleColour = Color(0.941176, 0.972549, 1, 0.3)
    
    if get_parent().movement and dragging:
        draw_line(startPos - global_position, targetPos - global_position, Color.GRAY)

    draw_polygon(FOV, [circleColour])
                
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void: 
     if get_parent().movement: 
        movement() 
     queue_redraw()
      
func _on_button_button_down() -> void:
    dragging = true
    offsetPos = get_global_mouse_position() - global_position
    travelDist = maxDist

func _on_button_button_up() -> void:
    dragging = false

func _input(_ev):
    if Input.is_key_pressed(KEY_SPACE):
        set_start_position()
        
    if Input.is_key_pressed(KEY_R):
        print('reseting')
        reset_sprite()

func set_start_position() -> void:
    startPos = global_position
    
func reset_sprite() -> void:
    position = startPos - offsetParent
    
func movement():
    if dragging:
        #get rays from the root objects on the edge of the base

        targetPos = get_global_mouse_position() - offsetPos
        #make sure the object isn't being moved outside the bounds of the 
        #gameboard
        targetPos[0] = float(max(leftBound, min(rightBound, targetPos[0])))
        targetPos[1] = float(max(upperBound, min(lowerBound, targetPos[1])))

        var x = (targetPos[0] - startPos[0])
        var y = (targetPos[1] - startPos[1])
        travelDist = (x**2) + (y**2)
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
    
func _on_button_mouse_entered() -> void:
    Tooltip.ModelPopup(data)

func _on_button_mouse_exited() -> void:
    Tooltip.HideModelPopup()
    
func _physics_process(delta: float) -> void:
    var shooting = get_parent().shooting
    var team = get_parent().team == get_parent().selectedTeam
    if shooting and team:
        """
        #get the area the model can currently see
        FOV = PackedVector2Array()
        pointsTest = PackedVector2Array()
        targetTest = PackedVector2Array()
        #get space state for raycasts
        var space_state = get_world_2d().direct_space_state
        var angle = FOV_incrament
        #get the equipped weapons for this model from the global data
        for i in data[2][11].keys():
            #get the range of the equipped weapon
            var equipedWeapon = globals.Weapons.filter('id', [i])
            var weaponRange = equipedWeapon.GetColumns('Range')[0]
            if weaponRange > 0:
                #if it is not a melle weapon, i.e. range 0, then draw what the unit can see
                weaponRange = globals.inchesToPixels(weaponRange) + radius
                while angle <= 2 * PI:
                    #for the angel incrament, fire a ray cast at that angle with length of weapon range
                    var targetPosition = Vector2(0, weaponRange).rotated(angle) + global_position
                    var query = PhysicsRayQueryParameters2D.create(global_position, targetPosition)
                    var result = space_state.intersect_ray(query)
                    if result:
                        #we hit something
                        if result.collider.get_collision_layer() == 5:
                            #collision layer 5 is for ruin footprints, we can see into these but not through
                            #create a new query from where the ray hit to the orinigal target, adding
                            #the first collider as an exception
                            var newQuery = PhysicsRayQueryParameters2D.create(result.position, targetPosition)
                            newQuery.exclude = [result.collider.get_rid()]
                            var newResult = space_state.intersect_ray(newQuery)
                            if newResult:
                                FOV.append(newResult.position - global_position)
                                pointsTest.append(newResult.position - global_position)
                            else:
                                FOV.append(targetPosition - global_position)
                                targetTest.append(targetPosition - global_position)
                        else:
                            FOV.append(result.position - global_position)
                            pointsTest.append(result.position - global_position)
                    else:
                        FOV.append(targetPosition - global_position)
                        targetTest.append(targetPosition - global_position)
                    angle += FOV_incrament
        """
        var space_state = get_world_2d().direct_space_state
        var angle = FOV_incrament
        
    else:
        FOV = PackedVector2Array()

    
    
        
