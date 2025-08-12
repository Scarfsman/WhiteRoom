extends TabBar

@onready var unit = preload("res://Scenes/unit.tscn")
@onready var model = preload("res://Scenes/model.tscn")
@onready var footprint = preload("res://Scenes/TerrainFootprint.tscn")

#variables for zooming
var hovering: bool = false                             
var currScale: float = 1

#https://docs.google.com/document/d/1WV085gGnMPOF-zprcri-9HDW5BWBE34HGc9ndIGRJHM/edit?tab=t.0

#TODO set up a dictionary containing the terain features from the UKTC terrain pack
#write a script to spawn them in                

var terrainFeatures = {'LargeL': [PackedVector2Array([Vector2(0, 0),
                                                     Vector2(0, 200),
                                                     Vector2(200, 200),
                                                     Vector2(200, 0)])],
                        
                        'MediumL': [PackedVector2Array([Vector2(0, 0),
                                                       Vector2(220, 0),
                                                       Vector2(220, 170),
                                                       Vector2(175, 170),
                                                       Vector2(175, 45),
                                                       Vector2(0, 45)])],
                                                    
                        'SmallLR': [PackedVector2Array([Vector2(0, 0),
                                                       Vector2(0, 100),
                                                       Vector2(200, 100),
                                                       Vector2(200, 0)])],
                                                    
                        'SmallLL': [PackedVector2Array([Vector2(0, 0),
                                                       Vector2(0, 100),
                                                       Vector2(200, 100),
                                                       Vector2(200, 0)])],
                                                    
                        'newRuins': [PackedVector2Array([Vector2(0, 0),
                                                        Vector2(0, 76.2),
                                                        Vector2(228.6, 76.2),
                                                        Vector2(228.6, 0)])]}

var wallsFeatures = {'LargeL': [PackedVector2Array([Vector2(0, 0),
                                                   Vector2(200, 0),
                                                   Vector2(200, 200),
                                                   Vector2(195, 200),
                                                   Vector2(195, 5),
                                                   Vector2(0, 5)])],
                        
                    'MediumL': [PackedVector2Array([Vector2(0, 18.5),
                                                    Vector2(220, 18.5),
                                                    Vector2(220, 21.5),
                                                    Vector2(0, 21.5)]),
                                PackedVector2Array([Vector2(198.5, 0),
                                                    Vector2(198.5, 170),
                                                    Vector2(195.5, 170),
                                                    Vector2(195.5, 0)])],
                                                
                    'SmallLR': [PackedVector2Array([Vector2(0, 0),
                                                    Vector2(200, 0),
                                                    Vector2(200, 100),
                                                    Vector2(195, 100),
                                                    Vector2(195, 5),
                                                    Vector2(0, 5)])],
                                                
                    'SmallLL': [PackedVector2Array([Vector2(0, 0),
                                                    Vector2(200, 0),
                                                    Vector2(200, 5),
                                                    Vector2(5, 5),
                                                    Vector2(5, 100),
                                                    Vector2(0, 100)])],
                                                
                    'newRuins': [PackedVector2Array([Vector2(0, 0),
                                                     Vector2(0, 76.2),
                                                     Vector2(5, 76.2),
                                                     Vector2(5, 5),
                                                     Vector2(76.2, 5),
                                                     Vector2(76.2, 0)]),
                                  PackedVector2Array([Vector2(152.4, 76.2),
                                                      Vector2(228.6, 76.2),
                                                      Vector2(228.6, 0),
                                                      Vector2(223.6, 0),
                                                      Vector2(223.6, 71.2),
                                                      Vector2(152.4, 71.2)])]}
 
var layouts = [[['LargeL', [120, 667.684375062506], 6.02637165237177],
                ['SmallLR', [420, 541.25984252], 0],
                ['SmallLL', [656.220472441, 620], 1.5708],
                ['MediumL', [820, 750], (2 * PI) - PI/5.2],
                ['MediumL', [120, 553.228346457],  (2 * PI) - PI/2],
                ['newRuins', [380, 280], 0.729728]]]



var deployments = [PackedVector2Array([Vector2(10, 18),
                                       Vector2(18, 38),
                                       Vector2(30, 22),
                                       Vector2(42, 6),
                                       Vector2(50, 26)])]

func moveFeature(feature: Array, terrainDict: Dictionary):
    '''
    Moves the terraain feature to a given position then rotates it
    around the iniital point. check the terrainFeatures dictionary to see
    which point the inital one it
    '''
    var features = terrainDict[feature[0]]
    var offset = feature[1]
    var theta = feature[2]
    var newPoints = []
     
    for feat in features:
        var newShape = []
        for point in feat:
            var x1 = globals.mmToPixels(point[0])
            var y1 = globals.mmToPixels(point[1])
            
            var x2 = (x1 * cos(theta) - y1 * sin(theta)) + offset[0]
            var y2 = (x1 * sin(theta) + y1 * cos(theta)) + offset[1]
            
            newShape.append(Vector2(x2, y2))
        newPoints.append(newShape)
    return newPoints
 
func mirrorFeature(points: PackedVector2Array):
    #flips a feature about the cetre point to make spawning easier
    var newPoints = PackedVector2Array()
    for point in points:
        var x1 = point[0]
        var y1 = point[1]
        var x2 = ((x1 - 1200) * cos(PI) - (y1 - 880) * sin(PI))
        var y2 = ((x1 - 1200) * sin(PI) + (y1 - 880) * cos(PI))
        
        newPoints.append(Vector2(x2, y2))
    return newPoints
   
func spawnTerrain(layout: Array) -> void:
    """
    for feature in layout:
        var newFeatures = moveFeature(feature, terrainFeatures)
        for newFeature in newFeatures:
            #spawn the footprints
            var terrain = footprint.instantiate()
            $ScrollContainer/Control/Panel/Terrain.add_child(terrain)
            terrain.polygon = newFeature
            terrain.color = Color.REBECCA_PURPLE
            terrain.setCollider()
            #flip the terain and spawn
            var mirrorTerrain = footprint.instantiate()
            $ScrollContainer/Control/Panel/Terrain.add_child(mirrorTerrain)
            mirrorTerrain.polygon = mirrorFeature(terrain.polygon)
            mirrorTerrain.color = Color.REBECCA_PURPLE
            mirrorTerrain.setCollider()
        
        #spawn the walls
        var newWalls = moveFeature(feature, wallsFeatures)
        for newWall in newWalls:
            var terrain = footprint.instantiate()
            $ScrollContainer/Control/Panel/Terrain.add_child(terrain)
            terrain.polygon = newWall
            terrain.color = Color.BLACK
            terrain.setCollider([1, 2])
            #flip the terain and spawn
            var mirrorTerrain = footprint.instantiate()
            $ScrollContainer/Control/Panel/Terrain.add_child(mirrorTerrain)
            mirrorTerrain.polygon = mirrorFeature(terrain.polygon)
            mirrorTerrain.color = Color.BLACK
            mirrorTerrain.setCollider([1, 2])
    """

    var walls = [PackedVector2Array([Vector2(600, 442),Vector2(600, 640),Vector2(602, 640),Vector2(602, 442)]),
                 PackedVector2Array([Vector2(602, 440),Vector2(602, 442),Vector2(798, 442),Vector2(798, 440)]),
                 PackedVector2Array([Vector2(600, 640),Vector2(600, 642),Vector2(802, 642),Vector2(802, 640)]),
                 PackedVector2Array([Vector2(802, 440),Vector2(802, 640),Vector2(800, 640),Vector2(800, 440)])]
    for feat in walls:
        var terrain = footprint.instantiate() 
        $ScrollContainer/Control/Panel/Terrain.add_child(terrain)
        terrain.polygon = feat
        terrain.color = Color.REBECCA_PURPLE
        terrain.setCollider(5)
    

        
#code for deployments
func spawnDeployment(objectives: Array) -> void:
    for markerPos in objectives[0]:
        var newX = globals.inchesToPixels(markerPos[0])
        var newY = globals.inchesToPixels(markerPos[1])
        var marker = Polygon2D.new()
        #the radius of an objective marker
        var radius = globals.inchesToPixels(3.7874015748)
        marker.polygon = generate_circle_polygon(radius, Vector2(newX, newY))
        marker.z_index = 2
        marker.color = Color(1, 0.921569, 0.803922, 0.4)
        $ScrollContainer/Control/Panel/Terrain.add_child(marker)
        
func generate_circle_polygon(radius: float, position: Vector2) -> PackedVector2Array:
    var angle_delta: float = (PI * 2) / 20
    var vector: Vector2 = Vector2(radius, 0)
    var polygon: PackedVector2Array

    for _i in 20:
        polygon.append(vector + position)
        vector = vector.rotated(angle_delta)
    return polygon
       
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass
         
func _process(delta: float) -> void:
    var thing = $PhaseSelect  
         
func _input(event):
 if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP and currScale <= 3:
            currScale += 0.1
            $ScrollContainer/Control/Panel.scale = Vector2(currScale, currScale)
        if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and currScale >1:
            currScale -= 0.1
            $ScrollContainer/Control/Panel.scale = Vector2(currScale, currScale)       
        
func _draw():
    #draw a grid to make debugging terrain placement easier
    var x  = 0 
    while x <= 1200:
        draw_line(Vector2(x, 0) + $ScrollContainer.position, Vector2(x, 880) + $ScrollContainer.position, Color.BLACK)
        x += 20
    var y = 0 
    while y <= 880:
        draw_line(Vector2(0, y) + $ScrollContainer.position, Vector2(1200, y) + $ScrollContainer.position, Color.BLACK)
        y += 20

func _on_load_pressed() -> void:
    var models = []
    #filter the units data frame for the unit based on the drop down box
    var unitData = globals.Units.filter('id', [$UnitSelection.get_selected_id()])
    #get the model data for the tooltips
    var modelData = globals.Units.filter('id', [$UnitSelection.get_selected_id()])
    unitData = unitData.GetColumns(['Count', 'Base Size', 'M']).data
    #for each model type, get the information required to spawn the model,
    #then save the information for the tool tips. 
    for n in range(len(unitData)) :
        for i in range(unitData[n][0]):
            var newModel = [unitData[n][1], unitData[n][2]]
            var data = [modelData.data[n][1]]
            var temp = ''
            for col in range(2, 9):
                var NewString = modelData.columns[col] + ': ' + str(modelData.data[n][col]) +'\n'
                temp += NewString
            data.append(temp)
            newModel.append(data)
            models.append(newModel)
                
    var newUnit = unit.instantiate()
    #set the model to the correct phase
    var index = $PhaseSelect.selected
    if index == 0:
        newUnit.movement = true
        newUnit.shooting = false
        newUnit.charge = false
    elif index == 1:
        newUnit.movement = false
        newUnit.shooting = true
        newUnit.charge = false
    else:
        newUnit.movement = false
        newUnit.shooting = false
        newUnit.charge = true
    #instantiate the models
    for indx in range(len(models)):
        #create a new model class object and add it to the unit
        var newModel = model.instantiate()
        newUnit.add_child(newModel)
        
        #set the models movement
        newModel.maxDist = models[indx][1]
        
        #resolve models radius
        var radius: float = models[indx][0]
        #convert milimeters to inches
        radius = radius/25.4
        #convert inches to pixels
        radius = globals.inchesToPixels(radius)
        newModel.radius = radius
        #get the scale factor for the sprite
        radius = radius/100
        var rowCount: int = 0
        #set the sprite scale accordingly
        newModel.get_node('Sprite2D').scale = Vector2(radius, radius)
        rowCount = indx/5
        #set the tooltip data for the model
        print(models[indx][2])
        newModel.data = models[indx][2] 
        
        #spawn the model
        var x = (indx*radius*150) + 150 - ((indx/5)*radius*150*5)
        var y = 150 + (radius * 150 * rowCount)
        newModel.position = Vector2(x, y)
        
    $ScrollContainer/Control/Panel/Units.add_child(newUnit)

func _on_clear_units_pressed() -> void:
    for child in $ScrollContainer/Control/Panel/Units.get_children():
        child.queue_free()

func _on_spawn_terrain_pressed() -> void:
    spawnTerrain(layouts[0])

func _on_scroll_container_mouse_entered() -> void:
    hovering = true

func _on_scroll_container_mouse_exited() -> void:
    hovering = false

func _on_spawn_deployment_pressed() -> void:
    spawnDeployment(deployments)

func _on_phase_select_item_selected(index: int) -> void:
    for unit in $ScrollContainer/Control/Panel/Units.get_children():
        if index == 0:
            unit.movement = true
            unit.shooting = false
            unit.charge = false
        elif index == 1:
            unit.movement = false
            unit.shooting = true
            unit.charge = false
        else:
            unit.movement = false
            unit.shooting = false
            unit.charge = true
